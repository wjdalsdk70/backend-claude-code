#!/usr/bin/env bash
# backend-claude-code 제거 스크립트 — .installed-files 목록에 기록된 파일만 삭제한다
set -euo pipefail

TARGET="${1:-$(pwd)}"
TRACKING_FILE="$TARGET/.claude/.installed-files"

echo "backend-claude-code 제거 위치: $TARGET"

if [ ! -f "$TRACKING_FILE" ]; then
  echo "Error: 트래킹 파일을 찾을 수 없습니다: $TRACKING_FILE"
  echo "install.sh로 설치된 프로젝트가 아니거나 이미 제거됐습니다."
  exit 1
fi

removed=0
skipped=0

while IFS= read -r file; do
  [ -z "$file" ] && continue
  if [ -f "$file" ]; then
    rm "$file"
    echo "  삭제: $file"
    ((removed++)) || true
    # 빈 디렉토리가 됐으면 함께 제거
    dir=$(dirname "$file")
    rmdir "$dir" 2>/dev/null || true
  else
    echo "  스킵 (없음): $file"
    ((skipped++)) || true
  fi
done < "$TRACKING_FILE"

# 트래킹 파일 자체도 삭제
rm "$TRACKING_FILE"
echo "  삭제: $TRACKING_FILE"

# .claude/ 가 비었으면 제거
rmdir "$TARGET/.claude/rules/common" 2>/dev/null || true
rmdir "$TARGET/.claude/rules/java" 2>/dev/null || true
rmdir "$TARGET/.claude/rules" 2>/dev/null || true
rmdir "$TARGET/.claude/agents" 2>/dev/null || true
rmdir "$TARGET/.claude/commands" 2>/dev/null || true
rmdir "$TARGET/.claude/skills" 2>/dev/null || true
rmdir "$TARGET/.claude" 2>/dev/null || true

echo ""
echo "제거 완료. 삭제 $removed 개 / 스킵 $skipped 개"
echo "프로젝트에서 직접 만든 파일은 그대로 유지됩니다."
