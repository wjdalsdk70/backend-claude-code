# Testing Requirements

## 최소 테스트 커버리지: 80%

테스트 유형 (모두 필요):
1. **단위 테스트** — 개별 함수, 유틸리티, 서비스
2. **통합 테스트** — API 엔드포인트, 데이터베이스 작업
3. **E2E 테스트** — 중요한 사용자 흐름

## 테스트 주도 개발 (TDD)

필수 워크플로우:
1. 먼저 테스트 작성 (RED)
2. 테스트 실행 — 실패해야 함
3. 최소 구현 작성 (GREEN)
4. 테스트 실행 — 통과해야 함
5. 리팩토링 (IMPROVE)
6. 커버리지 확인 (80%+)

## 테스트 구조 (AAA 패턴)

```java
@Test
@DisplayName("유효하지 않은 요청 시 400 반환")
void returns400_whenRequestInvalid() {
    // Arrange
    var request = new CreateOrderRequest("", null);

    // Act
    var result = orderService.create(request);

    // Assert
    assertThatThrownBy(() -> orderService.create(request))
        .isInstanceOf(ConstraintViolationException.class);
}
```

## 테스트 이름 규칙

행동을 설명하는 명확한 이름 사용:
```java
void should_return404_when_userNotFound()
void throws_exception_when_apiKeyMissing()
void returns_emptyPage_when_noResultsMatch()
```

## 커버리지 도구

- **JaCoCo** — Maven/Gradle용 커버리지 리포트
- 목표: 라인 커버리지 80%+
- CI에서 강제 적용: 미달 시 빌드 실패
