#!/usr/bin/env bash
# git-guardian — PreToolUse defense-in-depth.
# Blocks: secret reads, force-push to main/master, rm -rf at dangerous roots,
# --no-verify, writes to .env / secrets / *.pem / *.key, git config tampering.
#
# Usage (settings.json wires both):
#   PreToolUse Bash         → bash hooks/git-guardian.sh bash
#   PreToolUse Write|Edit*  → bash hooks/git-guardian.sh file
. "${CLAUDE_PROJECT_DIR:-.}/hooks/_lib.sh"

MODE="${1:-auto}"
INPUT="$(mythos_read_stdin)"

# Extract tool input fields defensively.
get() { mythos_json_get "$INPUT" "$1"; }
TOOL_NAME="$(get '.tool_name')"
CMD="$(get '.tool_input.command')"
FILE_PATH="$(get '.tool_input.file_path')"

# --- BASH MODE: command-level checks ------------------------------------------
guard_bash() {
  [ -z "$CMD" ] && mythos_allow

  # We must distinguish *invoked commands* from *string contents inside an
  # argument* (e.g. `git commit -m "...rm -rf /..."`). Strategy: split CMD into
  # command-segments at unquoted shell separators, then strip quoted string
  # literals from each segment before pattern-matching the leading invocation.

  segments_clean() {
    # 1. Replace quoted strings with a placeholder so their contents don't match.
    #    Handles "..." and '...' (greedy, single-segment — good enough for
    #    detection of dangerous *invocations*; doesn't try to be a parser).
    # 2. Split on shell separators ; && || | newline.
    # 3. Trim leading whitespace.
    printf '%s' "$1" \
      | perl -0777 -pe 's/"(?:\\.|[^"\\])*"/__Q__/g; s/'\''[^'\'']*'\''/__Q__/g' 2>/dev/null \
      | tr ';\n' '\n\n' \
      | sed -E 's/(\&\&|\|\||\|)/\n/g' \
      | sed -E 's/^[[:space:]]+//'
  }

  # Fallback (perl missing): use original CMD with naive double-quote stripping.
  if ! mythos_has perl; then
    segments_clean() {
      printf '%s' "$1" \
        | sed -E 's/"[^"]*"/__Q__/g; s/'\''[^'\'']*'\''/__Q__/g' \
        | tr ';\n' '\n\n' \
        | sed -E 's/(\&\&|\|\||\|)/\n/g' \
        | sed -E 's/^[[:space:]]+//'
    }
  fi

  CLEAN_SEGMENTS="$(segments_clean "$CMD")"

  # Force-push to main/master.
  if printf '%s' "$CLEAN_SEGMENTS" | grep -Eq '^git[[:space:]]+push[[:space:]]+(--force|-f)([[:space:]].*)?(main|master)([[:space:]]|$)'; then
    mythos_block "force-push to main/master is denied (Risk.md). Open a PR or push to a topic branch."
  fi

  # Skipping git hooks (--no-verify) — only allow if user asked explicitly via env.
  if printf '%s' "$CLEAN_SEGMENTS" | grep -Eq '^git[[:space:]]+(commit|push|merge|rebase)([[:space:]].*)?[[:space:]]--no-verify([[:space:]]|$)'; then
    if [ "${MYTHOS_ALLOW_NO_VERIFY:-0}" != "1" ]; then
      mythos_block "--no-verify is denied. Fix the underlying hook failure instead."
    fi
  fi

  # rm -rf at dangerous roots — must be the leading invocation of a segment.
  if printf '%s' "$CLEAN_SEGMENTS" | grep -Eq '^rm[[:space:]]+(-[a-zA-Z]*r[a-zA-Z]*f|-rf|-fr)[[:space:]]+(/|~|\$HOME)([[:space:]]|$)'; then
    mythos_block "destructive rm at filesystem root denied."
  fi

  # Reading secret files via shell — leading invocation, not an embedded string.
  if printf '%s' "$CLEAN_SEGMENTS" | grep -Eq '^(cat|head|tail|less|more|bat|xxd)[[:space:]]+.*(\.env([^[:alnum:]_-]|$)|/secrets/|\.pem([^[:alnum:]_-]|$)|\.key([^[:alnum:]_-]|$))'; then
    mythos_block "reading secret files via shell is denied. Use a secret manager."
  fi

  # git config tampering (writes).
  if printf '%s' "$CLEAN_SEGMENTS" | grep -Eq '^git[[:space:]]+config[[:space:]]+(--global|--system|user\.|commit\.gpgsign)'; then
    if [ "${MYTHOS_ALLOW_GIT_CONFIG:-0}" != "1" ]; then
      mythos_block "modifying git config is denied (export MYTHOS_ALLOW_GIT_CONFIG=1 to override)."
    fi
  fi

  mythos_allow
}

# --- FILE MODE: Write/Edit/MultiEdit checks -----------------------------------
guard_file() {
  [ -z "$FILE_PATH" ] && mythos_allow
  case "$FILE_PATH" in
    *.env|*.env.*|*/.env|*/.env.*|*/secrets/*|*.pem|*.key|*credentials*.json|*credentials*.yml|*credentials*.yaml)
      mythos_block "writing to a secret-shaped path ($FILE_PATH) is denied."
      ;;
  esac
  mythos_allow
}

# --- AUTO: pick mode from tool_name -------------------------------------------
case "$MODE" in
  bash) guard_bash ;;
  file) guard_file ;;
  auto|*)
    case "$TOOL_NAME" in
      Bash) guard_bash ;;
      Write|Edit|MultiEdit) guard_file ;;
      *) mythos_allow ;;
    esac
    ;;
esac
