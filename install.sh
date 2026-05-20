#!/usr/bin/env bash
# backend-claude-code 설치/업데이트 스크립트 — Java/Spring Boot 프로젝트에 Claude Code 설정을 복사한다
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$(pwd)}"

if [ ! -d "$TARGET" ]; then
  echo "Error: 대상 디렉토리가 존재하지 않습니다: $TARGET"
  exit 1
fi

echo "backend-claude-code → $TARGET"
mkdir -p "$TARGET/.claude"/{rules,agents,commands,skills}

TRACKING_FILE="$TARGET/.claude/.installed-files"
IGNORE_FILE="$TARGET/.claude/.claude-ignore"
touch "$TRACKING_FILE"

# --- .claude-ignore 파싱 (주석·빈 줄 제외) ---
IGNORED=()
if [ -f "$IGNORE_FILE" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    [[ "$line" =~ ^[[:space:]]*# || -z "${line// }" ]] && continue
    IGNORED+=("$line")
  done < "$IGNORE_FILE"
fi

_is_ignored() {
  local rel="$1"
  for p in "${IGNORED[@]+"${IGNORED[@]}"}"; do
    [[ "$rel" == "$p" ]] && return 0
  done
  return 1
}

# rel: .claude/ 기준 상대경로 (예: rules/foo.md, agents/bar.md)
_sync() {
  local src="$1" dest="$2" rel="$3"
  if _is_ignored "$rel"; then
    echo "  skip (ignored): $rel"
    return
  fi
  cp "$src" "$dest"
  grep -qxF "$dest" "$TRACKING_FILE" 2>/dev/null || echo "$dest" >> "$TRACKING_FILE"
  echo "  sync: $rel"
}

# 소스에서 제거된 파일을 대상 프로젝트에서도 삭제
_cleanup() {
  [ -f "$TRACKING_FILE" ] || return
  local tmp; tmp=$(mktemp)

  while IFS= read -r dest || [ -n "$dest" ]; do
    [ -z "$dest" ] && continue
    [ "$dest" = "$TRACKING_FILE" ] && continue

    local rel src
    case "$dest" in
      "$TARGET/.claude/settings.json") rel="settings.json";  src="$SCRIPT_DIR/.claude/settings.json" ;;
      "$TARGET/.claude/"*)             rel="${dest#"$TARGET/.claude/"}"; src="$SCRIPT_DIR/$rel" ;;
      "$TARGET/CLAUDE.md")             rel="CLAUDE.md";       src="$SCRIPT_DIR/CLAUDE.md" ;;
      "$TARGET/.mcp.json")             rel=".mcp.json";       src="$SCRIPT_DIR/.mcp.json" ;;
      *) echo "$dest" >> "$tmp"; continue ;;
    esac

    if [ -f "$src" ]; then
      echo "$dest" >> "$tmp"
    elif _is_ignored "$rel"; then
      echo "  keep (ignored, source removed): $rel"
      echo "$dest" >> "$tmp"
    else
      rm -f "$dest"
      echo "  remove: $rel"
    fi
  done < "$TRACKING_FILE"

  mv "$tmp" "$TRACKING_FILE"
}

# --- 소스에서 제거된 파일 정리 ---
echo "정리 중..."
_cleanup

# --- 동기화 ---
echo "동기화 중..."

for src in "$SCRIPT_DIR/rules/"*.md; do
  [ -f "$src" ] || continue
  fname=$(basename "$src")
  _sync "$src" "$TARGET/.claude/rules/$fname" "rules/$fname"
done

for src in "$SCRIPT_DIR/agents/"*.md; do
  [ -f "$src" ] || continue
  fname=$(basename "$src")
  _sync "$src" "$TARGET/.claude/agents/$fname" "agents/$fname"
done

for src in "$SCRIPT_DIR/commands/"*.md; do
  [ -f "$src" ] || continue
  fname=$(basename "$src")
  _sync "$src" "$TARGET/.claude/commands/$fname" "commands/$fname"
done

for skill_dir in "$SCRIPT_DIR/skills"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  mkdir -p "$TARGET/.claude/skills/$skill_name"
  _sync "$skill_dir/SKILL.md" "$TARGET/.claude/skills/$skill_name/SKILL.md" "skills/$skill_name/SKILL.md"
done

_sync "$SCRIPT_DIR/.claude/settings.json" "$TARGET/.claude/settings.json" "settings.json"
_sync "$SCRIPT_DIR/.mcp.json" "$TARGET/.mcp.json" ".mcp.json"
_sync "$SCRIPT_DIR/CLAUDE.md" "$TARGET/CLAUDE.md" "CLAUDE.md"

# GitHub 템플릿은 항상 덮어쓰기 (프로젝트별 커스텀 가능성 낮음)
mkdir -p "$TARGET/.github/ISSUE_TEMPLATE"
[ -f "$SCRIPT_DIR/.github/PULL_REQUEST_TEMPLATE.md" ] && \
  cp "$SCRIPT_DIR/.github/PULL_REQUEST_TEMPLATE.md" "$TARGET/.github/PULL_REQUEST_TEMPLATE.md"
for tmpl in "$SCRIPT_DIR/.github/ISSUE_TEMPLATE/"*.md; do
  [ -f "$tmpl" ] || continue
  cp "$tmpl" "$TARGET/.github/ISSUE_TEMPLATE/$(basename "$tmpl")"
done

echo ""
echo "완료!"
echo ""
echo "업데이트에서 제외할 파일이 있으면:"
echo "  $TARGET/.claude/.claude-ignore  에 추가하세요"
echo ""
echo "예시:"
echo "  rules/repository-patterns.md"
echo "  agents/code-reviewer.md"
