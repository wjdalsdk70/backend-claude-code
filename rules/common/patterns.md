# Common Patterns

## 레포지토리 패턴

일관된 인터페이스 뒤에 데이터 접근을 캡슐화:
- 표준 작업 정의: findAll, findById, create, update, delete
- 구체적 구현이 저장소 세부사항 처리 (데이터베이스, API, 파일 등)
- 비즈니스 로직은 저장 메커니즘이 아닌 추상 인터페이스에 의존
- 데이터 소스 교체 및 모의 테스트 단순화

## API 응답 형식

모든 API 응답에 일관된 엔벨로프 사용:
- 성공/상태 표시자 포함
- 데이터 페이로드 포함 (오류 시 null)
- 오류 메시지 필드 포함 (성공 시 null)
- 페이지네이션 응답을 위한 메타데이터 포함 (total, page, limit)

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

## 서비스 레이어 패턴

비즈니스 로직을 서비스 클래스에 집중:

```java
@Service
public class OrderService {
    private final OrderRepository orderRepository;

    // 생성자 주입 — 필드 주입 금지
    public OrderService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    @Transactional
    public OrderResponse createOrder(CreateOrderRequest request) {
        var order = Order.from(request);
        var saved = orderRepository.save(order);
        return OrderResponse.from(saved);
    }

    @Transactional(readOnly = true)
    public Page<OrderResponse> listOrders(Pageable pageable) {
        return orderRepository.findAll(pageable).map(OrderResponse::from);
    }
}
```

## 예외 처리 패턴

도메인 예외를 중앙에서 처리:

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(EntityNotFoundException.class)
    ResponseEntity<ApiResponse<Void>> handleNotFound(EntityNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(ApiResponse.error(ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<ApiResponse<Void>> handleValidation(MethodArgumentNotValidException ex) {
        String message = ex.getBindingResult().getFieldErrors().stream()
            .map(e -> e.getField() + ": " + e.getDefaultMessage())
            .collect(Collectors.joining(", "));
        return ResponseEntity.badRequest().body(ApiResponse.error(message));
    }
}
```
