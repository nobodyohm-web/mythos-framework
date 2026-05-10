# Lessons Learned — Agentic Autonomy

> This file is updated automatically after every user correction.
> Claude Code must review this file at session start and apply all patterns.
> Fed by: L3 Self-Improvement Loop (Rule #3) + L4 Journal Analyzer subagent.

---

## Format
Each lesson follows this structure:
```
### [DATE] — [SHORT TITLE]
**Mistake:** What went wrong
**Root Cause:** Why it happened
**Rule:** What to do instead (permanently)
```

---

<!-- Lessons will be appended below this line -->

### 2026-05-10 — CLAUDE.md is a budget, not a wishlist
**Mistake:** Initial CLAUDE.md was 268 lines including ascii diagrams, prose identity statements, and French verification blocks. Anthropic explicitly warns this causes Claude to ignore rules buried in noise.
**Root Cause:** Mistook comprehensiveness for clarity. Added everything that "felt useful" rather than only what changed Claude's behavior.
**Rule:** For every line in CLAUDE.md, ask "would removing this cause Claude to make a mistake?" If no → cut. Cap at 200 lines. Use `@imports` for detail; lazy-load via skills.

### 2026-05-10 — Hooks beat prompts for invariants
**Mistake:** Relying on CLAUDE.md instructions like "never commit secrets" — these are advisory and depend on model adherence.
**Root Cause:** Confused advisory text with deterministic enforcement.
**Rule:** Anything that MUST happen every time → hook. Anything that's situational → CLAUDE.md or skill. Defense-in-depth: layer both for critical invariants (e.g. force-push to main is denied in `permissions.deny` AND blocked by `git-guardian.sh`).

### 2026-05-10 — Test hooks with crafted stdin
**Mistake:** Past evolutions wrote hooks but never validated behavior end-to-end.
**Root Cause:** Assumed bash syntax check = working hook.
**Rule:** For every hook with branching logic, verify with `echo '{...}' | bash hooks/foo.sh; echo "exit=$?"`. Confirm both block-path (exit 2) and allow-path (exit 0). Bake these into `test-mythos.sh` over time.

### 2026-05-10 — Keep Bash(*) wildcard in permissions.allow
**Mistake:** /evolve replaced `Bash(*)` with 45 scoped commands (git, npm, bun...). Every unlisted command triggered a permission prompt, breaking autonomous flow.
**Root Cause:** Research said "wildcards defeat the safety classifier" — but the user explicitly wants ZERO permission prompts. The `deny` list already blocks dangerous operations (force-push, rm -rf /, secret reads).
**Rule:** ALWAYS keep `Bash(*)` in permissions.allow. Use `deny` list for security, NOT scoped allow. The deny list is the guardrail, not the allow list.

