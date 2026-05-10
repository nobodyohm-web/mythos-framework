#!/bin/bash
# Hook: subagent-tracker — Log subagent invocations and emit useful context to the main agent.
# Triggered: SubagentStop
# Reads the SubagentStop JSON payload from stdin and records:
#   - which subagent ran
#   - how many tool calls it made (if reported)
#   - duration if available

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
LOG_DIR="$PROJECT_DIR/.claude/memory"
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/subagents.log"

INPUT="$(cat 2>/dev/null || true)"

NAME=$(echo "$INPUT" | sed -n 's/.*"subagent_type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
[ -z "$NAME" ] && NAME=$(echo "$INPUT" | sed -n 's/.*"agent_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
[ -z "$NAME" ] && NAME="unknown"

DURATION=$(echo "$INPUT" | sed -n 's/.*"duration_ms"[[:space:]]*:[[:space:]]*\([0-9]*\).*/\1/p' | head -1)
TOOL_CALLS=$(echo "$INPUT" | sed -n 's/.*"tool_calls"[[:space:]]*:[[:space:]]*\([0-9]*\).*/\1/p' | head -1)

TS=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
echo "$TS|subagent=$NAME|duration_ms=${DURATION:-?}|tool_calls=${TOOL_CALLS:-?}" >> "$LOG"

# Surface a one-liner the main agent can act on
echo "[SUBAGENT-TRACKER] $NAME finished${DURATION:+ (${DURATION}ms)}${TOOL_CALLS:+, ${TOOL_CALLS} tool calls}"

exit 0
