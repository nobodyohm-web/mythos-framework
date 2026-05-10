---
name: code-review
description: Multi-dimensional code review checklist. Use before any commit ≥10 lines, before PRs, or when invoked as a Reviewer subagent.
allowed-tools: Read Grep Glob Bash
---

# 🔍 Code Review — Staff Engineer Standard

> "Would Anthropic ship this PR?" If no, iterate.

## Phase 1 — Context

1. Read the diff: `git diff` or `git diff --cached`.
2. Read the full file for each changed area (don't review snippets in isolation).
3. Identify the stated goal (PR description, ticket, or task prompt).

## Phase 2 — Five-Dimension Pass

### 1. Correctness
- Does the change actually solve the stated problem?
- Edge cases: empty input, null/undefined, max-size, unicode, concurrent calls?
- Off-by-one, fencepost, integer overflow?
- Time zones, daylight saving, leap year, leap second?
- Floating-point comparison without epsilon?

### 2. Security
- Untrusted input validated/sanitized at boundary?
- No SQL injection (parameterized queries)?
- No XSS (output encoding)?
- No path traversal (resolve + check prefix)?
- No hardcoded secrets, tokens, keys?
- Auth checks on every privileged endpoint?
- Rate limiting on outbound calls?

### 3. Quality
- Zero `any` (TypeScript) / untyped variables (Python)?
- Functions ≤50 lines? Cyclomatic complexity ≤10? Nesting ≤3?
- DRY: any copy-pasted block ≥5 lines that should be extracted?
- Dead code, unused imports, commented-out blocks?
- Names communicate intent without comments?

### 4. Resilience
- Network calls have timeouts (10-15s default)?
- Retries with exponential backoff for idempotent ops?
- Errors logged with enough context to diagnose post-mortem?
- Graceful degradation on dependency failure?
- No silent `catch (_) {}`?

### 5. Tests
- Each new branch covered?
- Regression test for any bug fixed?
- Tests deterministic (no real network, no random without seed)?
- Test names describe behavior, not implementation?

## Phase 3 — Run Verification

```bash
bun run typecheck
bun test
npx eslint . --quiet || true
git diff --cached --name-only | grep -E '\.(env|key|pem)' && echo "SECRETS STAGED" && exit 1
```

## Phase 4 — Verdict

| Verdict | Criteria |
|---|---|
| ✅ APPROVE | All five dimensions pass; no concerns |
| 🟡 APPROVE WITH NITS | Passes; minor style/naming notes |
| 🟠 REQUEST CHANGES | One dimension has a real issue |
| 🔴 REJECT | Critical security/correctness flaw |

## Output Template

```
═══════════════════════════════════════════
  🔍 CODE REVIEW — <PR/branch>
═══════════════════════════════════════════

📊 SCORES:
  Correctness:  XX/100
  Security:     XX/100
  Quality:      XX/100
  Resilience:   XX/100
  Tests:        XX/100

🔴 BLOCKERS:
  1. <file>:<line> — <issue>

🟡 SUGGESTIONS:
  1. <file>:<line> — <suggestion>

🟢 STRENGTHS:
  1. <what's done well>

VERDICT: ✅ APPROVE | 🟡 NITS | 🟠 CHANGES | 🔴 REJECT
═══════════════════════════════════════════
```

## Anti-Patterns to Flag

- "Just a quick fix" with no test
- New abstraction with one caller
- Silent error swallow (`catch { /* ignore */ }`)
- `// TODO` without ticket reference
- Magic number without named constant
- Mutable global state
