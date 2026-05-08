# CLAUDE.md

Java/Spring Boot 백엔드 API 프로젝트를 위한 Claude Code 가이드.

> **이 파일을 프로젝트에 맞게 커스터마이징하세요.** 특히 "프로젝트 개요"와 "아키텍처" 섹션.

## 프로젝트 개요

<!-- TODO: 프로젝트 목적과 주요 도메인을 여기에 작성하세요 -->
Spring Boot 기반 REST API 백엔드 서비스.

## 빌드 명령어

```bash
# Maven (권장)
./mvnw clean compile              # 컴파일
./mvnw test                       # 단위 테스트
./mvnw verify                     # 전체 테스트 + 정적 분석
./mvnw spring-boot:run            # 로컬 실행
./mvnw checkstyle:check           # 스타일 검사
./mvnw spotbugs:check             # 정적 분석
./mvnw dependency-check:check     # CVE 스캔

# Gradle
./gradlew compileJava             # 컴파일
./gradlew test                    # 단위 테스트
./gradlew check                   # 전체 테스트 + 린트
./gradlew bootRun                 # 로컬 실행
./gradlew jacocoTestReport        # 커버리지 리포트
```

## 아키텍처

3계층 표준 아키텍처:

```
Controller  →  Service  →  Repository  →  Database
   (HTTP)    (Business)    (Data Access)
```

```
src/main/java/com/example/
├── controller/      # REST 엔드포인트, 입력 검증
├── service/         # 비즈니스 로직, 트랜잭션
├── repository/      # Spring Data JPA 인터페이스
├── domain/          # 엔티티, VO, 도메인 모델
├── dto/             # 요청/응답 DTO (record 선호)
├── exception/       # 도메인 예외, 글로벌 핸들러
└── config/          # Spring 설정 클래스

src/test/java/com/example/
├── controller/      # @WebMvcTest
├── service/         # @ExtendWith(MockitoExtension.class)
├── repository/      # @DataJpaTest
└── integration/     # @SpringBootTest
```

## 개발 워크플로우

```
1. 기능 계획 (/java-review or planner 에이전트)
2. 테스트 먼저 작성 (/java-test)
3. 구현 → 빌드 검증 (/java-build)
4. 코드 리뷰 (/java-review)
5. 보안 확인 (security-reviewer 에이전트)
6. ./mvnw verify 통과 후 커밋
```

## 주요 슬래시 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/java-review` | Java/Spring Boot 코드 품질 리뷰 |
| `/java-build` | 빌드 오류 진단 및 수정 |
| `/java-test` | TDD 워크플로우 (테스트 먼저) |
| `/code-review` | 로컬 변경 또는 PR 종합 리뷰 |
| `/build-fix` | 빌드 에러 자동 수정 |

## 에이전트

| 에이전트 | 용도 | 언제 사용 |
|---------|------|----------|
| `java-reviewer` | Java/Spring Boot 코드 리뷰 | 코드 수정 후 항상 |
| `java-build-resolver` | 빌드/컴파일 에러 수정 | 빌드 실패 시 |
| `security-reviewer` | 보안 취약점 분석 | 인증/인가/입력처리 변경 시 |
| `tdd-guide` | TDD 워크플로우 안내 | 새 기능/버그수정 시 |
| `planner` | 기능 구현 계획 수립 | 복잡한 기능 시작 전 |

## 핵심 규칙

1. **코드 수정 후**: 반드시 `java-reviewer` 에이전트 실행
2. **새 기능**: TDD 워크플로우 준수 (테스트 RED → 구현 GREEN → 리팩토링)
3. **빌드 실패**: `java-build-resolver` 에이전트 사용, 증상 억제 금지
4. **보안 코드**: `security-reviewer` 실행 필수 (인증/DB쿼리/파일처리)
5. **커밋 전**: `./mvnw verify` 또는 `./gradlew check` 통과 확인
6. **의존성 주입**: 필드 주입(`@Autowired`) 금지 — 생성자 주입 필수

## 스킬 참조

| 작업 | 스킬 |
|------|------|
| REST API 구조 설계 | `springboot-patterns` |
| JPA 엔티티/쿼리 최적화 | `jpa-patterns` |
| 보안 설정 | `springboot-security` |
| TDD 패턴 | `springboot-tdd` |
| 코딩 표준 | `java-coding-standards` |
