# Git Workflow

## 커밋 메시지 형식

```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

## Pull Request 워크플로우

PR 생성 시:
1. 전체 커밋 히스토리 분석 (최신 커밋만 아님)
2. `git diff [base-branch]...HEAD`로 모든 변경사항 확인
3. 종합적인 PR 요약 작성
4. TODO가 포함된 테스트 계획 포함
5. 새 브랜치인 경우 `-u` 플래그로 푸시

## 브랜치 전략

```
main            # 프로덕션 브랜치
develop         # 개발 통합 브랜치
feature/<name>  # 기능 개발
fix/<name>      # 버그 수정
refactor/<name> # 리팩토링
```

## 커밋 전 체크리스트

- [ ] `./mvnw verify` 또는 `./gradlew check` 통과
- [ ] 새 기능에 테스트 존재
- [ ] 하드코딩된 시크릿 없음
- [ ] 불필요한 debug 로그 없음
- [ ] CLAUDE.md 규칙 준수
