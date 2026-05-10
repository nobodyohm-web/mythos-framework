#!/bin/bash
# Hook: PreMarket — Load market context before Claude Code session starts
# L3 Guardrail Layer — runs automatically at session start
# Maps to: the-trading-dev-kit/hooks/PreMarket.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "═══════════════════════════════════════════"
echo "  🌅 PRE-MARKET — Context Loader"
echo "  $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "═══════════════════════════════════════════"

# 1. Review lessons learned (Self-Improvement Loop — L3 Rule #3)
if [ -f "$PROJECT_DIR/tasks/lessons.md" ]; then
  LESSON_COUNT=$(grep -c "^### " "$PROJECT_DIR/tasks/lessons.md" 2>/dev/null || echo "0")
  echo "📚 Lessons learned: $LESSON_COUNT entries — REVIEW BEFORE CODING"
  if [ "$LESSON_COUNT" -gt 0 ]; then
    echo "   Last lesson:"
    grep "^### " "$PROJECT_DIR/tasks/lessons.md" | tail -1 | sed 's/^/   /'
  fi
fi

# 2. Check pending tasks (Task Management — L4)
if [ -f "$PROJECT_DIR/tasks/todo.md" ]; then
  PENDING=$(grep -c "^\- \[ \]" "$PROJECT_DIR/tasks/todo.md" 2>/dev/null || echo "0")
  DONE=$(grep -c "^\- \[x\]" "$PROJECT_DIR/tasks/todo.md" 2>/dev/null || echo "0")
  echo "📋 Tasks: $PENDING pending, $DONE completed"
fi

# 3. Git status
if [ -d "$PROJECT_DIR/.git" ]; then
  cd "$PROJECT_DIR"
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
  echo "🔀 Branch: $BRANCH | Uncommitted files: $DIRTY"
fi

# 4. Verify available skills (Knowledge Layer — L2)
SKILL_COUNT=$(find "$PROJECT_DIR/skills" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
echo "📖 Available playbooks: $SKILL_COUNT"
if [ "$SKILL_COUNT" -gt 0 ]; then
  find "$PROJECT_DIR/skills" -name "*.md" -exec basename {} .md \; 2>/dev/null | sort | sed 's/^/   ⚡ /'
fi

# 5. Verify subagents (Delegation Layer — L4)
AGENT_COUNT=$(find "$PROJECT_DIR/subagents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
echo "🤖 Available subagents: $AGENT_COUNT"
if [ "$AGENT_COUNT" -gt 0 ]; then
  find "$PROJECT_DIR/subagents" -name "*.md" -exec basename {} .md \; 2>/dev/null | sort | sed 's/^/   🔹 /'
fi

# 6. Check runtime availability
echo "── Runtime Check ──"
if command -v claude &>/dev/null; then
  CLAUDE_V=$(claude --version 2>/dev/null || echo "unknown")
  echo "  ✅ Claude Code: $CLAUDE_V"
else
  echo "  ⚠️  Claude Code CLI not found"
fi

if command -v bun &>/dev/null || command -v ~/.bun/bin/bun &>/dev/null; then
  BUN_V=$(bun --version 2>/dev/null || ~/.bun/bin/bun --version 2>/dev/null || echo "unknown")
  echo "  ✅ Bun: v$BUN_V"
fi

if command -v node &>/dev/null; then
  NODE_V=$(node --version 2>/dev/null || echo "unknown")
  echo "  ✅ Node: $NODE_V"
fi

echo "═══════════════════════════════════════════"
echo "  ✅ Pre-market context loaded. Ready to trade."
echo "═══════════════════════════════════════════"
