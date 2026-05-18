#!/usr/bin/env bash
# hallucination-guard — PreToolUse Bash hook for "tool-hallucination" detection.
#
# Scans a Bash command for path-like tokens being passed to commands that
# REQUIRE the referent to exist (cat, head, tail, less, grep, sed, awk, wc,
# file, stat, chmod, ls, find, source, ., bash <file>, python3 <file>, ...).
# If any such referent does not exist, emits a warning via additionalContext
# so the model sees it BEFORE the call runs — does NOT block.
#
# Catches the classic LLM failure of generating commands that reference
# non-existent files ("hallucination in action" per arXiv:2601.12560 §open
# challenges and arXiv:2504.19678 v2 §failure modes).
#
# Wiring: PreToolUse matcher "Bash" in .claude/settings.json.
set -uo pipefail
. "${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/hooks/_lib.sh"

INPUT="$(mythos_read_stdin)"
[ -z "$INPUT" ] && exit 0

CMD="$(mythos_json_get "$INPUT" '.tool_input.command')"
TOOL="$(mythos_json_get "$INPUT" '.tool_name')"
[ "$TOOL" != "Bash" ] && exit 0
[ -z "$CMD" ] && exit 0

# Only commands that REQUIRE the target to exist. Excludes creators
# (touch, mkdir, mv DST, cp DST, > redirection, tee, > file).
REQUIRE_EXIST_RX='(^|[[:space:]]|;|&&|\|\|)(cat|head|tail|less|more|bat|grep|egrep|fgrep|sed|awk|wc|file|stat|chmod|chown|ls|find|source|\.|bash|sh|zsh|python|python3|node|deno|ruby|perl|jq|cut|tr|sort|diff|md5|md5sum|sha1sum|sha256sum)([[:space:]]+|$)'

if ! printf '%s' "$CMD" | grep -Eq "$REQUIRE_EXIST_RX"; then
  exit 0
fi

# Skip if command contains backslash-escaped spaces — our naive tokenizer
# can't safely reassemble e.g. `/path/with\ spaces/file` after whitespace
# splitting, and it generates false positives that condition the user to
# ignore the warning (Kill Gate v5.2 pass 1 finding).
case "$CMD" in *'\ '*) exit 0 ;; esac

# Strip ALL quoted string contents so paths buried inside `echo "..."` etc.
# are not treated as real arguments. Also strip output redirections and their
# targets (`> file`, `>> file`, `2> /dev/null`, `&> log`) — those create or
# overwrite files, so the target need not exist.
SCRUBBED="$(printf '%s' "$CMD" \
  | sed -E '
      s/"[^"]*"/ /g
      s/'\''[^'\'']*'\''/ /g
      s/[0-9&]?>>?[[:space:]]*[^[:space:]]+/ /g
  ')"

MISSING=()
# shellcheck disable=SC2206
TOKENS=( $SCRUBBED )
for t in "${TOKENS[@]}"; do
  # skip empty and flag-like tokens
  [ -z "$t" ] && continue
  case "$t" in -*) continue ;; esac
  # skip shell operators / redirections / subshells (>foo, &, ;, (cmd, etc.)
  case "$t" in
    '>'*|'<'*|'&'*|';'*|'|'*|'('*|')'*|'`'*|'$('*|'${'*) continue ;;
  esac
  # only consider tokens that look like a path
  case "$t" in
    /*|./*|../*|*/*) ;;
    *) continue ;;
  esac
  # skip tokens with shell-expansion or escape characters we can't resolve cheaply
  case "$t" in
    *'$'*|*'`'*|*'*'*|*'?'*|*'{'*|*'['*|*'~'*|*'\'*) continue ;;
  esac
  # check against either absolute path or project-relative
  if [ ! -e "$t" ] && [ ! -e "$MYTHOS_PROJECT_DIR/$t" ]; then
    MISSING+=("$t")
  fi
done

if [ "${#MISSING[@]}" -gt 0 ]; then
  joined="${MISSING[*]}"
  msg="hallucination-guard: command references nonexistent paths: $joined — verify with ls before invoking, or use mkdir/touch if creating."
  printf '⚠️  %s\n' "$msg" >&2
  mythos_log_event "hallucination_suspected" \
    "{\"cmd\":$(mythos_json_escape "$CMD"),\"missing\":$(mythos_json_escape "$joined")}"
  if mythos_has jq; then
    jq -nc --arg t "[HALLUCINATION-GUARD] $msg" \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$t}}'
  else
    esc=$(mythos_json_escape "[HALLUCINATION-GUARD] $msg")
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":%s}}\n' "$esc"
  fi
fi

exit 0
