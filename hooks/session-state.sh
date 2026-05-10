#!/bin/bash
# Hook: session-state — Persist resumable state across sessions
# Modes:
#   save    — write current state snapshot (called from SessionEnd)
#   restore — print last snapshot for Claude to read (called from SessionStart)
#   show    — human-readable display of last snapshot

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
STATE_DIR="$PROJECT_DIR/.claude/memory"
mkdir -p "$STATE_DIR"
SNAPSHOT="$STATE_DIR/last-session-state.json"

MODE="${1:-show}"

save_state() {
  local BRANCH="(no-git)"
  local DIRTY=0
  local LAST_COMMIT="(no-git)"
  if [ -d "$PROJECT_DIR/.git" ]; then
    cd "$PROJECT_DIR"
    BRANCH=$(git branch --show-current 2>/dev/null || echo "(detached)")
    DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    LAST_COMMIT=$(git log -1 --pretty=format:'%h %s' 2>/dev/null || echo "(none)")
  fi

  local PENDING=0; local DONE_COUNT=0
  if [ -f "$PROJECT_DIR/tasks/todo.md" ]; then
    PENDING=$(grep -c '^\- \[ \]' "$PROJECT_DIR/tasks/todo.md" 2>/dev/null || echo "0")
    DONE_COUNT=$(grep -c '^\- \[x\]' "$PROJECT_DIR/tasks/todo.md" 2>/dev/null || echo "0")
  fi

  local LESSONS=0
  [ -f "$PROJECT_DIR/tasks/lessons.md" ] && LESSONS=$(grep -c '^### ' "$PROJECT_DIR/tasks/lessons.md" 2>/dev/null || echo "0")

  cat > "$SNAPSHOT" <<EOF
{
  "saved_at": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "branch": "$BRANCH",
  "uncommitted_files": $DIRTY,
  "last_commit": "$LAST_COMMIT",
  "tasks_pending": $PENDING,
  "tasks_done": $DONE_COUNT,
  "lessons_count": $LESSONS,
  "session_id": "${CLAUDE_SESSION_ID:-unknown}"
}
EOF
  echo "[SESSION-STATE] saved: $SNAPSHOT"
}

restore_state() {
  if [ -f "$SNAPSHOT" ]; then
    echo "[SESSION-STATE] previous session snapshot:"
    cat "$SNAPSHOT"
  else
    echo "[SESSION-STATE] no previous snapshot (first session)"
  fi
}

show_state() { restore_state; }

case "$MODE" in
  save) save_state ;;
  restore) restore_state ;;
  show|*) show_state ;;
esac

exit 0
