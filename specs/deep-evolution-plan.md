# Deep Evolution Plan — Mythos v5.0 → v5.1

**Date:** 2026-05-18
**Tier markers:** [E] Established · [D] Derived · [C] Conjectured · [S] Speculative

---

## North Star
Bring Mythos from a competent agentic base to a **calibrated, loop-resistant, blackboard-coordinated** system that enforces the Epistemic Tier System at runtime and produces measurable self-evaluation signals.

## Diagnosis (from `bin/mythos-reflect` + manual inspection)

| Strength | Weakness |
|---|---|
| Solid hook lifecycle (`_lib.sh`, lifecycle wiring) | No agent-loop / repetition detector ([E] AgentGuard pattern absent) |
| `git-guardian` + permissions deny block destructive ops | No epistemic-tier presence check on assistant claims |
| `auto-learn` tracks lessons & sessions | `confidence-log.md` is write-only — no calibration scoring |
| `bin/mythos-research` exists | Broken deps in fresh env; uses deprecated `duckduckgo_search`; no cache |
| `events.jsonl` written by `observability.sh` | No aggregator / dashboard CLI |
| 11 skills + 9 subagents | No blackboard primitive for durable cross-agent handoff |
| `MYTHOS_VERSION=5.0` declared in settings.json | No corresponding v5.1 invariants enforced in `test-mythos.sh` |

## Upgrade Phases

### Phase 4.A — Research CLI v2 [P0]
- Auto-bootstrap (already in place from this session): re-exec under `.venv` if deps missing.
- Replace `duckduckgo_search` import path with the renamed `ddgs` package (graceful fallback to legacy name).
- Add `--cache` flag → write/read JSONL cache at `.claude/memory/research-cache.jsonl` (key = sha1(query+limit+fetch)).
- Retry once with `safesearch=off` if first call returns empty.
- File: `bin/mythos-research`

### Phase 4.B — AgentGuard loop detector [P0]
- Hook: `hooks/agent-guard.sh` (PostToolUse, Bash matcher).
- Tracks last 20 Bash commands in `.claude/memory/exec-ring.jsonl` (ring buffer).
- If the same exact command repeats ≥3 times within the last 10 entries, emit a stderr warning + `hookSpecificOutput` additional context flagging a probable loop.
- File: `hooks/agent-guard.sh` (new) + wire into settings.json PostToolUse.

### Phase 4.C — Epistemic Gate [P1]
- CLI: `bin/mythos-epistemic-check` — given a markdown file path, scans for confident assertions (heuristic: paragraphs containing "is", "will", "must", "always") and reports which ones lack a [E]/[D]/[C]/[S] tier marker.
- Returns JSON: `{ scanned, untagged_count, untagged_lines: [...] }`.
- Not wired as a blocking hook (would be too noisy); usable from `/reflect` and `/critique`.

### Phase 4.D — Calibration scorer [P0]
- CLI: `bin/mythos-calibrate` — reads `tasks/confidence-log.md`, computes Brier score & calibration buckets (0–49, 50–69, 70–89, 90–100) from rows where outcome is also recorded.
- Writes summary to `.claude/memory/calibration.json` and updates `patterns.json.calibration`.

### Phase 4.E — Blackboard primitive [P1]
- CLI: `bin/mythos-blackboard` — sub-commands `write`, `read`, `list`, `clear`.
- Store: `.claude/state/blackboard/<topic>.json` (one file per topic; atomic write via temp+rename).
- Each entry: `{ ts, agent, topic, payload, tier }`.
- Skill: `skills/blackboard.md` documents handoff pattern for parallel agents.

### Phase 4.F — Observability dashboard [P2]
- CLI: `bin/mythos-observe` — aggregates `events.jsonl` and produces text dashboard:
  - top 10 event types
  - tool-error rate
  - last loop warning
  - last block reason
  - last 5 session timestamps

### Phase 4.G — Tests + Constitution updates [P0]
- Extend `hooks/test-mythos.sh` with behavior tests for `agent-guard.sh` and unit tests for the new CLIs.
- Bump `patterns.json.version` → `"5.1"` and seed `evolutionHistory[0]` with this leap's summary.
- Append a lesson to `tasks/lessons.md` documenting the SOTA patterns adopted.
- Optional CLAUDE.md cross-reference of new CLIs (under L3 commands table if any new slash commands are added — none in this leap).

## Out of scope
- Replacing MCP servers (kept as-is; they aren't the bottleneck).
- Adding new subagents (existing 9 cover the needed roles).
- Changing the global lifecycle wiring (only additive).

## Acceptance criteria (Define Success Before Writing Code)
- `bash hooks/test-mythos.sh` → ALL CLEAR with the new tests included.
- `./bin/mythos-research -q "test" --limit 1 --cache` returns non-empty JSON the first time and uses the cache the second time.
- `./bin/mythos-calibrate` runs without error even on empty input and prints a JSON summary.
- `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | bash hooks/agent-guard.sh` exits 0 and writes a ring entry.
- Repeating the same command 3 times produces a loop warning on stderr.
- `./bin/mythos-blackboard write foo '{"k":"v"}'` followed by `read foo` returns the payload.
- `./bin/mythos-observe` prints a non-empty dashboard.
- `patterns.json.version == "5.1"` with the evolution entry seeded.
- Reviewer-subagent verdict = APPROVE (Kill Gate).
