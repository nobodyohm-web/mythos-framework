# Spec 009 — v6.1 "Reasoning Revolution"

> Status: specifying → planned
> Created: 2026-05-21
> Author: Mythos main (under /mythosrun)
> Parent: Spec 007 (v6.0 Reasoning Monster — CoVe + SC)

## Problem Statement

v6.0 shipped **within-attempt** reasoning primitives (CoVe, SC) and made Mythos production-ready (LICENSE, CI, docs). What's still missing:

1. **No cross-attempt memory.** When Mythos fails on attempt N and tries again, attempt N+1 has no record of *why* N failed. We only persist post-session lessons (manual, slow). Reflexion (arXiv:2303.11366) closes this gap with verbal RL: write a reflection on failure, prepend it to the next attempt.

2. **Compute is non-adaptive.** SC always samples N traces regardless of difficulty. CoVe always runs the full 4-stage cycle even when the draft was correct. Snell et al. (arXiv:2408.03314) show >4× efficiency from routing easy tasks to BoN and hard tasks to sequential revision.

3. **CoVe is single-shot.** The Dhuliawala paper's protocol does one revision pass. Self-Refine (arXiv:2303.17651) shows that iterative critique-revise loops gain ~20% across 7 tasks, plateauing around 3-4 iterations.

These are not catalog-padding. They're three named failure modes with peer-reviewed solutions.

## Functional Requirements

### FR1 — Episodic memory CLI `bin/mythos-reflexion`
Implements the Reflexion verbal-RL loop (arXiv:2303.11366, NeurIPS 2023).

**Storage**: `.claude/memory/reflexion/<task>.jsonl` — append-only, one reflection per line, JSON `{ts, attempt, outcome, reflection, tier}`.

**Subcommands**:
- `record <task-id> <attempt-n> <outcome> <reflection-file|->` — append reflection. Outcome ∈ {success, failure, partial}. Tier = D (reflections are derived from observed outcomes).
- `recall <task-id> [--last N]` — print last N reflections as markdown (default N=3, ready for context injection).
- `list` — enumerate tasks with reflections + count.
- `clear <task-id>` — wipe one task's history (testing only).

**Tier discipline**: reflections are tier D (Derived from observed failure). Tier C if outcome=partial.

### FR2 — Adaptive Best-of-N CLI `bin/mythos-bestofn`
Implements Snell et al. compute-optimal routing (arXiv:2408.03314).

**Storage**: `.claude/state/bestofn/<task>.json` — `{question, difficulty, recommended_n, candidates: [{id, content, score}], best_id, ts}`.

**Subcommands**:
- `init <task-id> <prompt-file|-> --difficulty=1-5` — record task + difficulty + compute recommended N (1=1, 2=2, 3=4, 4=8, 5=16). Caller sets difficulty (heuristic prompt) or omits to default to 3.
- `record <task-id> <candidate-file|-> <score>` — append a candidate with verifier score (0-100).
- `choose <task-id>` — print highest-scoring candidate as JSON `{id, score, content}`.
- `status <task-id>` — show recommended_n vs recorded count + score distribution.

**Tier discipline**: recommended_n is C (heuristic-derived). Chosen winner is D if agreement is high (top score ≥ 2nd by 10+), else C.

### FR3 — `mythos-cove --iterations N` flag
Implements Self-Refine via CoVe iteration (arXiv:2303.17651).

`bin/mythos-cove revise <task-id> <file> [--iterations N]`:
- N=1 (default) → existing behavior.
- N>1 → after writing the revised stage, the caller can call `revise` N-1 more times; each subsequent call writes `revised-2`, `revised-3`, … into blackboard topics.
- Convergence detection: if `revised-K` content is identical (byte-for-byte after strip) to `revised-K-1`, the next `revise` call exits 0 with stderr "✓ converged at iteration K-1" and does NOT write.
- `show` and `status` enumerate all `revised-*` topics.

