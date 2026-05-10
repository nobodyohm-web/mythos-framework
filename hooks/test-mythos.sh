#!/bin/bash
# Hook: test-mythos — Self-test the entire Mythos system
# Verifies: file presence, JSON validity, hook executability, frontmatter validity
# Run: bash hooks/test-mythos.sh

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$PROJECT_DIR"

PASS=0
FAIL=0
WARN=0

green() { echo "  ✅ $1"; PASS=$((PASS+1)); }
red()   { echo "  ❌ $1"; FAIL=$((FAIL+1)); }
yel()   { echo "  ⚠️  $1"; WARN=$((WARN+1)); }

echo "═══════════════════════════════════════════"
echo "  🧪 MYTHOS SELF-TEST"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "═══════════════════════════════════════════"

# 1. Core files
echo "── Core files ──"
for f in CLAUDE.md Risk.md .claude/settings.json .claude/memory/patterns.json; do
  [ -f "$f" ] && green "$f exists" || red "$f MISSING"
done

# 2. CLAUDE.md size sanity
LINES=$(wc -l < CLAUDE.md | tr -d ' ')
if [ "$LINES" -le 200 ]; then
  green "CLAUDE.md is $LINES lines (≤200 budget)"
else
  yel "CLAUDE.md is $LINES lines (>200 — consider trimming)"
fi

# 3. JSON validity
echo "── JSON validity ──"
for j in .claude/settings.json .claude/memory/patterns.json; do
  if [ -f "$j" ]; then
    if command -v python3 &>/dev/null; then
      python3 -c "import json,sys; json.load(open('$j'))" 2>/dev/null \
        && green "$j valid JSON" \
        || red "$j INVALID JSON"
    else
      yel "$j — python3 not available, skipped JSON parse"
    fi
  fi
done

# 4. Hooks: present, executable, syntactically valid
echo "── Hooks ──"
for h in PreMarket.sh PostTrade.sh EndOfDay.sh auto-learn.sh verify-completion.sh \
         smart-router.sh context-guardian.sh git-guardian.sh \
         error-recovery.sh session-state.sh test-mythos.sh; do
  P="hooks/$h"
  if [ -f "$P" ]; then
    if [ -x "$P" ]; then
      bash -n "$P" 2>/dev/null && green "$h ok" || red "$h syntax error"
    else
      yel "$h not executable — run: chmod +x $P"
    fi
  else
    red "$h MISSING"
  fi
done

# 5. Skills: present + has frontmatter
echo "── Skills ──"
for s in breakout pullback mean-reversion debug-detective architect code-review tdd refactor; do
  P="skills/$s.md"
  if [ -f "$P" ]; then
    head -1 "$P" | grep -q '^---$' && green "skills/$s.md has frontmatter" || yel "skills/$s.md missing YAML frontmatter"
  else
    red "skills/$s.md MISSING"
  fi
done

# 6. Subagents
echo "── Subagents ──"
for a in market-researcher risk-manager journal-analyzer architect debugger optimizer security-auditor; do
  P="subagents/$a.md"
  [ -f "$P" ] && green "subagents/$a.md exists" || red "subagents/$a.md MISSING"
done

# 7. Slash commands
echo "── Slash commands ──"
for c in mythosrun evolve heal deepaudit swarm reflect bootstrap ship research; do
  P=".claude/commands/$c.md"
  [ -f "$P" ] && green "/$c command exists" || red "/$c command MISSING"
done

# 8. Task ledgers
echo "── Task ledgers ──"
for t in lessons.md confidence-log.md todo.md session-journal.md; do
  P="tasks/$t"
  [ -f "$P" ] && green "tasks/$t exists" || red "tasks/$t MISSING"
done

# 9. Settings.json wiring sanity
echo "── Hook wiring ──"
if [ -f .claude/settings.json ]; then
  for ev in SessionStart SessionEnd PostToolUse Stop; do
    grep -q "\"$ev\"" .claude/settings.json && green "$ev wired" || yel "$ev not wired"
  done
fi

# 10. Runtime
echo "── Runtime ──"
command -v claude &>/dev/null && green "claude CLI: $(claude --version 2>/dev/null || echo unknown)" || yel "claude CLI not in PATH"
command -v bun &>/dev/null && green "bun: $(bun --version)" || yel "bun not in PATH"
command -v node &>/dev/null && green "node: $(node --version)" || yel "node not in PATH"
command -v git &>/dev/null && green "git: $(git --version | awk '{print $3}')" || red "git not in PATH"

# Summary
echo "═══════════════════════════════════════════"
echo "  RESULT: $PASS passed | $FAIL failed | $WARN warnings"
if [ "$FAIL" -gt 0 ]; then
  echo "  ❌ MYTHOS SELF-TEST: FAILED"
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo "  ⚠️  MYTHOS SELF-TEST: PASSED WITH WARNINGS"
  exit 0
else
  echo "  ✅ MYTHOS SELF-TEST: ALL CLEAR"
  exit 0
fi
