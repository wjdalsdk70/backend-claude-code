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

### 슬래시 커맨드 (14개)

#### 검증 & 리뷰

| 커맨드 | 설명 |
|--------|------|
| `/verify` | 빌드·정적분석·테스트·커버리지·보안 전체 검증 |
| `/java-review` | Java/Spring Boot 코드 리뷰 |
| `/code-review` | 로컬 변경사항 또는 PR 종합 리뷰 |
| `/review-pr` | 다관점 PR 리뷰 (여러 에이전트 병렬 실행) |

#### 빌드 & 테스트

| 커맨드 | 설명 |
|--------|------|
| `/java-build` | 빌드 오류 진단 및 수정 |
| `/build-fix` | 빌드 에러 자동 수정 |
| `/java-test` | TDD 워크플로우 (테스트 먼저 작성) |
| `/test-coverage` | 커버리지 분석 및 미달 영역 테스트 생성 |

#### 데이터베이스

| 커맨드 | 설명 |
|--------|------|
| `/db-migrate` | DB 마이그레이션 실행·상태 확인·롤백 (Flyway/Liquibase 자동 감지) |

#### PRP 워크플로우 (계획 → 구현 → 커밋 → PR)

| 커맨드 | 설명 |
|--------|------|
| `/prp-plan` | 코드베이스 분석 후 구현 계획서 작성 |
| `/prp-implement` | 계획서 기반 코드 구현 및 검증 |
| `/git commit` | 변경사항 커밋 |
| `/git pr` | PR 자동 생성 (push → PR → CI 확인) |

#### GitHub

| 커맨드 | 설명 |
|--------|------|
| `/git issue` | GitHub 이슈 생성 (`bug` / `feat`) |

### 스킬 (13개)

`springboot-patterns`, `springboot-security`, `springboot-tdd`, `jpa-patterns`, `java-coding-standards`, `springboot-verification`, `database-migrations`, `postgres-patterns`, `hexagonal-architecture`, `api-design`, `architecture-decision-records`, `git-workflow`, `github-ops`

### 규칙

- `common/` — 코딩 스타일, 테스트, 보안, 패턴, Git 워크플로우, 코드 리뷰, 개발 워크플로우
- `java/` — Java 코딩 스타일, 테스트, 보안, 패턴, hooks

### GitHub 템플릿

- `.github/PULL_REQUEST_TEMPLATE.md` — Spring Boot 체크리스트 포함 PR 템플릿
- `.github/ISSUE_TEMPLATE/bug_report.md` — 버그 리포트
- `.github/ISSUE_TEMPLATE/feature_request.md` — 기능 요청
