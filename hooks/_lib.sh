#!/usr/bin/env bash
# Mythos hook shared library — common helpers for every hook.
# Source via: . "${CLAUDE_PROJECT_DIR:-.}/hooks/_lib.sh"
# All helpers are idempotent and side-effect-free unless explicitly noted.

set -u  # NOT -e: hooks must never abort mid-pipeline; we handle errors explicitly.

MYTHOS_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
MYTHOS_MEMORY_DIR="${MYTHOS_PROJECT_DIR}/.claude/memory"
MYTHOS_TASKS_DIR="${MYTHOS_PROJECT_DIR}/tasks"
MYTHOS_HOOKS_DIR="${MYTHOS_PROJECT_DIR}/hooks"
MYTHOS_EVENTS_LOG="${MYTHOS_MEMORY_DIR}/events.jsonl"
MYTHOS_ERROR_LOG="${MYTHOS_MEMORY_DIR}/error-recovery.log"
MYTHOS_NOTIF_LOG="${MYTHOS_MEMORY_DIR}/notifications.log"
MYTHOS_SUBAGENT_LOG="${MYTHOS_MEMORY_DIR}/subagents.log"
MYTHOS_STATE_FILE="${MYTHOS_MEMORY_DIR}/last-session-state.json"
MYTHOS_SNAPSHOT_FILE="${MYTHOS_MEMORY_DIR}/precompact-snapshot.md"

mkdir -p "$MYTHOS_MEMORY_DIR" "$MYTHOS_TASKS_DIR" 2>/dev/null || true

# ISO-8601 UTC timestamp.
mythos_ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

# Detect tool availability.
mythos_has() { command -v "$1" >/dev/null 2>&1; }

# JSON-string escape (newlines, quotes, backslashes, control chars).
mythos_json_escape() {
  if mythos_has jq; then
    jq -Rs . <<<"$1"
  else
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '"%s"' "$s"
  fi
}

# Append a JSONL event with size-rotation at 5MB.
# Usage: mythos_log_event "<event_name>" "<json_payload_object>"
mythos_log_event() {
  local event="$1"; shift
  local payload="${1:-{\}}"
  local ts; ts="$(mythos_ts)"
  mkdir -p "$MYTHOS_MEMORY_DIR" 2>/dev/null || return 0
  if [ -f "$MYTHOS_EVENTS_LOG" ]; then
    local size
    size=$(wc -c <"$MYTHOS_EVENTS_LOG" 2>/dev/null | tr -d ' ')
    if [ -n "$size" ] && [ "$size" -gt 5242880 ]; then
      mv "$MYTHOS_EVENTS_LOG" "${MYTHOS_EVENTS_LOG}.1" 2>/dev/null || true
    fi
  fi
  printf '{"ts":"%s","event":"%s","payload":%s}\n' "$ts" "$event" "$payload" \
    >> "$MYTHOS_EVENTS_LOG" 2>/dev/null || true
}

# Read a field out of a JSON stdin payload (uses jq if present, else grep+sed).
# Usage: mythos_json_get "<json>" ".path.to.field"
mythos_json_get() {
  local json="$1" path="$2"
  if mythos_has jq; then
    printf '%s' "$json" | jq -r "$path // empty" 2>/dev/null
  else
    # Naive fallback for top-level "key":"value" extraction; path like .key.subkey
    local key
    key="${path##.}"; key="${key//./.}"
    local last="${key##*.}"
    printf '%s' "$json" \
      | tr -d '\n' \
      | grep -oE "\"$last\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
      | head -1 \
      | sed -E "s/\"$last\"[[:space:]]*:[[:space:]]*\"([^\"]*)\"/\\1/"
  fi
}

# Read full stdin into a variable (safely handles empty stdin).
mythos_read_stdin() {
  if [ -t 0 ]; then
    printf ''
  else
    cat -
  fi
}

# Emit official hookSpecificOutput JSON contract on stdout.
# Usage: mythos_emit_hook_output "<hookEventName>" "<additionalContext string>"
mythos_emit_hook_output() {
  local event="$1" ctx="$2"
  if mythos_has jq; then
    jq -cn --arg e "$event" --arg c "$ctx" \
      '{hookSpecificOutput:{hookEventName:$e,additionalContext:$c}}'
  else
    local esc; esc=$(mythos_json_escape "$ctx")
    printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":%s}}\n' \
      "$event" "$esc"
  fi
}

# Claude Code 2.1.x exposes session-level metadata via env vars in
# subprocesses. These helpers read them safely (empty if unset, so hooks
# that source _lib.sh in older Claude Code versions still work).
# Verified: UserPromptSubmit hook is firing in this codebase, confirming
# we are on a version with the env-var contract. Use [C] tier if you log
# these — they are platform-derived, not Mythos-derived.
mythos_session_id() {
  printf '%s' "${CLAUDE_CODE_SESSION_ID:-}"
}
mythos_effort() {
  printf '%s' "${CLAUDE_EFFORT:-default}"
}

# Block a tool with an explanation (PreToolUse). Exit 2 = decline; stderr → user.
mythos_block() {
  local reason="$*"
  printf '🛑 Mythos guard: %s\n' "$reason" >&2
  mythos_log_event "block" "{\"reason\":$(mythos_json_escape "$reason")}"
  exit 2
}

mythos_allow() { exit 0; }

# Cross-platform mutex via atomic mkdir. macOS has no /usr/bin/flock.
# Usage:
#   mythos_lock_acquire <name> <timeout_ms?>
#   mythos_lock_release <name>
# Returns 0 if lock acquired, 1 if timed out. Default timeout: 5000ms.
mythos_lock_acquire() {
  local name="$1" timeout_ms="${2:-5000}"
  local lockdir="${MYTHOS_MEMORY_DIR}/.locks/${name}.lock"
  mkdir -p "${MYTHOS_MEMORY_DIR}/.locks" 2>/dev/null || true
  local waited=0
  while ! mkdir "$lockdir" 2>/dev/null; do
    # Stale-lock check: if owner pid is gone, steal it.
    local owner="" pidfile="$lockdir/pid"
    [ -f "$pidfile" ] && owner=$(cat "$pidfile" 2>/dev/null)
    if [ -n "$owner" ] && ! kill -0 "$owner" 2>/dev/null; then
      rm -rf "$lockdir" 2>/dev/null || true
      continue
    fi
    sleep 0.05 2>/dev/null || sleep 1
    waited=$((waited + 50))
    [ "$waited" -ge "$timeout_ms" ] && return 1
  done
  printf '%s' "$$" > "$lockdir/pid" 2>/dev/null || true
  return 0
}
mythos_lock_release() {
  local lockdir="${MYTHOS_MEMORY_DIR}/.locks/${1}.lock"
  rm -rf "$lockdir" 2>/dev/null || true
}
