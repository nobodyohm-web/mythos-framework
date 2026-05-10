#!/bin/bash
# Hook: context-guardian — Track session size and warn before context exhaustion
# Triggered: PostToolUse (every tool call)
# Behavior: counts cumulative tool calls / approximate tokens; emits a one-line warning
#           when thresholds are crossed. Non-blocking.
#
# Wiring (in .claude/settings.json):
#   "PostToolUse": [{ "matcher": "*", "hooks": [{ "type": "command",
#     "command": "bash \"${CLAUDE_PROJECT_DIR:-.}/hooks/context-guardian.sh\"",
#     "timeout": 2000 }]}]

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
STATE_DIR="$PROJECT_DIR/.claude/memory"
mkdir -p "$STATE_DIR"
COUNTER="$STATE_DIR/.context-guardian-count"
SESSION_ID="${CLAUDE_SESSION_ID:-default}"
SESSION_FILE="$COUNTER.$SESSION_ID"

# Increment per-session tool-call counter
COUNT=0
[ -f "$SESSION_FILE" ] && COUNT=$(cat "$SESSION_FILE" 2>/dev/null || echo "0")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$SESSION_FILE"

# Thresholds (tool calls — rough proxy for context fill)
WARN_AT=75
HARD_AT=150
COMPACT_AT=200

case "$COUNT" in
  $WARN_AT)
    echo "[CONTEXT-GUARDIAN] ⚠️  $COUNT tool calls — context filling. Consider /clear between unrelated tasks."
    ;;
  $HARD_AT)
    echo "[CONTEXT-GUARDIAN] 🟠 $COUNT tool calls — performance may degrade. Recommend /compact now."
    ;;
  $COMPACT_AT)
    echo "[CONTEXT-GUARDIAN] 🔴 $COUNT tool calls — context near limit. Run /compact or /clear immediately."
    ;;
esac

# Also track per-day tool calls for ops insight
DAY=$(date '+%Y-%m-%d')
DAILY="$STATE_DIR/.context-guardian-daily-$DAY"
DCOUNT=0
[ -f "$DAILY" ] && DCOUNT=$(cat "$DAILY" 2>/dev/null || echo "0")
DCOUNT=$((DCOUNT + 1))
echo "$DCOUNT" > "$DAILY"

# Cleanup old daily counters (>14 days)
find "$STATE_DIR" -name '.context-guardian-daily-*' -mtime +14 -delete 2>/dev/null || true

exit 0
