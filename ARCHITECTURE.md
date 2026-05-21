# Mythos — Architecture

This document explains how Mythos is structured, why each layer exists, and how data flows through a session.

## The 7 layers

```
┌─────────────────────────────────────────────────────────────────┐
│  L0 — CONSTITUTION (constitution.md, Risk.md)                   │
│  Immutable principles. Loaded BEFORE every session.             │
└─────────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────────┐
│  L1 — OPERATING MODE (CLAUDE.md)                                │
│  Epistemic tier system, terse-by-default, batch-by-default.     │
└─────────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────────┐
│  L2 — SKILLS (skills/*.md, loaded on demand)                    │
│  Domain knowledge: epistemic-rigor, debug-detective, refactor,  │
│  chain-of-verification, self-consistency, tot, gvu, ...         │
└─────────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────────┐
│  L3 — COMMANDS (.claude/commands/*.md)                          │
│  Slash workflow controllers: /mythosrun, /critique, /team,      │
│  /cove, /sc, /assimilate, /marketplace, ...                     │
└─────────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────────┐
│  L4 — SUBAGENTS (.claude/agents/*.md)                           │
│  Delegation roster (9): planner, architect, researcher,         │
│  implementer, tester, reviewer, debugger, optimizer,            │
│  security-auditor. 8 on Opus, 1 (researcher) on Sonnet.         │
└─────────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────────┐
│  L5 — NATIVE CLIs (bin/mythos-*)                                │
│  18 deterministic CLIs that hold state on disk:                 │
│  blackboard, gvu, tot, cove, sc, research, reflect, budget,     │
│  tokens, fleet, calibrate, observe, route, detect, ...          │
└─────────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────────┐
│  L6 — HOOKS (hooks/*.sh)                                        │
│  Deterministic defenses on every lifecycle event:               │
│  git-guardian, hallucination-guard, prompt-injection-guard,     │
│  agent-guard, smart-router, verify-completion, auto-learn, ...  │
└─────────────────────────────────────────────────────────────────┘
```

## Data-flow lifecycle

A single user prompt traverses every layer:

```
user prompt
   │
   ▼
[SessionStart hook]   ──▶ load lessons.md, restore session-state
   │
   ▼
[UserPromptSubmit hook] ──▶ smart-router suggests skill
   │
   ▼
Model receives prompt + context
   │
   ▼
Tool call (Bash, Edit, Read, WebFetch, ...)
   │
   ▼
[PreToolUse hook]
   ├─ git-guardian (Bash) ──▶ block force-push, secrets, rm -rf /
   └─ hallucination-guard (Bash) ──▶ warn nonexistent paths
   │
   ▼
Tool executes
   │
   ▼
[PostToolUse hook]
   ├─ agent-guard ──▶ detect command-repeat loops
   ├─ context-guardian ──▶ checkpoint state if approaching limit
   ├─ error-recovery ──▶ auto-suggest fix on common errors
   └─ prompt-injection-guard (Read / WebFetch) ──▶ scan response
   │
   ▼
Model continues …
   │
   ▼ (eventually)
[Stop hook] ──▶ verify-completion (typecheck, tests, diff review)
[SessionEnd hook] ──▶ auto-learn (extract lesson if applicable)
                  ──▶ self-eval (score the session)
```

## State that survives across sessions

Mythos is "communicate through files, not shared context":

| Where | What | Owner |
|-------|------|-------|
| `tasks/lessons.md` | Append-only learnings. Loaded on SessionStart. | `learn`, `auto-learn` |
| `tasks/confidence-log.md` | Per-action confidence + outcome. Feeds `/calibrate`. | every workflow command |
| `tasks/session-journal.md` | One paragraph per `/mythosrun`. | `/mythosrun`, `/reflect` |
| `.claude/memory/patterns.json` | Self-improvement state. | `/evolve`, `/calibrate` |
| `.claude/memory/exec-metrics.jsonl` | Per-tool execution metrics. | hooks |
| `.claude/state/blackboard/*.jsonl` | Cross-agent durable state, tier-tagged. | `bin/mythos-blackboard` |
| `.claude/state/cove/*.json` | Chain-of-Verification state machines. | `bin/mythos-cove` |
| `.claude/state/sc/*.json` | Self-Consistency vote bundles. | `bin/mythos-sc` |
| `.claude/state/tot/*.json` | Tree-of-Thoughts node states. | `bin/mythos-tot` |
| `.claude/state/gvu/*.json` | Generator-Verifier-Updater triads. | `bin/mythos-gvu` |
| `.claude/state/fleet/*.json` | Worker registries + budgets. | `bin/mythos-fleet` |
| `specs/{id}-{slug}/{spec,plan,tasks,review}.md` | Spec-driven dev artifacts. | `/specify`, `/mythosrun` |

## Why "everything on disk"?

Two failure modes Mythos is designed against:
1. **Context drift** — long sessions lose decisions made early.
2. **Inter-agent telephone** — subagent A → orchestrator → subagent B loses raw evidence at each hop.

Both are solved by writing structured artifacts to disk and reading them from a fresh context, not by trusting the model to remember.

## The 5 Anthropic Principles, mapped to the codebase

| Principle | Where it lives |
|-----------|---------------|
| Separate the judge from the builder | `/critique`, `reviewer` subagent, `bin/mythos-gvu` |
| Define success before writing code | `specs/{slug}/spec.md`, constitution.md |
| Communicate through files, not shared context | `bin/mythos-blackboard`, `tasks/*.md`, all `.claude/state/` |
| Calibrate your evaluator relentlessly | `/calibrate`, `bin/mythos-calibrate`, `confidence-log.md` |
| Prefer reversible actions over irreversible ones | `hooks/git-guardian.sh`, fleet `--bare` mode, no auto-merge |

## Bus factor and trust

Mythos ships with no maintained external dependencies beyond `bash`, `jq`, `python3`, and `git`. Every CLI auto-bootstraps its Python deps via a project `.venv` when needed. The registry HEAD-probes URLs before write, and SHA-256-pins on request.

This is intentional: the framework's value is the *discipline*, not the *code volume*. If you fork Mythos and drop half the CLIs, you still have the constitution, the hooks, the epistemic-tier system, and the spec-driven workflow. Those are the load-bearing parts.
