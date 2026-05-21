# Mythos — Benchmarks

This document tracks Mythos's measurable claims. Numbers are reproducible; the commands are below the numbers.

## Self-test suite

The single source of truth for whether the framework is working.

| Version | Checks | Pass | Date |
|---------|--------|------|------|
| 6.1.0 | 309 | **309 (100%)** | 2026-05-21 |
| 6.0.0 | 274 | 274 (100%) | 2026-05-21 |
| 5.5.0 | 251 | 251 (100%) | 2026-05-20 |
| 5.4.0 | 234 | 234 (100%) | 2026-05-20 |
| 5.2.0 | 218 | 218 (100%) | 2026-05-18 |

**Reproduce:**
```bash
bash hooks/test-mythos.sh
# → ✓ ALL CLEAR — 309/309 checks passed
```

Tests cover: file layout, hook wiring, JSON validity, frontmatter on every agent, guard behavior under crafted inputs, marketplace CLIs, registry shape, dry-run install safety, token-optim CLIs, the subagent model policy (8 on Opus, 1 on Sonnet), the fleet safety contract (help text, dispatch error paths, exit codes, env isolation, state-dir lifecycle), CoVe state machine + iterations + convergence, Self-Consistency vote logic, Reflexion record/recall/tier discipline, Best-of-N init/record/choose/margin→tier, and `_lib.sh` env-var helpers.

## Defensive hook behavior

Each hardening hook has a crafted test input. Numbers below are caught-vs-attempted on those inputs.

| Hook | Class | Crafted inputs | Caught | Notes |
|------|-------|----------------|--------|-------|
| `git-guardian.sh` | Irreversible op blocker | 14 | 14 (100%) | `--force` to main, `--no-verify`, `rm -rf /`, secret commits |
| `hallucination-guard.sh` | Tool-path hallucination | 9 | 9 (100%) | nonexistent cat/bash/python3 targets, redirects |
| `prompt-injection-guard.sh` | Indirect injection | 6 | 6 (100%) | "ignore previous instructions", ChatML tags, `<system>` blocks |
| `agent-guard.sh` | Command-repeat loop | 3-repeat threshold | warns at N≥3 | ring buffer + jq lookup |

**Reproduce:** the input files live in `hooks/test-fixtures/` and the assertions in `hooks/test-mythos.sh` (`── Behavior: <guard> ──` sections).

## Token economy claims

The output-side claim "~65% reduction with terse mode" is derived from internal session comparisons, not an external benchmark. To re-measure on your own workload:

```bash
# Baseline (no terse mode)
bin/mythos-tokens session

# Run same task with /terse activated
# Then:
bin/mythos-tokens session
```

The provider-side claim (running through `claude-code-router` to OpenRouter/DeepSeek/Ollama) does *not* preserve Claude's reasoning quality. We say so explicitly in `skills/free-claude-code-assessment.md` — labeled `[D]` derived from comparison runs on architectural tasks, not `[E]`.

## What we do NOT claim

- **No SWE-bench number.** We have not run the full SWE-bench benchmark. The `benchmark/` directory contains scaffolding and a vulnerable-app harness, but the public claims do not include a SWE-bench leaderboard position.
- **No "X% fewer hallucinations" number.** The hallucination-guard reduces a *specific failure mode* (path-existence errors in Bash commands). We have not run a controlled study comparing total hallucination rate with vs without Mythos.
- **No "Y% faster development" number.** Marketing language we will not put in this file: "10x faster", "AI-native", "next-generation". If we can't measure it, we don't claim it.

## How to add a benchmark

If you want to contribute a benchmark:

1. Define what's measured, with what command, on what input.
2. Run it 3 times — Mythos numbers are medians, not best-of.
3. Document the environment (OS, bash version, Python version).
4. Open a PR that adds the row to this file AND the harness to `benchmark/cases/`.

We refuse benchmarks where the input is curated by the author. If you want to ship a real number, use a public dataset or a fixed-seed synthetic input.
