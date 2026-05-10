#!/bin/bash
# Hook: auto-learn — Auto-learning post-session hook
# Extracts session metrics and feeds the evolution system
# Triggered by SessionEnd in .claude/settings.json

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "── 🧠 Mythos Auto-Learn ──"

# 1. Count session metrics
LESSONS=$(grep -c "^### " "$PROJECT_DIR/tasks/lessons.md" 2>/dev/null || echo "0")
CONFIDENCE_ENTRIES=$(grep -c "^\*\*Confidence:\*\*" "$PROJECT_DIR/tasks/confidence-log.md" 2>/dev/null || echo "0")
JOURNAL_ENTRIES=$(grep -c "^## Session" "$PROJECT_DIR/tasks/session-journal.md" 2>/dev/null || echo "0")
PENDING_TASKS=$(grep -c "^\- \[ \]" "$PROJECT_DIR/tasks/todo.md" 2>/dev/null || echo "0")
DONE_TASKS=$(grep -c "^\- \[x\]" "$PROJECT_DIR/tasks/todo.md" 2>/dev/null || echo "0")

echo "  📚 Total lessons: $LESSONS"
echo "  📊 Confidence entries: $CONFIDENCE_ENTRIES"
echo "  📓 Journal entries: $JOURNAL_ENTRIES"
echo "  📋 Tasks: $DONE_TASKS done, $PENDING_TASKS pending"

# 2. Update patterns.json with session count
if [ -f "$PROJECT_DIR/.claude/memory/patterns.json" ]; then
  # Update sessionsCompleted (simple sed since jq may not be available)
  CURRENT_SESSIONS=$(grep -o '"sessionsCompleted": [0-9]*' "$PROJECT_DIR/.claude/memory/patterns.json" | grep -o '[0-9]*')
  NEW_SESSIONS=$((CURRENT_SESSIONS + 1))
  sed -i '' "s/\"sessionsCompleted\": $CURRENT_SESSIONS/\"sessionsCompleted\": $NEW_SESSIONS/" "$PROJECT_DIR/.claude/memory/patterns.json" 2>/dev/null || true
  echo "  🔄 Sessions completed: $NEW_SESSIONS"
fi

# 3. Check if evolution is recommended
if [ "$LESSONS" -gt 5 ] && [ "$CONFIDENCE_ENTRIES" -gt 0 ]; then
  echo "  💡 Recommendation: Run /evolve to optimize based on accumulated lessons"
fi

echo "── 🧠 Auto-Learn complete ──"
