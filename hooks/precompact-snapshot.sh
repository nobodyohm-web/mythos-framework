#!/bin/bash
# Hook: precompact-snapshot — Capture a brief state snapshot before context compaction.
# Triggered: PreCompact
# Why: /compact loses transient state. We persist enough to resume after compaction.

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
SNAP_DIR="$PROJECT_DIR/.claude/memory"
mkdir -p "$SNAP_DIR"
SNAP="$SNAP_DIR/precompact-snapshot.md"

TS=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

BRANCH="(no-git)"
DIRTY=0
RECENT_COMMITS="(no-git)"
if [ -d "$PROJECT_DIR/.git" ]; then
  cd "$PROJECT_DIR"
  BRANCH=$(git branch --show-current 2>/dev/null || echo "(detached)")
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  RECENT_COMMITS=$(git log -3 --pretty=format:'  - %h %s' 2>/dev/null || echo "  - (none)")
fi

PENDING=0; DONE_C=0
if [ -f "$PROJECT_DIR/tasks/todo.md" ]; then
  PENDING=$(grep -c '^\- \[ \]' "$PROJECT_DIR/tasks/todo.md" 2>/dev/null || true)
  DONE_C=$(grep -c '^\- \[x\]' "$PROJECT_DIR/tasks/todo.md" 2>/dev/null || true)
fi

LAST_LESSON=$(grep '^### ' "$PROJECT_DIR/tasks/lessons.md" 2>/dev/null | tail -1)

cat > "$SNAP" <<EOF
# Pre-Compact Snapshot
> Saved $TS — read this if you wake up after a /compact.

## Git
- Branch: $BRANCH
- Uncommitted: $DIRTY files
- Recent commits:
$RECENT_COMMITS

## Tasks
- Pending: $PENDING
- Done: $DONE_C

## Last lesson
$LAST_LESSON

## Resume hints
- Re-read \`tasks/todo.md\` for the active task.
- Re-read \`tasks/lessons.md\` (top of file) for hard rules.
- If the user's last prompt is unclear, ask them to restate it.
EOF

echo "[PRECOMPACT] snapshot saved: $SNAP"
exit 0
