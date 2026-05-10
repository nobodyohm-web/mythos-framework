#!/bin/bash
# Hook: smart-router — Detect task type from user prompt and emit a routing hint + relevant lessons.
# Triggered: UserPromptSubmit
# Output: a JSON object via the official Claude Code hookSpecificOutput contract so the additional
#         context is injected into Claude's prompt cleanly:
#   { "hookSpecificOutput": {
#       "hookEventName": "UserPromptSubmit",
#       "additionalContext": "[ROUTER] ... \n[LESSONS] ..." } }
#
# Falls back to a plain stdout one-liner if jq is unavailable.

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
INPUT="$(cat 2>/dev/null || true)"

# Extract the prompt text — works both with raw text and with JSON {"prompt":"..."} payloads
if echo "$INPUT" | grep -q '"prompt"'; then
  PROMPT=$(echo "$INPUT" | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
else
  PROMPT="$INPUT"
fi

LC=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

ROUTE=""
SKILL=""
AGENT=""

case "$LC" in
  *"fix"*|*"bug"*|*"error"*|*"broken"*|*"failing"*|*"crash"*|*"exception"*|*"stack trace"*)
    ROUTE="BUG_FIX"; SKILL="skills/debug-detective.md"; AGENT="debugger" ;;
  *"design"*|*"architect"*|*"adr"*|*"refactor architecture"*|*"system design"*)
    ROUTE="DESIGN"; SKILL="skills/architect.md"; AGENT="architect" ;;
  *"review"*|*"audit code"*|*"pr feedback"*)
    ROUTE="REVIEW"; SKILL="skills/code-review.md"; AGENT="reviewer" ;;
  *"test"*|*"tdd"*|*"add test"*|*"write tests"*)
    ROUTE="TDD"; SKILL="skills/tdd.md"; AGENT="tester" ;;
  *"refactor"*|*"clean up"*|*"restructure"*|*"extract"*)
    ROUTE="REFACTOR"; SKILL="skills/refactor.md" ;;
  *"slow"*|*"performance"*|*"latency"*|*"optimize"*|*"too slow"*|*"memory"*)
    ROUTE="PERFORMANCE"; SKILL="subagents/optimizer.md"; AGENT="optimizer" ;;
  *"security"*|*"vulnerab"*|*"owasp"*|*"cve"*|*"injection"*|*"xss"*|*"csrf"*)
    ROUTE="SECURITY"; SKILL="subagents/security-auditor.md"; AGENT="security-auditor" ;;
  *"plan"*|*"decompose"*|*"break down"*|*"split this"*|*"split the work"*)
    ROUTE="PLAN"; SKILL="skills/parallel-execution.md"; AGENT="planner" ;;
  *"team"*|*"parallel"*|*"in parallel"*|*"multi-agent"*|*"fan out"*|*"fan-out"*)
    ROUTE="TEAM"; SKILL="skills/parallel-execution.md" ;;
  *"benchmark"*|*"swe-bench"*|*"eval"*|*"evaluate"*|*"score"*|*"baseline"*)
    ROUTE="BENCHMARK"; SKILL="skills/self-improve.md" ;;
  *"self-improve"*|*"improve mythos"*|*"compounding"*|*"calibrate"*)
    ROUTE="SELF_IMPROVE"; SKILL="skills/self-improve.md" ;;
  *"mcp"*|*"filesystem server"*|*"memory server"*|*"sequential thinking"*|*"sequential-thinking"*)
    ROUTE="MCP"; SKILL="skills/mcp-orchestrator.md" ;;
  *"research"*|*"sota"*|*"state of the art"*|*"deep dive on"*|*"compare libraries"*)
    ROUTE="RESEARCH"; AGENT="researcher" ;;
  *"breakout"*|*"momentum"*|*"new high"*|*"volume surge"*)
    ROUTE="TRADE_BREAKOUT"; SKILL="skills/breakout.md" ;;
  *"pullback"*|*"dip"*|*"support bounce"*)
    ROUTE="TRADE_PULLBACK"; SKILL="skills/pullback.md" ;;
  *"reversion"*|*"oversold"*|*"overbought"*|*"fade"*|*"rsi divergence"*)
    ROUTE="TRADE_MEAN_REV"; SKILL="skills/mean-reversion.md" ;;
esac

# Multi-file change hint: if prompt mentions ≥3 files explicitly, suggest /team.
FILE_HITS=$(echo "$PROMPT" | grep -oE '[a-zA-Z0-9_./-]+\.(ts|tsx|js|jsx|py|rs|sh|md|json)' | sort -u | wc -l | tr -d ' ')
if [ "${FILE_HITS:-0}" -ge 3 ] && [ -z "$ROUTE" ]; then
  ROUTE="MULTI_FILE"; SKILL="skills/parallel-execution.md"
fi

# Compose the additional context text
TEXT=""
if [ -n "$ROUTE" ]; then
  TEXT="[ROUTER] Task type: $ROUTE → suggested skill: $SKILL"
  [ -n "$AGENT" ] && TEXT="$TEXT (subagent: $AGENT)"
fi

# Inject the most recent lesson — small, high-leverage context
LESSONS_FILE="$PROJECT_DIR/tasks/lessons.md"
if [ -f "$LESSONS_FILE" ]; then
  LAST=$(grep '^### ' "$LESSONS_FILE" 2>/dev/null | tail -1 | sed 's/^### //')
  if [ -n "$LAST" ]; then
    [ -n "$TEXT" ] && TEXT="$TEXT
"
    TEXT="${TEXT}[LESSONS] Most recent lesson: $LAST (see tasks/lessons.md for the rule)"
  fi
fi

# Nothing to add → exit silently
[ -z "$TEXT" ] && exit 0

# Prefer JSON output when jq is available — official hook contract
if command -v jq &>/dev/null; then
  jq -nc --arg t "$TEXT" '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$t}}'
else
  # Plain-stdout fallback — the harness still surfaces this to the model
  printf '%s\n' "$TEXT"
fi

exit 0
