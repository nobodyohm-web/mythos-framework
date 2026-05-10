#!/bin/bash
# Hook: verify-completion — Verify before declaring "done"
# Self-healing guardrail: prevents premature task completion
# Triggered by the Stop hook in .claude/settings.json

set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0

echo "── 🔍 Mythos Completion Verification ──"

# 1. Typecheck (if applicable)
if [ -f "$PROJECT_DIR/tsconfig.json" ]; then
  if command -v bun &>/dev/null && ! bun run typecheck 2>/dev/null; then
    echo "  ❌ TYPECHECK FAILED — cannot mark complete"
    ERRORS=$((ERRORS + 1))
  elif command -v npx &>/dev/null && ! npx tsc --noEmit 2>/dev/null; then
    echo "  ❌ TYPECHECK FAILED — cannot mark complete"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ Typecheck passed"
  fi
fi

# 2. Tests (if test files exist)
TEST_COUNT=$(find "$PROJECT_DIR" -name "*.test.*" 2>/dev/null | grep -v node_modules | wc -l | tr -d ' ')
if [ "$TEST_COUNT" -gt 0 ]; then
  if command -v bun &>/dev/null && ! bun test 2>/dev/null; then
    echo "  ❌ TESTS FAILED ($TEST_COUNT test files) — cannot mark complete"
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ Tests passed ($TEST_COUNT files)"
  fi
fi

# 3. Security check — no secrets in staged files
if [ -d "$PROJECT_DIR/.git" ]; then
  cd "$PROJECT_DIR"
  STAGED_SECRETS=$(git diff --cached --name-only 2>/dev/null | grep -E '\.(env|key|pem|secret)' || true)
  if [ -n "$STAGED_SECRETS" ]; then
    echo "  ⛔ SECURITY: Secret files staged for commit!"
    echo "$STAGED_SECRETS" | sed 's/^/    ❌ /'
    ERRORS=$((ERRORS + 1))
  else
    echo "  ✅ No secrets staged"
  fi
fi

# 4. Check if lessons were captured (if corrections happened)
if [ -f "$PROJECT_DIR/tasks/lessons.md" ]; then
  LESSON_COUNT=$(grep -c "^### " "$PROJECT_DIR/tasks/lessons.md" 2>/dev/null || echo "0")
  echo "  📚 Lessons captured: $LESSON_COUNT"
fi

# 5. Check if confidence was logged
if [ -f "$PROJECT_DIR/tasks/confidence-log.md" ]; then
  CONF_COUNT=$(grep -c "^\*\*Confidence:\*\*" "$PROJECT_DIR/tasks/confidence-log.md" 2>/dev/null || echo "0")
  echo "  📊 Confidence entries: $CONF_COUNT"
fi

# Report
if [ "$ERRORS" -gt 0 ]; then
  echo "── ❌ VERIFICATION FAILED: $ERRORS issue(s) must be fixed ──"
  echo "  Run /heal to auto-fix, or resolve manually."
  exit 1
else
  echo "── ✅ Mythos Verification: All clear ──"
fi
