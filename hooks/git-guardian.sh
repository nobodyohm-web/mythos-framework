#!/bin/bash
# Hook: git-guardian — Block secret-containing writes; warn on dangerous git operations
# Triggered: PreToolUse on Write|Edit|MultiEdit|Bash
# Returns: exit code 2 (BLOCK) if a hard violation is detected; 0 otherwise.
#
# Wiring:
#   "PreToolUse": [
#     { "matcher": "Write|Edit|MultiEdit",
#       "hooks": [{ "type": "command",
#                   "command": "bash \"${CLAUDE_PROJECT_DIR:-.}/hooks/git-guardian.sh\" file" }]},
#     { "matcher": "Bash",
#       "hooks": [{ "type": "command",
#                   "command": "bash \"${CLAUDE_PROJECT_DIR:-.}/hooks/git-guardian.sh\" bash" }]}
#   ]

set -uo pipefail

MODE="${1:-file}"
INPUT="$(cat 2>/dev/null || true)"

# Patterns indicating real secrets (not common variable names like "password" alone).
# Tuned conservatively to avoid false positives on docs / type defs.
SECRET_PATTERNS='(sk-(live|test)?-?[a-zA-Z0-9]{20,}|sk-ant-[a-zA-Z0-9-]{20,}|ghp_[a-zA-Z0-9]{20,}|gho_[a-zA-Z0-9]{20,}|github_pat_[a-zA-Z0-9_]{60,}|AKIA[0-9A-Z]{16}|aws_secret_access_key[[:space:]]*=[[:space:]]*["\x27]?[A-Za-z0-9/+=]{40}|-----BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----|xox[baprs]-[0-9a-zA-Z-]{10,})'

if [ "$MODE" = "file" ]; then
  # Inspect file content payload for secret-shaped strings
  if echo "$INPUT" | grep -qiE "$SECRET_PATTERNS"; then
    echo "[GIT-GUARDIAN] ⛔ BLOCKED: file payload contains a secret-shaped string. Use env vars / secret manager." >&2
    exit 2
  fi

  # Block writes to common secret files
  if echo "$INPUT" | grep -qE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*\.(env|env\.[a-z]+|pem|key|p12|pfx)"'; then
    PATH_HIT=$(echo "$INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    echo "[GIT-GUARDIAN] ⛔ BLOCKED: refusing to write secret-class file: $PATH_HIT" >&2
    exit 2
  fi
fi

if [ "$MODE" = "bash" ]; then
  # Extract command string
  CMD=$(echo "$INPUT" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

  # Block force-push to main / master
  if echo "$CMD" | grep -qE 'git[[:space:]]+push[[:space:]]+([^[:space:]]+[[:space:]]+)?(--force|--force-with-lease|-f)[[:space:]]*.*\b(main|master)\b'; then
    echo "[GIT-GUARDIAN] ⛔ BLOCKED: force-push to main/master is forbidden." >&2
    exit 2
  fi
  if echo "$CMD" | grep -qE 'git[[:space:]]+push[[:space:]]+.*(main|master).*[[:space:]](--force|-f)'; then
    echo "[GIT-GUARDIAN] ⛔ BLOCKED: force-push to main/master is forbidden." >&2
    exit 2
  fi

  # Warn on rm -rf with broad targets
  if echo "$CMD" | grep -qE 'rm[[:space:]]+(-rf|-fr|-r[[:space:]]+-f|-f[[:space:]]+-r)[[:space:]]+(/|~|\$HOME|\.\.|\*)'; then
    echo "[GIT-GUARDIAN] ⛔ BLOCKED: dangerous rm targeting filesystem root / home / parent." >&2
    exit 2
  fi

  # Warn on git reset --hard without target (current branch wipe)
  if echo "$CMD" | grep -qE 'git[[:space:]]+reset[[:space:]]+--hard[[:space:]]*$'; then
    echo "[GIT-GUARDIAN] ⚠️  Warning: 'git reset --hard' with no target discards uncommitted work." >&2
    # warn only, do not block
  fi

  # Block committing .env / *.pem / *.key
  if echo "$CMD" | grep -qE 'git[[:space:]]+(add|commit).*\.(env|pem|key|p12|pfx)'; then
    echo "[GIT-GUARDIAN] ⛔ BLOCKED: refusing to stage/commit secret-class file." >&2
    exit 2
  fi
fi

exit 0
