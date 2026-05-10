#!/bin/bash
# Hook: EndOfDay — Save state before closing the session
# L3 Guardrail Layer — runs at session end
# Maps to: the-trading-dev-kit/hooks/EndOfDay.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "═══════════════════════════════════════════"
echo "  🌙 END OF DAY — State Save"
echo "  $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "═══════════════════════════════════════════"

cd "$PROJECT_DIR"

# 1. Final typecheck (if applicable)
if [ -f "$PROJECT_DIR/tsconfig.json" ]; then
  echo "🔍 Final typecheck..."
  if command -v bun &>/dev/null && bun run typecheck 2>/dev/null; then
    echo "  ✅ Typecheck: clean"
  elif command -v ~/.bun/bin/bun &>/dev/null && ~/.bun/bin/bun run typecheck 2>/dev/null; then
    echo "  ✅ Typecheck: clean"
  else
    echo "  ⚠️  Typecheck has errors — session ended with issues"
  fi
fi

# 2. Final test run (if tests exist)
TEST_COUNT=$(find "$PROJECT_DIR" -name "*.test.*" 2>/dev/null | grep -v node_modules | wc -l | tr -d ' ')
if [ "$TEST_COUNT" -gt 0 ]; then
  echo "🧪 Final test run..."
  if command -v bun &>/dev/null && bun test 2>/dev/null; then
    echo "  ✅ Tests: all passing"
  elif command -v ~/.bun/bin/bun &>/dev/null && ~/.bun/bin/bun test 2>/dev/null; then
    echo "  ✅ Tests: all passing"
  else
    echo "  ⚠️  Tests have failures — session ended with issues"
  fi
fi

# 3. Git status summary
if [ -d "$PROJECT_DIR/.git" ]; then
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$DIRTY" -gt 0 ]; then
    echo "📝 Uncommitted changes: $DIRTY files"
    git status --porcelain 2>/dev/null | head -10
    if [ "$DIRTY" -gt 10 ]; then
      echo "   ... and $((DIRTY - 10)) more"
    fi
  else
    echo "✅ Working tree clean"
  fi
fi

# 4. Task summary
if [ -f "$PROJECT_DIR/tasks/todo.md" ]; then
  PENDING=$(grep -c "^\- \[ \]" "$PROJECT_DIR/tasks/todo.md" 2>/dev/null || echo "0")
  DONE=$(grep -c "^\- \[x\]" "$PROJECT_DIR/tasks/todo.md" 2>/dev/null || echo "0")
  echo "📋 Tasks: $DONE completed, $PENDING remaining"
fi

# 5. Lessons summary
if [ -f "$PROJECT_DIR/tasks/lessons.md" ]; then
  LESSON_COUNT=$(grep -c "^### " "$PROJECT_DIR/tasks/lessons.md" 2>/dev/null || echo "0")
  echo "📚 Total lessons captured: $LESSON_COUNT"
fi

# 6. Session duration estimate
if [ -f "/tmp/.claude-session-start" ]; then
  START_TS=$(cat /tmp/.claude-session-start 2>/dev/null || echo "0")
  NOW_TS=$(date +%s)
  DURATION=$(( (NOW_TS - START_TS) / 60 ))
  echo "⏱️  Estimated session duration: ${DURATION} minutes"
fi

echo "═══════════════════════════════════════════"
echo "  Session ended: $(date '+%Y-%m-%d %H:%M:%S')"
echo "  State saved. See you tomorrow. 🌙"
echo "═══════════════════════════════════════════"
