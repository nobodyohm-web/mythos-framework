#!/bin/bash
# Hook: PostTrade — Log fills and validate after execution
# L3 Guardrail Layer — runs after code edits or trade execution
# Maps to: the-trading-dev-kit/hooks/PostTrade.sh

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "── PostTrade Validation ──"

# 1. Typecheck (if applicable)
if [ -f "$PROJECT_DIR/tsconfig.json" ]; then
  echo "🔍 Typecheck..."
  if command -v bun &>/dev/null && bun run typecheck 2>&1; then
    echo "  ✅ Typecheck passed"
  elif command -v ~/.bun/bin/bun &>/dev/null && ~/.bun/bin/bun run typecheck 2>&1; then
    echo "  ✅ Typecheck passed"
  elif command -v npx &>/dev/null && npx tsc --noEmit 2>&1; then
    echo "  ✅ Typecheck passed"
  else
    echo "  ❌ TYPECHECK FAILED — fix before continuing"
    exit 1
  fi
fi

# 2. Lint (if applicable)
if [ -f "$PROJECT_DIR/.eslintrc.json" ] || [ -f "$PROJECT_DIR/.eslintrc.js" ] || [ -f "$PROJECT_DIR/eslint.config.js" ]; then
  echo "🧹 Lint..."
  if npx eslint --quiet . 2>&1; then
    echo "  ✅ Lint passed"
  else
    echo "  ⚠️  Lint warnings — review before committing"
  fi
fi

# 3. Run tests (if test files exist)
TEST_COUNT=$(find "$PROJECT_DIR" -name "*.test.ts" -o -name "*.test.js" -o -name "*.test.py" 2>/dev/null | grep -v node_modules | wc -l | tr -d ' ')
if [ "$TEST_COUNT" -gt 0 ]; then
  echo "🧪 Running tests ($TEST_COUNT test files)..."
  if command -v bun &>/dev/null && bun test 2>&1; then
    echo "  ✅ Tests passed"
  elif command -v ~/.bun/bin/bun &>/dev/null && ~/.bun/bin/bun test 2>&1; then
    echo "  ✅ Tests passed"
  else
    echo "  ❌ TESTS FAILED — fix before continuing"
    exit 1
  fi
fi

# 4. Security check — no secrets staged
if [ -d "$PROJECT_DIR/.git" ]; then
  cd "$PROJECT_DIR"
  STAGED_SECRETS=$(git diff --cached --name-only 2>/dev/null | grep -E '\.(env|key|pem|secret)' || true)
  if [ -n "$STAGED_SECRETS" ]; then
    echo "  ⛔ SECURITY ALERT: Secret files staged for commit!"
    echo "$STAGED_SECRETS" | sed 's/^/    ❌ /'
    exit 1
  fi
fi

echo "── PostTrade: All clear ──"
