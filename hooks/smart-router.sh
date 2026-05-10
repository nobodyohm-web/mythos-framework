#!/bin/bash
# Hook: smart-router — Detect task type from user prompt and emit a routing hint
# Triggered: UserPromptSubmit
# Output: a one-liner Claude sees as system context, e.g.
#   "[ROUTER] Task type: BUG_FIX → suggested skill: skills/debug-detective.md"
#
# Wiring (in .claude/settings.json):
#   "UserPromptSubmit": [{ "hooks": [{ "type": "command",
#     "command": "bash \"${CLAUDE_PROJECT_DIR:-.}/hooks/smart-router.sh\"" }]}]

set -uo pipefail

# Read user prompt from stdin (Claude Code passes prompt JSON on stdin for UserPromptSubmit)
INPUT="$(cat 2>/dev/null || true)"

# Extract the prompt text — works both with raw text and with JSON {"prompt":"..."} payloads
if echo "$INPUT" | grep -q '"prompt"'; then
  PROMPT=$(echo "$INPUT" | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
else
  PROMPT="$INPUT"
fi

# Lower-case for matching
LC=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

ROUTE=""
SKILL=""

case "$LC" in
  *"fix"*|*"bug"*|*"error"*|*"broken"*|*"failing"*|*"crash"*|*"exception"*|*"stack trace"*)
    ROUTE="BUG_FIX"; SKILL="skills/debug-detective.md" ;;
  *"design"*|*"architect"*|*"adr"*|*"refactor architecture"*|*"system design"*)
    ROUTE="DESIGN"; SKILL="skills/architect.md" ;;
  *"review"*|*"audit code"*|*"pr feedback"*)
    ROUTE="REVIEW"; SKILL="skills/code-review.md" ;;
  *"test"*|*"tdd"*|*"add test"*|*"write tests"*)
    ROUTE="TDD"; SKILL="skills/tdd.md" ;;
  *"refactor"*|*"clean up"*|*"restructure"*|*"extract"*)
    ROUTE="REFACTOR"; SKILL="skills/refactor.md" ;;
  *"slow"*|*"performance"*|*"latency"*|*"optimize"*|*"too slow"*|*"memory"*)
    ROUTE="PERFORMANCE"; SKILL="subagents/optimizer.md" ;;
  *"security"*|*"vulnerab"*|*"owasp"*|*"cve"*|*"injection"*|*"xss"*|*"csrf"*)
    ROUTE="SECURITY"; SKILL="subagents/security-auditor.md" ;;
  *"breakout"*|*"momentum"*|*"new high"*|*"volume surge"*)
    ROUTE="TRADE_BREAKOUT"; SKILL="skills/breakout.md" ;;
  *"pullback"*|*"dip"*|*"support bounce"*)
    ROUTE="TRADE_PULLBACK"; SKILL="skills/pullback.md" ;;
  *"reversion"*|*"oversold"*|*"overbought"*|*"fade"*|*"rsi divergence"*)
    ROUTE="TRADE_MEAN_REV"; SKILL="skills/mean-reversion.md" ;;
esac

if [ -n "$ROUTE" ]; then
  echo "[ROUTER] Task type: $ROUTE → suggested skill: $SKILL"
fi

# Always exit 0; routing is advisory, never blocking
exit 0
