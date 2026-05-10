#!/usr/bin/env bash
# test-mythos — self-test harness. Validates the Mythos system end-to-end:
# files exist, hooks executable, JSON valid, hooks behave correctly under
# crafted stdin. Exit 0 = all green, exit 1 = any failure.
#
# Usage: bash hooks/test-mythos.sh [--verbose]
. "${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}/hooks/_lib.sh"

VERBOSE=0
[ "${1:-}" = "--verbose" ] && VERBOSE=1

PASS=0; FAIL=0
RED=$'\033[31m'; GRN=$'\033[32m'; DIM=$'\033[2m'; OFF=$'\033[0m'

check() {
  local label="$1" status="$2" detail="${3:-}"
  if [ "$status" -eq 0 ]; then
    PASS=$((PASS+1))
    [ "$VERBOSE" -eq 1 ] && printf '  %s✓%s %s\n' "$GRN" "$OFF" "$label"
  else
    FAIL=$((FAIL+1))
    printf '  %s✗%s %s%s%s\n' "$RED" "$OFF" "$label" "${detail:+ — }" "$detail"
  fi
}

section() { printf '\n%s── %s ──%s\n' "$DIM" "$1" "$OFF"; }

P="$MYTHOS_PROJECT_DIR"

# ─── 1. Required files ────────────────────────────────────────────────────────
section "Files & directories"
for f in CLAUDE.md Risk.md \
         .claude/settings.json .claude/memory/patterns.json \
         tasks/lessons.md tasks/confidence-log.md tasks/session-journal.md tasks/todo.md
do
  [ -f "$P/$f" ]; check "exists: $f" $?
done

for d in .claude/agents .claude/commands .claude/memory skills tasks hooks; do
  [ -d "$P/$d" ]; check "dir:    $d" $?
done

# ─── 2. Hooks: present & executable ───────────────────────────────────────────
section "Hooks"
HOOKS=(_lib.sh PreMarket.sh PostTrade.sh EndOfDay.sh \
       smart-router.sh git-guardian.sh context-guardian.sh error-recovery.sh \
       session-state.sh observability.sh precompact-snapshot.sh subagent-tracker.sh \
       notification-handler.sh verify-completion.sh auto-learn.sh test-mythos.sh \
       self-eval.sh execution-monitor.sh)
for h in "${HOOKS[@]}"; do
  [ -f "$P/hooks/$h" ]; check "file:  hooks/$h" $?
done
for h in "${HOOKS[@]}"; do
  [ -x "$P/hooks/$h" ]; check "+x:    hooks/$h" $?
done

# ─── 3. JSON config validity ──────────────────────────────────────────────────
section "JSON validity"
python3 -c "import json,sys; json.load(open('$P/.claude/settings.json'))" 2>/dev/null
check "settings.json parses"               $?
python3 -c "import json,sys; json.load(open('$P/.claude/memory/patterns.json'))" 2>/dev/null
check "patterns.json parses"               $?

# settings.json must wire every hook the lifecycle declares.
for h in smart-router git-guardian context-guardian error-recovery \
         session-state observability precompact-snapshot subagent-tracker \
         notification-handler verify-completion auto-learn PreMarket PostTrade EndOfDay \
         self-eval execution-monitor
do
  grep -q "$h.sh" "$P/.claude/settings.json"
  check "settings.json wires $h.sh" $?
done

# v4: settings.json must declare mcpServers with at least filesystem + memory.
python3 -c "
import json,sys
d = json.load(open('$P/.claude/settings.json'))
m = d.get('mcpServers', {})
sys.exit(0 if ('filesystem' in m and 'memory' in m) else 1)
" 2>/dev/null
check "settings.json declares filesystem + memory MCP servers" $?

python3 -c "
import json,sys
d = json.load(open('$P/.claude/settings.json'))
sys.exit(0 if d.get('env',{}).get('MYTHOS_VERSION','').startswith('4') else 1)
" 2>/dev/null
check "MYTHOS_VERSION is 4.x"               $?

# ─── 4. CLAUDE.md size budget ─────────────────────────────────────────────────
section "CLAUDE.md budget"
lines="$(wc -l <"$P/CLAUDE.md" | tr -d ' ')"
[ "$lines" -le 200 ]
check "CLAUDE.md ≤ 200 lines (actual: $lines)" $?

