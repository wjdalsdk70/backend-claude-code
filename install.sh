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
mkdir -p "$TARGET/.claude"/{rules/java,agents,commands,skills}

TRACKING_FILE="$TARGET/.claude/.installed-files"
# 트래킹 파일 초기화 (누적 — 재설치 시 새 파일만 추가)
touch "$TRACKING_FILE"

# 복사 후 트래킹 파일에 경로를 기록하는 헬퍼
_copy_if_absent() {
  local src="$1" dest="$2" label="$3"
  if [ -f "$dest" ]; then
    echo "    $label 이미 존재합니다. 스킵합니다."
  else
    cp "$src" "$dest"
    echo "$dest" >> "$TRACKING_FILE"
    echo "    $label 복사 완료"
  fi
}

# rules 복사 (Java)
echo "  rules 복사..."
for rule_dir in java; do
  for src in "$SCRIPT_DIR/rules/$rule_dir/"*.md; do
    [ -f "$src" ] || continue
    fname=$(basename "$src")
    _copy_if_absent "$src" "$TARGET/.claude/rules/$rule_dir/$fname" "rules/$rule_dir/$fname"
  done
done

# agents 복사
echo "  agents 복사..."
for src in "$SCRIPT_DIR/agents/"*.md; do
  fname=$(basename "$src")
  _copy_if_absent "$src" "$TARGET/.claude/agents/$fname" "agents/$fname"
done

# commands 복사
echo "  commands 복사..."
for src in "$SCRIPT_DIR/commands/"*.md; do
  fname=$(basename "$src")
  _copy_if_absent "$src" "$TARGET/.claude/commands/$fname" "commands/$fname"
done

# skills 복사
echo "  skills 복사..."
for skill_dir in "$SCRIPT_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p "$TARGET/.claude/skills/$skill_name"
  _copy_if_absent "$skill_dir/SKILL.md" "$TARGET/.claude/skills/$skill_name/SKILL.md" "skills/$skill_name/SKILL.md"
done

# settings.json 복사
_copy_if_absent "$SCRIPT_DIR/.claude/settings.json" "$TARGET/.claude/settings.json" ".claude/settings.json"
if grep -qx "$TARGET/.claude/settings.json" "$TRACKING_FILE" 2>/dev/null; then
  : # 방금 복사됨
else
  echo "  .claude/settings.json — 수동으로 병합하세요: $SCRIPT_DIR/.claude/settings.json"
fi

# .mcp.json 복사
_copy_if_absent "$SCRIPT_DIR/.mcp.json" "$TARGET/.mcp.json" ".mcp.json"
if grep -qx "$TARGET/.mcp.json" "$TRACKING_FILE" 2>/dev/null; then
  :
else
  echo "  .mcp.json — 수동으로 병합하세요: $SCRIPT_DIR/.mcp.json"
fi

# CLAUDE.md 생성
_copy_if_absent "$SCRIPT_DIR/CLAUDE.md" "$TARGET/CLAUDE.md" "CLAUDE.md"

# GitHub PR 템플릿 복사
mkdir -p "$TARGET/.github"
_copy_if_absent "$SCRIPT_DIR/.github/PULL_REQUEST_TEMPLATE.md" "$TARGET/.github/PULL_REQUEST_TEMPLATE.md" ".github/PULL_REQUEST_TEMPLATE.md"

# GitHub 이슈 템플릿 복사
echo "  이슈 템플릿 복사..."
mkdir -p "$TARGET/.github/ISSUE_TEMPLATE"
for tmpl in "$SCRIPT_DIR/.github/ISSUE_TEMPLATE/"*.md; do
  [ -f "$tmpl" ] || continue
  fname=$(basename "$tmpl")
  _copy_if_absent "$tmpl" "$TARGET/.github/ISSUE_TEMPLATE/$fname" ".github/ISSUE_TEMPLATE/$fname"
done

echo "$TRACKING_FILE" >> "$TRACKING_FILE"

echo ""
echo "설치 완료!"
echo ""
echo "다음 단계:"
echo "  1. $TARGET/CLAUDE.md 를 프로젝트에 맞게 수정하세요"
echo "  2. $TARGET/.mcp.json 에서 GITHUB_TOKEN 환경변수를 설정하세요"
echo "  3. Claude Code에서 /verify, /java-review, /java-test, /java-build 커맨드를 사용하세요"
