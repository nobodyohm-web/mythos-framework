# Constitution — Mythos Sovereign Agentic System

> Immutable architectural principles. Loaded BEFORE CLAUDE.md every session.
> To modify: requires explicit user approval via `/specify` or direct edit.

---

## Non-Negotiable Principles

1. **Spec-first** — Never implement without a specification. Even a 3-line spec beats zero spec.
2. **Verify-before-ship** — Every change must pass typecheck + tests + manual diff review before declaring "done".
3. **Compound learning** — Every session must leave the system smarter than it found it (lessons, patterns, calibration).
4. **Minimal footprint** — Prefer editing existing files over creating new ones. Prefer small diffs over large rewrites.
5. **Research-before-guess** — Web search or codebase scan before any assumption about unfamiliar APIs, libraries, or patterns.
6. **Context survival** — Critical state (plan, progress, blockers) must be persisted to files before context compaction.

## Architectural Standards

### Code Organization
- Source code → `/src` or project-appropriate root
- Tests colocated as `*.test.{ts,py}` alongside source
- No circular imports — enforce acyclic dependency graph
- Single responsibility per file — one module, one concern

### Naming Conventions
| Element | Convention | Example |
|---------|-----------|---------|
| Files | `kebab-case` | `smart-router.sh` |
| Functions (TS/JS) | `camelCase` | `parseUserInput()` |
| Functions (Python) | `snake_case` | `parse_user_input()` |
| Types/Classes | `PascalCase` | `MarketAnalysis` |
| Constants | `SCREAMING_SNAKE` | `MAX_RETRY_COUNT` |
| Env vars | `SCREAMING_SNAKE` | `MYTHOS_MODE` |

### Forbidden Patterns
- ❌ `git push --force` to main/master — NEVER
- ❌ Committing secrets, `.env`, credentials, API keys
- ❌ `rm -rf /` or `rm -rf ~` — NEVER
- ❌ Global mutable state without explicit synchronization
- ❌ Swallowing errors silently (`catch {}` with no logging)
- ❌ Skipping verification phases — every phase is mandatory

### Quality Gates
- All code changes must pass: typecheck → tests → lint → security scan → diff review
- Confidence score must be logged after every significant action
- Below 70 confidence → explain WHY and what would raise it
- Two consecutive <70 → trigger `/evolve` self-improvement cycle

## Technology Defaults
- **Package manager**: `bun` > `npm` > `yarn`
- **TypeScript**: strict mode, no `any` without justification
- **Python**: type hints on all public functions
- **Shell**: `set -euo pipefail` in all scripts
- **Git**: conventional commits, atomic commits (one concern per commit)

## Delegation Rules
- Act autonomously on: code edits, refactors, bug fixes, clear-spec features
- Ask user on: architectural choices with multiple valid approaches, deleting significant code, changing public APIs
- NEVER: commit secrets, force-push to main, destructive filesystem operations

## Spec-Driven Development Protocol
When a task is non-trivial (3+ steps, multi-file, or architectural):
1. Create or reference `specs/{feature-slug}/spec.md` — the WHAT and WHY
2. If ambiguity exists and confidence < 90: clarify with user before planning
3. Create `specs/{feature-slug}/plan.md` — the HOW
4. Create `specs/{feature-slug}/tasks.md` — ordered, dependency-tagged task list
5. Execute tasks respecting dependency order and `[P]` parallel markers
6. Validate against spec acceptance criteria
7. Log results to `specs/{feature-slug}/review.md`
