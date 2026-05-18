#!/usr/bin/env bash
# agent-guard — PostToolUse loop / repetition detector.
#
# Tracks the last N=20 Bash commands in a ring buffer at
# .claude/memory/exec-ring.jsonl. If the SAME command (first 200 chars) appears
# ≥ MYTHOS_LOOP_THRESHOLD (default 3) times in the ring, emits:
#   - stderr warning visible to the operator,
#   - JSON `hookSpecificOutput.additionalContext` flagging a probable loop so
#     the model can self-correct.
#
# Never blocks: this is signal, not enforcement. Exit 0 always.
#
# Wiring: PostToolUse matcher "Bash" in .claude/settings.json.
set -uo pipefail

. "${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/hooks/_lib.sh"

RING="$MYTHOS_MEMORY_DIR/exec-ring.jsonl"
WINDOW="${MYTHOS_LOOP_WINDOW:-20}"
THRESHOLD="${MYTHOS_LOOP_THRESHOLD:-3}"
mkdir -p "$(dirname "$RING")"

INPUT="$(mythos_read_stdin)"
[ -z "$INPUT" ] && exit 0

CMD="$(mythos_json_get "$INPUT" '.tool_input.command' | head -c 200)"
TOOL="$(mythos_json_get "$INPUT" '.tool_name')"
[ "$TOOL" != "Bash" ] && exit 0
[ -z "$CMD" ] && exit 0

TS="$(mythos_ts)"

# Append + trim under a single lock. POSIX O_APPEND alone isn't sufficient
# because the trim is read-modify-write — the lock serializes them.
if ! mythos_lock_acquire "agent-guard-ring" 2000; then
  # Lock contention is benign — skip this call's bookkeeping rather than
  # block the user's tool pipeline.
  exit 0
fi
trap 'mythos_lock_release "agent-guard-ring"' EXIT

if mythos_has jq; then
  jq -nc --arg ts "$TS" --arg c "$CMD" '{ts:$ts,cmd:$c}' >> "$RING"
else
  esc_cmd="$(mythos_json_escape "$CMD")"
  printf '{"ts":"%s","cmd":%s}\n' "$TS" "$esc_cmd" >> "$RING"
fi

# Trim ring buffer to last $WINDOW lines using a pid-scoped temp file.
if [ -f "$RING" ]; then
  total=$(wc -l < "$RING" | tr -d ' ')
  if [ "${total:-0}" -gt "$WINDOW" ]; then
    trim_tmp="$RING.tmp.$$.$RANDOM"
    if tail -n "$WINDOW" "$RING" > "$trim_tmp" 2>/dev/null; then
      mv "$trim_tmp" "$RING" 2>/dev/null || rm -f "$trim_tmp" 2>/dev/null || true
    else
      rm -f "$trim_tmp" 2>/dev/null || true
    fi
  fi
fi

# Count repeats of THIS command in the window. Prefer jq for exact match.
if mythos_has jq; then
  REPEATS=$(tail -n "$WINDOW" "$RING" 2>/dev/null \
    | jq -r --arg c "$CMD" 'select(.cmd == $c) | .ts' 2>/dev/null \
    | wc -l | tr -d ' ')
else
  # Fallback without jq: extract the `cmd` field per line via sed and do
  # exact equality, not substring match (avoids `ls` falsely matching `ls -la`).
  REPEATS=$(tail -n "$WINDOW" "$RING" 2>/dev/null \
    | sed -n 's/.*"cmd":"\(.*\)"}$/\1/p' \
    | awk -v c="$CMD" 'BEGIN{n=0} { if ($0 == c) n++ } END{ print n }')
  REPEATS=${REPEATS:-0}
fi
REPEATS=${REPEATS:-0}

mythos_lock_release "agent-guard-ring"
trap - EXIT

if [ "${REPEATS:-0}" -ge "$THRESHOLD" ] 2>/dev/null; then
  msg="agent-guard: same Bash command ran ${REPEATS}× in last ${WINDOW} — probable loop. cmd=\"$CMD\""
  printf '⚠️  %s\n' "$msg" >&2
  mythos_log_event "loop_detected" \
    "{\"cmd\":$(mythos_json_escape "$CMD"),\"repeats\":${REPEATS},\"window\":${WINDOW}}"
  # Emit hookSpecificOutput so the model sees it next turn.
  if mythos_has jq; then
    jq -nc --arg t "[AGENT-GUARD] $msg — break the loop: change the command, inspect output, or stop and re-plan." \
      '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:$t}}'
  else
    esc=$(mythos_json_escape "[AGENT-GUARD] $msg — break the loop: change the command, inspect output, or stop and re-plan.")
    printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s}}\n' "$esc"
  fi
fi

exit 0
