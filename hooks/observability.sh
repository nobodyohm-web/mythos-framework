#!/bin/bash
# Hook: observability — Append a structured JSONL event for any hook lifecycle moment.
# Usage: bash hooks/observability.sh <event_name>
#   <event_name>: SessionStart | SessionEnd | UserPromptSubmit | PreToolUse | PostToolUse |
#                 Stop | PreCompact | SubagentStop | Notification
# Reads stdin (the harness's JSON event payload) and folds the most useful fields into a
# single line in .claude/memory/events.jsonl. Always exits 0 — never blocks.

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
LOG_DIR="$PROJECT_DIR/.claude/memory"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/events.jsonl"

EVENT="${1:-unknown}"
TS=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
SID="${CLAUDE_SESSION_ID:-unknown}"

INPUT="$(cat 2>/dev/null || true)"

# Attempt to extract a few common fields without requiring jq
TOOL=$(echo "$INPUT" | sed -n 's/.*"tool_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
SUBAGENT=$(echo "$INPUT" | sed -n 's/.*"subagent_type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
PROMPT_LEN=$(echo "$INPUT" | wc -c | tr -d ' ')
EXIT_CODE=$(echo "$INPUT" | sed -n 's/.*"exit_code"[[:space:]]*:[[:space:]]*\([0-9]*\).*/\1/p' | head -1)

# Build a JSON line manually (escaping minimal — fields above are constrained)
{
  printf '{"ts":"%s","session":"%s","event":"%s"' "$TS" "$SID" "$EVENT"
  [ -n "$TOOL" ]      && printf ',"tool":"%s"' "$TOOL"
  [ -n "$SUBAGENT" ]  && printf ',"subagent":"%s"' "$SUBAGENT"
  [ -n "$EXIT_CODE" ] && printf ',"exit_code":%s' "$EXIT_CODE"
  printf ',"payload_bytes":%s}\n' "$PROMPT_LEN"
} >> "$LOG"

# Rotate when the file exceeds 5 MB so we never balloon disk
if [ -f "$LOG" ]; then
  SIZE=$(stat -f%z "$LOG" 2>/dev/null || stat -c%s "$LOG" 2>/dev/null || echo 0)
  if [ "${SIZE:-0}" -gt 5242880 ]; then
    mv "$LOG" "$LOG.$(date '+%Y%m%d-%H%M%S')"
    # Keep at most 3 rotated archives
    ls -t "$LOG".* 2>/dev/null | tail -n +4 | xargs rm -f 2>/dev/null || true
  fi
fi

exit 0
