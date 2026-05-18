#!/bin/bash
# Hook: session-start — Load context at session start.
# Triggered by SessionStart in .claude/settings.json.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "═══════════════════════════════════════════"
echo "  🌅 SESSION START — Context Loader"
echo "  $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "═══════════════════════════════════════════"

# 1. Review lessons learned
if [ -f "$PROJECT_DIR/tasks/lessons.md" ]; then
  LESSON_COUNT=$(grep -c "^### " "$PROJECT_DIR/tasks/lessons.md" 2>/dev/null || true)
  echo "📚 Lessons learned: $LESSON_COUNT entries — REVIEW BEFORE CODING"
  if [ "$LESSON_COUNT" -gt 0 ]; then
    echo "   Last lesson:"
    grep "^### " "$PROJECT_DIR/tasks/lessons.md" | tail -1 | sed 's/^/   /'
  fi
fi

# 2. Pending tasks
if [ -f "$PROJECT_DIR/tasks/todo.md" ]; then
  PENDING=$(grep -c "^\- \[ \]" "$PROJECT_DIR/tasks/todo.md" 2>/dev/null || true)
  DONE=$(grep -c "^\- \[x\]" "$PROJECT_DIR/tasks/todo.md" 2>/dev/null || true)
  echo "📋 Tasks: $PENDING pending, $DONE completed"
fi

# 3. Git status
if [ -d "$PROJECT_DIR/.git" ]; then
  cd "$PROJECT_DIR"
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
  echo "🔀 Branch: $BRANCH | Uncommitted files: $DIRTY"
fi

# 4. Skills
SKILL_COUNT=$(find "$PROJECT_DIR/skills" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
echo "📖 Available playbooks: $SKILL_COUNT"
if [ "$SKILL_COUNT" -gt 0 ]; then
  find "$PROJECT_DIR/skills" -maxdepth 1 -name "*.md" -exec basename {} .md \; 2>/dev/null | sort | sed 's/^/   ⚡ /'
fi

# 5. Subagents — prefer the canonical .claude/agents/ if populated
if [ -d "$PROJECT_DIR/.claude/agents" ] && [ -n "$(ls -A "$PROJECT_DIR/.claude/agents" 2>/dev/null)" ]; then
  AGENT_COUNT=$(find "$PROJECT_DIR/.claude/agents" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "🤖 Available subagents (auto-discovered via .claude/agents/): $AGENT_COUNT"
  find "$PROJECT_DIR/.claude/agents" -maxdepth 1 -name "*.md" -exec basename {} .md \; 2>/dev/null | sort | sed 's/^/   🔹 /'
else
  AGENT_COUNT=$(find "$PROJECT_DIR/subagents" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "🤖 Available subagents (subagents/ legacy): $AGENT_COUNT"
  find "$PROJECT_DIR/subagents" -maxdepth 1 -name "*.md" -exec basename {} .md \; 2>/dev/null | sort | sed 's/^/   🔹 /'
fi

# 6. Runtime check
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
echo "  ✅ Session start context loaded. Ready to execute."
echo "═══════════════════════════════════════════"
