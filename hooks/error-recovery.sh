#!/bin/bash
# Hook: error-recovery — Detect known error patterns in PostToolUse output and log them
# Triggered: PostToolUse (Bash)
# Output: emits "[ERROR-RECOVERY] hint: ..." for known patterns. Non-blocking.

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
LOG_DIR="$PROJECT_DIR/.claude/memory"
mkdir -p "$LOG_DIR"
ERROR_LOG="$LOG_DIR/error-recovery.log"

INPUT="$(cat 2>/dev/null || true)"

# Extract command output if present
OUTPUT=$(echo "$INPUT" | sed -n 's/.*"output"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p' | head -c 5000)
[ -z "$OUTPUT" ] && OUTPUT="$INPUT"

emit() {
  local TAG="$1"; local HINT="$2"
  echo "[ERROR-RECOVERY] $TAG → $HINT"
  echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ')|$TAG|$HINT" >> "$ERROR_LOG"
}

# --- Known patterns ----------------------------------------------------------

# TypeScript: missing types
if echo "$OUTPUT" | grep -qE 'TS2307|TS2304.*Cannot find name'; then
  emit "TS_MISSING_MODULE" "Run 'bun add -d @types/<package>' or check tsconfig paths"
fi

# Node: ESM vs CJS confusion
if echo "$OUTPUT" | grep -qE 'ERR_REQUIRE_ESM|Cannot use import statement outside a module'; then
  emit "ESM_CJS_MISMATCH" "Add \"type\": \"module\" to package.json or rename to .mjs"
fi

# Bun: command not found
if echo "$OUTPUT" | grep -qE 'bun: command not found'; then
  emit "BUN_MISSING" "Install bun: 'curl -fsSL https://bun.sh/install | bash' then 'source ~/.zshrc'"
fi

# Port already in use
if echo "$OUTPUT" | grep -qE 'EADDRINUSE|address already in use'; then
  PORT=$(echo "$OUTPUT" | grep -oE ':[0-9]+' | head -1 | tr -d ':')
  emit "PORT_IN_USE" "Port ${PORT:-?} busy. Find: 'lsof -i :${PORT:-PORT}'  Kill: 'kill -9 \$(lsof -ti :${PORT:-PORT})'"
fi

# Permission denied (file)
if echo "$OUTPUT" | grep -qE 'EACCES|Permission denied'; then
  emit "PERMISSION_DENIED" "Check file ownership / chmod; never sudo as a fix"
fi

# Git: rejected non-fast-forward
if echo "$OUTPUT" | grep -qE 'rejected.*non-fast-forward|Updates were rejected'; then
  emit "GIT_NON_FF" "Run 'git pull --rebase' first; never force-push to main"
fi

# Network failures
if echo "$OUTPUT" | grep -qE 'ENOTFOUND|ECONNREFUSED|ETIMEDOUT|getaddrinfo'; then
  emit "NETWORK_FAIL" "Check connectivity / DNS / VPN; consider exponential backoff retry"
fi

# Disk full
if echo "$OUTPUT" | grep -qE 'ENOSPC|No space left on device'; then
  emit "DISK_FULL" "Free space: 'df -h'; clear caches: 'bun pm cache rm', 'npm cache clean --force'"
fi

# Auth failures
if echo "$OUTPUT" | grep -qE '401 Unauthorized|403 Forbidden|invalid_grant|invalid_token'; then
  emit "AUTH_FAIL" "Check API keys, refresh token, env vars. Re-auth if expired."
fi

exit 0