### FR4 — Skills with paper citations
- `skills/reflexion.md` — when to record reflections, anti-patterns (don't reflect on success of trivial tasks), how to inject recalled reflections.
- `skills/best-of-n.md` — when BoN beats SC (discrete answers, single shot), when BoN beats CoVe (long-form scoring possible), Snell routing rule.

### FR5 — Slash commands
- `.claude/commands/reflexion.md` — thin wrapper.
- `.claude/commands/bestofn.md` — thin wrapper.

### FR6 — Platform integration (minimal, safe)
- `hooks/_lib.sh`: add helpers `mythos_session_id()` (echoes `$CLAUDE_CODE_SESSION_ID`) and `mythos_effort()` (echoes `$CLAUDE_EFFORT` or "default"). Safe: empty if env unset.
- CLAUDE.md: 3-line section marking `/goal`, `/ultrareview`, `/effort xhigh` as native Claude Code primitives `[C]` (researcher-verified URLs; we don't reimplement them).

### FR7 — Self-test extensions
`hooks/test-mythos.sh` adds section **7h. v6.1 — Reflexion + Best-of-N + CoVe iterations**. Each AC has a corresponding test.

### FR8 — Registry + docs
- `specs/registry.json` adds entry 009 with status=implemented after acceptance.
- `CHANGELOG.md` adds v6.1.0 entry under "Unreleased".
- `PAPERS.md` adds Reflexion, Self-Refine, Snell papers.
- `BENCHMARKS.md` adds the new test count.

## Acceptance Criteria

- [ ] AC-01: `bin/mythos-reflexion record/recall/list/clear` round-trips through `.claude/memory/reflexion/<task>.jsonl`.
- [ ] AC-02: `bin/mythos-reflexion recall --last 3` returns the 3 most recent reflections in markdown form.
- [ ] AC-03: `bin/mythos-reflexion record` rejects task-id with shell metacharacters (exit 64).
- [ ] AC-04: `bin/mythos-bestofn init` accepts difficulty 1-5 and computes recommended_n ∈ {1,2,4,8,16}.
- [ ] AC-05: `bin/mythos-bestofn choose` returns the highest-scoring recorded candidate as JSON.
- [ ] AC-06: `bin/mythos-bestofn` rejects difficulty outside 1-5 with exit 64.
- [ ] AC-07: `bin/mythos-cove revise --iterations 1` is equivalent to existing single-pass revise (backward compatible).
- [ ] AC-08: `bin/mythos-cove revise --iterations 3` with 2 identical revisions in a row triggers "converged" message and stops writing.
- [ ] AC-09: `skills/reflexion.md` and `skills/best-of-n.md` exist with arXiv citations.
- [ ] AC-10: `.claude/commands/reflexion.md` and `.claude/commands/bestofn.md` exist.
- [ ] AC-11: `hooks/_lib.sh` exposes `mythos_session_id` and `mythos_effort` helpers that work whether env is set or unset.
- [ ] AC-12: `hooks/test-mythos.sh` passes 100% with ≥10 new checks for v6.1 primitives.
- [ ] AC-13: CLAUDE.md remains ≤ 150 lines (hard cap) with the new content.
- [ ] AC-14: CHANGELOG.md has a v6.1.0 entry with conventional format.
- [ ] AC-15: PAPERS.md cites arXiv:2303.11366, 2408.03314, 2303.17651.

## Out of Scope (explicit, with reasons)

- **MCTS upgrade to bin/mythos-tot** — researcher 3 recommends spike-first; deferred to v6.2.
- **Process Reward Model** — both researchers reject without a training pipeline; zero-shot PRM underperforms by ~15pp.
- **Multi-Agent Debate** — researcher 3 explicitly: gain over existing SC is unquantified from available sources; effort is L.
- **Plugin manifest packaging** — L effort; deferred. Requires plugin lifecycle testing.
- **New Claude Code hook types** (mcp_tool, http, args:[] exec form, continueOnBlock, terminalSequence) — unverified by me; risk of silent failure if researcher 2's WebFetch findings were inaccurate. Defer until I can independently WebFetch.
- **UserPromptSubmit replacement of smart-router** — refactor with no functional gain; defer.
- **claude agents --json replacement of fleet polling** — works correctly today; not broken, not fixing.
- **Constitutional AI 2025 alignment improvements** — researcher 1 noted these address safety, not reasoning quality.

## Dependencies

- `bin/mythos-blackboard` (existing) — backend for state storage.
- `hooks/_lib.sh:mythos_lock_acquire` (existing) — per-task lock primitive.
- jq, python3 (already required).

## Risk

- **Reversibility**: HIGH. All new files. Removing them restores v6.0 state.
- **Blast radius**: 3 new CLIs, 1 modified CLI (cove --iterations flag), 2 new skills, 2 new commands, 1 _lib.sh addition, test extensions. CLAUDE.md gets ≤5 lines added.
- **Bus factor**: documented in skills with paper citations; each CLI has a self-describing usage docstring.

## Confidence

Pre-implementation: 90/100 🟢 — scope is paper-backed, follows v6.0 patterns, and is properly bounded. The platform-integration items in Wave B are minimal and tier-tagged [C] for honesty.
