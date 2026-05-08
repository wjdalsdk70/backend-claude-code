#!/usr/bin/env bash
# backend-claude-code 설치 스크립트 — Java/Spring Boot 프로젝트에 Claude Code 설정을 복사한다
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$(pwd)}"

echo "backend-claude-code 설치 위치: $TARGET"

if [ ! -d "$TARGET" ]; then
  echo "Error: 대상 디렉토리가 존재하지 않습니다: $TARGET"
  exit 1
fi

# .claude 하위 디렉토리 생성
mkdir -p "$TARGET/.claude"/{rules/common,rules/java,agents,commands,skills}

# rules 복사 (공통 + Java)
echo "  rules 복사..."
cp -r "$SCRIPT_DIR/rules/common/." "$TARGET/.claude/rules/common/"
cp -r "$SCRIPT_DIR/rules/java/." "$TARGET/.claude/rules/java/"

# agents 복사
echo "  agents 복사..."
cp "$SCRIPT_DIR/agents/"*.md "$TARGET/.claude/agents/"

# commands 복사
echo "  commands 복사..."
cp "$SCRIPT_DIR/commands/"*.md "$TARGET/.claude/commands/"

# skills 복사
echo "  skills 복사..."
for skill_dir in "$SCRIPT_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p "$TARGET/.claude/skills/$skill_name"
  cp "$skill_dir/SKILL.md" "$TARGET/.claude/skills/$skill_name/"
done

# settings.json 복사 (기존 파일이 있으면 병합 필요하다고 안내)
if [ -f "$TARGET/.claude/settings.json" ]; then
  echo "  .claude/settings.json 이미 존재합니다."
  echo "  $SCRIPT_DIR/.claude/settings.json 의 내용을 수동으로 병합하세요."
else
  cp "$SCRIPT_DIR/.claude/settings.json" "$TARGET/.claude/settings.json"
  echo "  .claude/settings.json 복사 완료"
fi

# .mcp.json 복사 (기존 파일 있으면 안내)
if [ -f "$TARGET/.mcp.json" ]; then
  echo "  .mcp.json 이미 존재합니다."
  echo "  $SCRIPT_DIR/.mcp.json 의 내용을 수동으로 병합하세요."
else
  cp "$SCRIPT_DIR/.mcp.json" "$TARGET/.mcp.json"
  echo "  .mcp.json 복사 완료"
fi

# CLAUDE.md 생성 (기존 파일 있으면 스킵)
if [ -f "$TARGET/CLAUDE.md" ]; then
  echo "  CLAUDE.md 이미 존재합니다. 스킵합니다."
else
  cp "$SCRIPT_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "  CLAUDE.md 생성 완료 — 프로젝트에 맞게 커스터마이징하세요"
fi

# Dockerfile 복사 (기존 파일 있으면 스킵)
if [ -f "$TARGET/Dockerfile" ]; then
  echo "  Dockerfile 이미 존재합니다. 스킵합니다."
else
  cp "$SCRIPT_DIR/Dockerfile" "$TARGET/Dockerfile"
  echo "  Dockerfile 복사 완료 — JAVA_VERSION, APP_PORT를 프로젝트에 맞게 수정하세요"
fi

# GitHub Actions CI 워크플로우 복사 (기존 파일 있으면 스킵)
if [ -f "$TARGET/.github/workflows/ci.yml" ]; then
  echo "  .github/workflows/ci.yml 이미 존재합니다. 스킵합니다."
else
  mkdir -p "$TARGET/.github/workflows"
  cp "$SCRIPT_DIR/.github/workflows/ci.yml" "$TARGET/.github/workflows/ci.yml"
  echo "  .github/workflows/ci.yml 복사 완료 — secrets 설정 및 TODO 항목을 확인하세요"
fi

# GitHub PR 템플릿 복사 (기존 파일 있으면 스킵)
if [ -f "$TARGET/.github/PULL_REQUEST_TEMPLATE.md" ]; then
  echo "  .github/PULL_REQUEST_TEMPLATE.md 이미 존재합니다. 스킵합니다."
else
  mkdir -p "$TARGET/.github"
  cp "$SCRIPT_DIR/.github/PULL_REQUEST_TEMPLATE.md" "$TARGET/.github/PULL_REQUEST_TEMPLATE.md"
  echo "  .github/PULL_REQUEST_TEMPLATE.md 복사 완료"
fi

# GitHub 이슈 템플릿 복사
echo "  이슈 템플릿 복사..."
mkdir -p "$TARGET/.github/ISSUE_TEMPLATE"
for tmpl in "$SCRIPT_DIR/.github/ISSUE_TEMPLATE/"*.md; do
  fname=$(basename "$tmpl")
  if [ -f "$TARGET/.github/ISSUE_TEMPLATE/$fname" ]; then
    echo "    $fname 이미 존재합니다. 스킵합니다."
  else
    cp "$tmpl" "$TARGET/.github/ISSUE_TEMPLATE/$fname"
    echo "    $fname 복사 완료"
  fi
done

echo ""
echo "설치 완료!"
echo ""
echo "다음 단계:"
echo "  1. $TARGET/CLAUDE.md 를 프로젝트에 맞게 수정하세요"
echo "  2. $TARGET/.mcp.json 에서 GITHUB_TOKEN 환경변수를 설정하세요"
echo "  3. $TARGET/Dockerfile 에서 JAVA_VERSION, 포트를 확인하세요"
echo "  4. $TARGET/.github/workflows/ci.yml 에서 TODO 항목을 수정하세요"
echo "  5. Claude Code에서 /verify, /java-review, /java-test, /java-build 커맨드를 사용하세요"
