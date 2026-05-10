#!/usr/bin/env bash
# Hook: execution-monitor — track command duration and warn on stuck patterns.
# Triggered: PostToolUse (Bash matcher).
# Reads:    JSON payload with tool_input.command and (if harness provides) duration_ms.
# Writes:   .claude/memory/exec-metrics.jsonl (one row per long-running command).
# Side-effect: if duration_ms > 300000 (5min), prints a warning to stderr.
# Never blocks (always exit 0); the harness already has the result.

set -uo pipefail

. "${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/hooks/_lib.sh"

P="$MYTHOS_PROJECT_DIR"
METRICS="$P/.claude/memory/exec-metrics.jsonl"
mkdir -p "$(dirname "$METRICS")"

INPUT="$(cat 2>/dev/null || true)"
[ -z "$INPUT" ] && exit 0

# Extract command and duration_ms (if the harness includes it).
CMD="$(echo "$INPUT" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -c 200)"
DUR="$(echo "$INPUT" | sed -n 's/.*"duration_ms"[[:space:]]*:[[:space:]]*\([0-9]*\).*/\1/p' | head -1)"

# Only record durations we actually got (harness-dependent).
[ -z "${DUR:-}" ] && exit 0
[ -z "${CMD:-}" ] && exit 0

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Record if >5s (the boring stuff is noise).
if [ "$DUR" -gt 5000 ] 2>/dev/null; then
  if command -v jq &>/dev/null; then
    jq -nc --arg ts "$NOW" --arg c "$CMD" --argjson d "$DUR" \
      '{ts:$ts, cmd:$c, duration_ms:$d}' >> "$METRICS"
  else
    printf '{"ts":"%s","cmd":"%s","duration_ms":%s}\n' "$NOW" "$CMD" "$DUR" >> "$METRICS"
  fi
fi

# Warn on stuck patterns (>5min).
if [ "$DUR" -gt 300000 ] 2>/dev/null; then
  printf '⚠️  EXEC-MONITOR: command ran %sms (>5min): %s — consider timeout/break-up\n' "$DUR" "$CMD" >&2
fi

exit 0
