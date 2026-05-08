# RULES.md

## 반드시 해야 할 것 (Must Always)

- Java 코드 수정 후 `java-reviewer` 에이전트 실행
- 새 기능/버그 수정은 TDD 워크플로우 준수 (RED → GREEN → REFACTOR)
- 커밋 전 `./mvnw verify` 또는 `./gradlew check` 통과 확인
- 인증/DB쿼리/파일처리 코드 변경 시 `security-reviewer` 실행
- 빌드 실패 시 `java-build-resolver` 에이전트에 위임
- 생성자 주입 사용 (필드 주입 `@Autowired` 금지)
- DTO에 record 사용 (Java 16+)
- 서비스 레이어에 `@Transactional` 적용
- 읽기 전용 서비스 메서드에 `@Transactional(readOnly = true)` 적용
- 모든 엔드포인트 `@Valid` 검증 적용

## 절대 하면 안 되는 것 (Must Never)

- 소스 코드에 시크릿/토큰/비밀번호 하드코딩
- `Optional.get()` 호출 (항상 `.orElseThrow()`)
- 컬렉션에 `FetchType.EAGER` 사용
- 컨트롤러에서 JPA 엔티티 직접 반환
- 빈 catch 블록 (`catch (Exception e) {}`)
- 단위 테스트에 `@SpringBootTest` 사용
- 컨트롤러에 비즈니스 로직 작성
- 빌드 경고를 `@SuppressWarnings`로 억제 (근본 원인 수정)
- 문자열 연결로 SQL 쿼리 조립
- `Thread.sleep()`을 비동기 테스트에 사용 (Awaitility 사용)

## 코드 형식 (Format Standards)

**Agents** — `agents/*.md`, YAML frontmatter: `name`, `description`, `tools`, `model`

**Skills** — `skills/<name>/SKILL.md`, YAML frontmatter: `name`, `description`, `origin`

**Commands** — `commands/*.md`, frontmatter: `description`, `argument-hint`

**Rules** — `rules/<layer>/*.md`, paths frontmatter 포함

**파일 이름** — 소문자 하이픈 구분 (예: `order-service.md`, `java-reviewer.md`)

## 커밋 스타일 (Conventional Commits)

```
<type>: <description>

Types: feat, fix, refactor, docs, test, chore, perf, ci
```

예시:
- `feat: 주문 생성 API 추가`
- `fix: N+1 쿼리 문제 JOIN FETCH로 해결`
- `test: OrderService 단위 테스트 커버리지 80% 달성`
- `refactor: PaymentService 생성자 주입으로 전환`

## 심각도 기준

| 등급 | 의미 | 조치 |
|------|------|------|
| CRITICAL | 보안 취약점, 데이터 손실 위험 | 즉시 수정, 머지 차단 |
| HIGH | 버그, 아키텍처 위반 | 머지 전 수정 |
| MEDIUM | 유지보수성 이슈 | 수정 권장 |
| LOW | 스타일, 마이너 제안 | 선택적 |
