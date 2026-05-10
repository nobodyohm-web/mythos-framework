#!/usr/bin/env bash
# Hook: self-eval — at SessionEnd, score the session and append metrics.
# Triggered: SessionEnd (chained after auto-learn + session-state save)
# Scores: lessons added, errors logged, confidence variance, hook-block count.
# Output: appends one JSON line to .claude/memory/eval-metrics.jsonl.
# Never blocks; exit 0 always (failure to score is not failure to end the session).

set -uo pipefail

. "${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/hooks/_lib.sh"

P="$MYTHOS_PROJECT_DIR"
METRICS="$P/.claude/memory/eval-metrics.jsonl"
mkdir -p "$(dirname "$METRICS")"

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Helper: return a single integer count, never empty.
_count() { local v; v="$(printf '%s' "$1" | tr -dc '0-9')"; printf '%s' "${v:-0}"; }

# How many lessons captured *today*?
LESSONS_TODAY=0
if [ -f "$P/tasks/lessons.md" ]; then
  TODAY="$(date +%Y-%m-%d)"
  LESSONS_TODAY="$(_count "$(grep -c "^### $TODAY " "$P/tasks/lessons.md" 2>/dev/null)")"
fi

# How many errors recovered this session?
ERRORS_RECOVERED=0
if [ -f "$P/.claude/memory/error-recovery.log" ]; then
  ERRORS_RECOVERED="$(_count "$(wc -l < "$P/.claude/memory/error-recovery.log" 2>/dev/null)")"
fi

# How many guard blocks fired?
GUARD_BLOCKS=0
if [ -f "$P/.claude/memory/events.jsonl" ]; then
  GUARD_BLOCKS="$(_count "$(grep -c '"event":"GuardBlocked"' "$P/.claude/memory/events.jsonl" 2>/dev/null)")"
fi

# Average confidence from last 10 entries (if any have a numeric score)
AVG_CONF="null"
if [ -f "$P/tasks/confidence-log.md" ]; then
  AVG_CONF="$(grep -oE 'Confidence:[[:space:]]*[0-9]+' "$P/tasks/confidence-log.md" 2>/dev/null \
    | tail -10 | grep -oE '[0-9]+' \
    | awk '{s+=$1; n+=1} END {if (n>0) print s/n; else print "null"}')"
  [ -z "$AVG_CONF" ] && AVG_CONF="null"
fi

# Hook self-test status (cheap: just check the file/JSON validity, do NOT re-run)
SELF_TEST="unknown"
if [ -f "$P/hooks/test-mythos.sh" ] && [ -x "$P/hooks/test-mythos.sh" ]; then
  SELF_TEST="present"
fi

# Compose JSON metric row. Use jq if available, fallback to printf.
ROW=""
if command -v jq &>/dev/null; then
  ROW="$(jq -nc \
    --arg ts "$NOW" \
    --arg ver "${MYTHOS_VERSION:-unknown}" \
    --argjson lessons "${LESSONS_TODAY:-0}" \
    --argjson errs "${ERRORS_RECOVERED:-0}" \
    --argjson blocks "${GUARD_BLOCKS:-0}" \
    --arg conf "$AVG_CONF" \
    --arg test "$SELF_TEST" \
    '{ts:$ts, mode:"session-end", version:$ver,
      lessons_today:$lessons, errors_recovered:$errs, guard_blocks:$blocks,
      avg_confidence: ($conf | if . == "null" then null else tonumber end),
      self_test:$test}')"
else
  ROW="{\"ts\":\"$NOW\",\"mode\":\"session-end\",\"version\":\"${MYTHOS_VERSION:-unknown}\",\"lessons_today\":${LESSONS_TODAY:-0},\"errors_recovered\":${ERRORS_RECOVERED:-0},\"guard_blocks\":${GUARD_BLOCKS:-0},\"avg_confidence\":${AVG_CONF},\"self_test\":\"$SELF_TEST\"}"
fi

printf '%s\n' "$ROW" >> "$METRICS"
exit 0
