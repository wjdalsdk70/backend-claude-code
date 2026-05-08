# backend-claude-code

Java/Spring Boot 백엔드 프로젝트에 Claude Code 설정을 빠르게 적용하는 harness.

---

## 설치

```bash
# 현재 디렉토리에 설치
./install.sh

# 특정 프로젝트 경로에 설치
./install.sh /path/to/your/project
```

설치 시 이미 존재하는 파일은 덮어쓰지 않고 스킵합니다.
복사된 파일 목록은 `.claude/.installed-files`에 기록됩니다.

## 제거

```bash
# 현재 디렉토리에서 제거
./uninstall.sh

# 특정 프로젝트 경로에서 제거
./uninstall.sh /path/to/your/project
```

`.installed-files`에 기록된 파일만 삭제합니다. 프로젝트에서 직접 만든 파일은 건드리지 않습니다.

---

## 설치 후 해야 할 일

1. `CLAUDE.md` — 프로젝트 이름, 아키텍처, 패키지 구조를 맞게 수정
2. `.mcp.json` — `GITHUB_TOKEN` 환경변수 설정
3. `.claude/settings.json` — 기존 파일이 있다면 수동 병합

---

## 포함 항목

### 에이전트 (8개)

| 에이전트 | 역할 |
|---------|------|
| `java-reviewer` | Java/Spring Boot 코드 리뷰 |
| `java-build-resolver` | 빌드·컴파일 에러 수정 |
| `security-reviewer` | 보안 취약점 분석 (OWASP) |
| `tdd-guide` | TDD 워크플로우 안내 |
| `planner` | 기능 구현 계획 수립 |
| `database-reviewer` | DB 쿼리·스키마 최적화 |
| `performance-optimizer` | 성능 병목 분석 |
| `code-reviewer` | 코드 품질 종합 리뷰 |

### 슬래시 커맨드 (13개)

#### dev — 개발 워크플로우

| 커맨드 | 설명 |
|--------|------|
| `/dev` | 계획 → 구현 → 테스트 전체 워크플로우 실행 |
| `/dev plan` | 코드베이스 분석 후 구현 계획서 작성 |
| `/dev run` | 계획서 기반 코드 구현 및 검증 |
| `/dev test` | TDD 워크플로우 (테스트 먼저 작성) |
| `/dev review` | 로컬 변경사항(Java 특화) 또는 PR 종합 리뷰 |
| `/dev build` | 빌드 오류 진단 및 수정 |
| `/dev fix` | 빌드 에러 자동 수정 |
| `/dev verify` | 빌드·정적분석·테스트·커버리지·보안 전체 검증 |
| `/dev coverage` | 커버리지 분석 및 미달 영역 테스트 생성 |

#### git — GitHub 워크플로우

| 커맨드 | 설명 |
|--------|------|
| `/git commit` | 변경사항 커밋 |
| `/git pr` | PR 자동 생성 (push → PR → CI 확인) |
| `/git issue` | 이슈 생성 (`bug` / `feat`) |

#### 기타

| 커맨드 | 설명 |
|--------|------|
| `/db-migrate` | DB 마이그레이션 실행·상태 확인·롤백 (Flyway/Liquibase 자동 감지) |

### 스킬 (10개)

> 사용법: 프롬프트에서 `skill: <이름>` 으로 참조

#### Spring Boot

| 스킬 | 설명 |
|------|------|
| `springboot-patterns` | Controller·Service·Repository 구조, 공통 패턴 |
| `springboot-security` | Spring Security 설정 및 리뷰 기준 |
| `springboot-tdd` | JUnit5·Mockito·Testcontainers TDD 워크플로우 |

#### Java

| 스킬 | 설명 |
|------|------|
| `java-coding-standards` | Java 코딩 규칙·관용구·금지 패턴 |
| `jpa-patterns` | 엔티티 설계, N+1 해결, 쿼리 최적화 |

#### 데이터베이스

| 스킬 | 설명 |
|------|------|
| `database-migrations` | Flyway·Liquibase 마이그레이션 패턴 |
| `postgres-patterns` | PostgreSQL 쿼리·인덱스·성능 패턴 |

#### 아키텍처

| 스킬 | 설명 |
|------|------|
| `hexagonal-architecture` | 헥사고날 아키텍처 (Ports & Adapters) 구현 |
| `api-design` | REST API 설계 원칙·버저닝·에러 포맷 |
| `architecture-decision-records` | ADR 작성 가이드 |


### 규칙

| 파일 | 적용 범위 |
|------|----------|
| `coding-style` | 전체 Java 파일 |
| `testing` | 테스트 파일 |
| `security` | 인증·인가·입력처리 |
| `hooks` | PostToolUse·Stop 자동화 |
| `architecture` | 레이어 구조 및 책임 |
| `controller-patterns` | `*Controller.java` |
| `dto-patterns` | `*Dtos.java` |
| `entity-patterns` | `*Entity.java`, `domain/**` |
| `repository-patterns` | `*Repository*.java` |
| `service-patterns` | `*Service.java` |
| `error-handling` | 예외 처리 전반 |

### GitHub 템플릿

- `.github/PULL_REQUEST_TEMPLATE.md` — Spring Boot 체크리스트 포함 PR 템플릿
- `.github/ISSUE_TEMPLATE/bug_report.md` — 버그 리포트
- `.github/ISSUE_TEMPLATE/feature_request.md` — 기능 요청
