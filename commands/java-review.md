---
description: Java/Spring Boot 코드 리뷰 — java-reviewer 에이전트로 변경된 Java 파일을 리뷰합니다
argument-hint: [file path | blank for staged changes]
---

# Java Code Review

**Input**: $ARGUMENTS

---

## Phase 1 — GATHER

```bash
git diff --name-only HEAD -- '*.java'
```

변경된 Java 파일이 없으면 종료: "리뷰할 Java 파일이 없습니다."

특정 파일이 지정된 경우 (`$ARGUMENTS`):
```bash
git diff HEAD -- "$ARGUMENTS"
```

## Phase 2 — BUILD CHECK

```bash
./mvnw compile -q --no-transfer-progress 2>&1 | tail -5 || \
./gradlew compileJava -q 2>&1 | tail -5
```

컴파일 실패 시 → `/java-build` 실행 먼저.

## Phase 3 — DELEGATE TO java-reviewer

`java-reviewer` 에이전트 실행:

변경된 파일 목록과 함께 다음을 리뷰:
- **CRITICAL**: 보안 취약점, 오류 처리 누락
- **HIGH**: Spring Boot 아키텍처 위반, JPA N+1, 필드 주입
- **MEDIUM**: 동시성 문제, Java 관용구, 테스트 품질
- **LOW**: 명명, 스타일

## Phase 4 — REPORT

심각도별 정리:

```
Java Code Review — <날짜>
Files: <파일 목록>
Build: PASS/FAIL

CRITICAL (N):
  - [파일:라인] 문제 → 권장 수정

HIGH (N):
  - [파일:라인] 문제 → 권장 수정

MEDIUM (N):
  - [파일:라인] 문제

Decision: APPROVE | REQUEST_CHANGES | BLOCK
```

- CRITICAL/HIGH → 수정 후 재리뷰 필요
- MEDIUM만 → 권장 수정이지만 머지 가능
- 없음 → APPROVE