# ─── 5. Subagents: canonical layout + frontmatter ─────────────────────────────
section "Subagents"
for f in "$P"/.claude/agents/*.md; do
  [ -f "$f" ] || continue
  head -1 "$f" | grep -q '^---$'
  check "frontmatter open: $(basename "$f")" $?
  grep -q '^name:' "$f"
  check "frontmatter name: $(basename "$f")" $?
  grep -q '^description:' "$f"
  check "frontmatter desc: $(basename "$f")" $?
done

# ─── 6. Skills: present ───────────────────────────────────────────────────────
section "Skills"
for s in debug-detective architect code-review tdd refactor \
         mcp-orchestrator parallel-execution self-improve; do
  [ -f "$P/skills/$s.md" ]; check "skill:  skills/$s.md" $?
done

# ─── 6b. v4 agents (planner/researcher/implementer/reviewer/tester) ───────────
section "v4 Agents"
for a in planner researcher implementer reviewer tester; do
  [ -f "$P/.claude/agents/$a.md" ]; check "agent:  .claude/agents/$a.md" $?
  if [ -f "$P/.claude/agents/$a.md" ]; then
    grep -q "^name: $a" "$P/.claude/agents/$a.md"
    check "agent name matches: $a"           $?
    grep -q '^tools:' "$P/.claude/agents/$a.md"
    check "agent declares tools: $a"         $?
  fi
done

# ─── 6c. v4 commands ──────────────────────────────────────────────────────────
section "v4 Commands"
for c in team benchmark calibrate; do
  [ -f "$P/.claude/commands/$c.md" ]; check "command: /$c" $?
done

# ─── 7. Behavior tests on hooks ───────────────────────────────────────────────
section "Behavior: git-guardian"

# 7a. Force-push to main MUST be blocked (exit 2).
echo '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' \
  | bash "$P/hooks/git-guardian.sh" bash >/dev/null 2>&1
[ $? -eq 2 ]; check "blocks force-push to main" $?

# 7b. Normal push allowed (exit 0).
echo '{"tool_name":"Bash","tool_input":{"command":"git push origin feature-branch"}}' \
  | bash "$P/hooks/git-guardian.sh" bash >/dev/null 2>&1
[ $? -eq 0 ]; check "allows normal push" $?

# 7c. rm -rf / blocked.
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' \
  | bash "$P/hooks/git-guardian.sh" bash >/dev/null 2>&1
[ $? -eq 2 ]; check "blocks rm -rf /" $?

# 7d. --no-verify blocked.
echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"x\" --no-verify"}}' \
  | bash "$P/hooks/git-guardian.sh" bash >/dev/null 2>&1
[ $? -eq 2 ]; check "blocks --no-verify" $?

# 7e. Writing to .env blocked.
echo '{"tool_name":"Write","tool_input":{"file_path":"/x/.env"}}' \
  | bash "$P/hooks/git-guardian.sh" file >/dev/null 2>&1
[ $? -eq 2 ]; check "blocks write to .env" $?

# 7f. Writing to a normal file allowed.
echo '{"tool_name":"Write","tool_input":{"file_path":"/x/foo.py"}}' \
  | bash "$P/hooks/git-guardian.sh" file >/dev/null 2>&1
[ $? -eq 0 ]; check "allows write to .py file" $?

# 7g. NEW: dangerous patterns inside a quoted argument MUST NOT trigger.
#     Regression test for the "git commit -m '...rm -rf /...'" false positive.
echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"refactor: removed rm -rf / shortcut\""}}' \
  | bash "$P/hooks/git-guardian.sh" bash >/dev/null 2>&1
[ $? -eq 0 ]; check "allows quoted 'rm -rf /' inside commit message" $?

# 7h. NEW: '... && rm -rf /' as a chained command MUST be blocked.
echo '{"tool_name":"Bash","tool_input":{"command":"echo hi && rm -rf /"}}' \
  | bash "$P/hooks/git-guardian.sh" bash >/dev/null 2>&1
[ $? -eq 2 ]; check "blocks chained '&& rm -rf /'" $?

# 7i. NEW: 'echo "git push --force main"' MUST NOT trigger (string content).
echo '{"tool_name":"Bash","tool_input":{"command":"echo \"git push --force main\""}}' \
  | bash "$P/hooks/git-guardian.sh" bash >/dev/null 2>&1
[ $? -eq 0 ]; check "allows quoted 'git push --force main' as string" $?

section "Behavior: smart-router"
out="$(echo '{"prompt":"there is a bug in the parser causing a crash"}' \
  | bash "$P/hooks/smart-router.sh" 2>/dev/null)"
echo "$out" | grep -q '"hookSpecificOutput"'
check "emits hookSpecificOutput JSON" $?
echo "$out" | grep -q 'debug-detective'
check "routes 'bug' → debug-detective" $?

out="$(echo '{"prompt":"design the API schema for the new service"}' \
  | bash "$P/hooks/smart-router.sh" 2>/dev/null)"
echo "$out" | grep -q 'architect'
check "routes 'design' → architect" $?

# v4: route 'team' / 'parallel' → parallel-execution
out="$(echo '{"prompt":"split this work in parallel across multiple agents"}' \
  | bash "$P/hooks/smart-router.sh" 2>/dev/null)"
echo "$out" | grep -q 'parallel-execution'
check "routes 'parallel' → parallel-execution" $?

# v4: route 'benchmark' → self-improve
out="$(echo '{"prompt":"run the benchmark and score Mythos"}' \
  | bash "$P/hooks/smart-router.sh" 2>/dev/null)"
echo "$out" | grep -q 'self-improve'
check "routes 'benchmark' → self-improve" $?

# v4: route 'mcp' → mcp-orchestrator
out="$(echo '{"prompt":"use the mcp filesystem server to find a file"}' \
  | bash "$P/hooks/smart-router.sh" 2>/dev/null)"
echo "$out" | grep -q 'mcp-orchestrator'
check "routes 'mcp' → mcp-orchestrator" $?

section "Behavior: observability + session-state + precompact"
echo '{"session_id":"test","tool_name":"Read"}' \
  | bash "$P/hooks/observability.sh" "TestEvent" >/dev/null 2>&1
check "observability writes (no crash)" $?
[ -f "$MYTHOS_EVENTS_LOG" ] && grep -q '"event":"TestEvent"' "$MYTHOS_EVENTS_LOG"
check "TestEvent landed in events.jsonl" $?

bash "$P/hooks/session-state.sh" save </dev/null >/dev/null 2>&1
check "session-state save" $?
python3 -c "import json; json.load(open('$P/.claude/memory/last-session-state.json'))" 2>/dev/null
check "last-session-state.json valid JSON" $?

bash "$P/hooks/precompact-snapshot.sh" </dev/null >/dev/null 2>&1
check "precompact-snapshot run" $?
[ -s "$P/.claude/memory/precompact-snapshot.md" ]
check "precompact-snapshot.md non-empty" $?

# v4: self-eval appends a JSON row to eval-metrics.jsonl on SessionEnd.
section "Behavior: self-eval"
rm -f "$P/.claude/memory/eval-metrics.jsonl.preflight"
TMP_METRICS="$P/.claude/memory/eval-metrics.jsonl"
PRE_LINES=0
[ -f "$TMP_METRICS" ] && PRE_LINES=$(wc -l < "$TMP_METRICS" | tr -d ' ')
bash "$P/hooks/self-eval.sh" </dev/null >/dev/null 2>&1
check "self-eval runs without error" $?
POST_LINES=0
[ -f "$TMP_METRICS" ] && POST_LINES=$(wc -l < "$TMP_METRICS" | tr -d ' ')
[ "$POST_LINES" -gt "$PRE_LINES" ]
check "self-eval appended a metric row" $?
[ -f "$TMP_METRICS" ] && tail -1 "$TMP_METRICS" | python3 -c "import json,sys; json.loads(sys.stdin.read())" 2>/dev/null
check "self-eval row is valid JSON" $?

# v4: execution-monitor handles a duration_ms payload without crashing and writes nothing on small durations.
section "Behavior: execution-monitor"
echo '{"tool_name":"Bash","tool_input":{"command":"echo hello"},"duration_ms":42}' \
  | bash "$P/hooks/execution-monitor.sh" >/dev/null 2>&1
check "execution-monitor accepts duration_ms (no crash)" $?
echo '{"tool_name":"Bash","tool_input":{"command":"sleep 7"},"duration_ms":7000}' \
  | bash "$P/hooks/execution-monitor.sh" >/dev/null 2>&1
check "execution-monitor logs >5s commands (no crash)" $?

# ─── 8. Summary ───────────────────────────────────────────────────────────────
TOTAL=$((PASS+FAIL))
printf '\n──────────────────────────────────────\n'
if [ "$FAIL" -eq 0 ]; then
  printf '%s✓ ALL CLEAR%s — %d/%d checks passed\n' "$GRN" "$OFF" "$PASS" "$TOTAL"
  exit 0
else
  printf '%s✗ FAILURES%s — %d/%d failed\n' "$RED" "$OFF" "$FAIL" "$TOTAL"
  exit 1
fi
