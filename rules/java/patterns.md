---
paths:
  - "**/*.java"
---
# Java Patterns

> This file extends [common/patterns.md](../common/patterns.md) with Java-specific content.

## 레포지토리 패턴

인터페이스 뒤에 데이터 접근 캡슐화:

```java
public interface OrderRepository {
    Optional<Order> findById(Long id);
    Page<Order> findAll(Pageable pageable);
    Order save(Order order);
    void deleteById(Long id);
}
```

구체적 구현이 저장소 세부사항 처리 (JPA, JDBC, 테스트용 인메모리).

## 서비스 레이어

서비스 클래스에 비즈니스 로직 집중; 컨트롤러와 레포지토리는 얇게:

```java
@Service
public class OrderService {
    private final OrderRepository orderRepository;
    private final PaymentGateway paymentGateway;

    public OrderService(OrderRepository orderRepository, PaymentGateway paymentGateway) {
        this.orderRepository = orderRepository;
        this.paymentGateway = paymentGateway;
    }

    @Transactional
    public OrderResponse placeOrder(CreateOrderRequest request) {
        var order = Order.from(request);
        paymentGateway.charge(order.total());
        var saved = orderRepository.save(order);
        return OrderResponse.from(saved);
    }

    @Transactional(readOnly = true)
    public OrderResponse findById(Long id) {
        return orderRepository.findById(id)
            .map(OrderResponse::from)
            .orElseThrow(() -> new OrderNotFoundException(id));
    }
}
```

## 생성자 주입

항상 생성자 주입 사용 — 필드 주입 절대 금지:

```java
// GOOD — 생성자 주입 (테스트 가능, 불변)
@Service
public class NotificationService {
    private final EmailSender emailSender;

    public NotificationService(EmailSender emailSender) {
        this.emailSender = emailSender;
    }
}

// BAD — 필드 주입 (테스트 불가, 프레임워크 의존)
@Service
public class NotificationService {
    @Autowired
    private EmailSender emailSender;
}
```

## DTO 매핑

DTO에 record 사용. 서비스/컨트롤러 경계에서 매핑:

```java
public record OrderResponse(Long id, String customerName, BigDecimal total, OrderStatus status) {
    public static OrderResponse from(Order order) {
        return new OrderResponse(
            order.getId(),
            order.getCustomerName(),
            order.getTotal(),
            order.getStatus()
        );
    }
}
```

## Sealed Types 도메인 모델

```java
public sealed interface PaymentResult permits PaymentSuccess, PaymentFailure {
    record PaymentSuccess(String transactionId, BigDecimal amount) implements PaymentResult {}
    record PaymentFailure(String errorCode, String message) implements PaymentResult {}
}

// 완전한 처리 (Java 21+)
String message = switch (result) {
    case PaymentSuccess s -> "결제 완료: " + s.transactionId();
    case PaymentFailure f -> "결제 실패: " + f.errorCode();
};
```

## API 응답 엔벨로프

일관된 API 응답:

```java
public record ApiResponse<T>(boolean success, T data, String error) {
    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(true, data, null);
    }
    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>(false, null, message);
    }
}
```

## Builder 패턴

선택적 매개변수가 많은 객체에 사용:

```java
SearchCriteria criteria = new SearchCriteria.Builder()
    .query("spring boot")
    .page(0)
    .size(20)
    .sortBy("createdAt")
    .build();
```

## 참고

skill: `springboot-patterns` — Spring Boot 아키텍처 패턴
skill: `jpa-patterns` — 엔티티 설계 및 쿼리 최적화
