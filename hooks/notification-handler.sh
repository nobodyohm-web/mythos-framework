#!/bin/bash
# Hook: notification-handler — React to Claude Code Notification events.
# Triggered: Notification (e.g. permission needed, idle for >60s, awaiting input)
# Behavior: log + (optionally) emit a macOS desktop notification via osascript.

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
LOG_DIR="$PROJECT_DIR/.claude/memory"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/notifications.log"

INPUT="$(cat 2>/dev/null || true)"

MSG=$(echo "$INPUT" | sed -n 's/.*"message"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
[ -z "$MSG" ] && MSG="(no message)"
TITLE=$(echo "$INPUT" | sed -n 's/.*"title"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
[ -z "$TITLE" ] && TITLE="Claude Mythos"

TS=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
echo "$TS | $TITLE | $MSG" >> "$LOG"

# Desktop notification — only on macOS, only if user opted in
if [ "${MYTHOS_DESKTOP_NOTIFY:-0}" = "1" ] && command -v osascript &>/dev/null; then
  # Escape double quotes in MSG/TITLE
  SAFE_MSG=$(echo "$MSG" | sed 's/"/\\"/g')
  SAFE_TITLE=$(echo "$TITLE" | sed 's/"/\\"/g')
  osascript -e "display notification \"$SAFE_MSG\" with title \"$SAFE_TITLE\"" 2>/dev/null || true
fi

# Emit a one-liner so Claude sees the notification surfaced
echo "[NOTIFICATION] $TITLE — $MSG"

exit 0
