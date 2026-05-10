---
name: debug-detective
description: Systematic debugging — Reproduce → Isolate → Fix → Immunize. Use whenever a bug is reported, a test fails, or behavior is unexpected.
allowed-tools: Read Grep Glob Bash Edit
---

# 🔬 Debug Detective — Root-Cause-First Bug Hunting

> **Bugs are not random.** Every bug has a cause; every cause has a fix; every fix has a test that prevents regression.

## Phase 1 — REPRODUCE (≤ 5 minutes)

Goal: shrink the bug to the smallest reliable repro.

1. **Capture the failure verbatim.** Stack trace, error message, exit code, screenshot. No paraphrase.
2. **Isolate inputs.** What inputs trigger it? What inputs do not?
3. **Determinism check.** Does it fail every time, or intermittently? If intermittent → log timing, ordering, concurrency.
4. **Minimal repro.** Reduce to fewest lines / smallest dataset that still fails. If you can't make a minimal repro, you don't understand the bug yet.

**Output:** A failing test or one-liner shell command that demonstrates the bug.

---

## Phase 2 — ISOLATE (root cause, not symptom)

1. **Read `tasks/lessons.md`** — has this bug pattern occurred before?
2. **Bisect.** Git: `git bisect start && git bisect bad HEAD && git bisect good <known-good>`. Code: comment out half, observe, repeat.
3. **Trace the data flow.** Where does the bad value enter the system? Where does it first diverge from expected?
4. **Check assumptions.** What is your code assuming about input shape, timing, ordering, null-ness, encoding? List them; verify each.
5. **Read adjacent code.** The bug may be in a caller, a config, or an environment variable, not the obvious file.

**Stop conditions:**
- ✅ You can explain in one sentence WHY the bug happens.
- ❌ You can only explain WHAT happens — keep digging.

**Anti-pattern:** "It works now, I'm not sure why." → DO NOT proceed. Either you understand it or it is not fixed.

---

## Phase 3 — FIX (minimal & elegant)

1. **Smallest fix that addresses the root cause.** Not the symptom.
2. **Follow existing patterns** in the codebase — don't introduce new abstractions for a one-line fix.
3. **No try/catch hiding.** Catching and silently swallowing the error is not a fix.
4. **No defensive bloat.** Don't add validation for cases that genuinely cannot happen.
5. **One concept per commit.** If the fix needs 3 changes, that's 3 commits (or one labeled commit explaining the dependency).

---

## Phase 4 — VERIFY

```bash
# Run the failing test → must now pass
bun test path/to/repro.test.ts

# Run the full suite → no regressions
bun test

# Typecheck
bun run typecheck
```

If anything else breaks → STOP. The fix has unintended consequences. Either expand the fix or rethink it.

---

## Phase 5 — IMMUNIZE (prevent recurrence)

1. **Add a regression test** that fails before the fix and passes after. Commit alongside the fix.
2. **Append to `tasks/lessons.md`:**
   ```
   ### YYYY-MM-DD — <Short title>
   **Mistake:** <what broke>
   **Root Cause:** <one-sentence why>
   **Rule:** <permanent prevention>
   ```
3. **Consider a hook.** If this class of bug could be caught mechanically (lint rule, type narrowing, pre-commit scan), add it.

---

## Output Template

```
═══════════════════════════════════════════
  🔬 DEBUG REPORT — <bug-id or short title>
═══════════════════════════════════════════

🔁 REPRODUCED: <one-line repro>
🎯 ROOT CAUSE: <one sentence>
🔧 FIX: <files changed, lines>
🧪 TEST ADDED: <test path>
📚 LESSON LOGGED: <lessons.md entry>
✅ VERIFIED: typecheck ✓ | tests ✓ | regressions: none

CONFIDENCE: XX/100
═══════════════════════════════════════════
```
