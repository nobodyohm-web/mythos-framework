---
name: refactor
description: Safe refactoring with characterization tests. Use when restructuring code without changing observable behavior — extracting modules, renaming APIs, replacing patterns.
allowed-tools: Read Grep Glob Bash Edit
---

# ♻️ Refactor — Behavior Preservation Under Change

> Refactoring is changing the shape without changing the behavior. The test suite is your safety net. If the net has holes, weave it tighter before you jump.

## Pre-flight Checklist

Before touching any code:

1. **Characterization tests exist?** If not, write them first. They lock in current behavior — even if buggy. You refactor first, fix bugs separately.
2. **Tests are green?** Don't refactor on a red bar. Fix or skip failing tests first.
3. **VCS clean?** Commit or stash unrelated changes. You want a clean diff.
4. **Scope defined?** Write the goal in one sentence. "Extract auth logic into AuthService" beats "clean up auth code."

## The Refactoring Loop

```
1. Run tests → green
2. Make ONE small change
3. Run tests → must still be green
4. If red → revert (git checkout) and try smaller
5. Commit if change is meaningful
6. Repeat
```

**One concept per commit.** "Rename `usr` → `user` across handlers" is one commit. "Rename `usr` → `user` AND extract `UserService`" is two.

## Common Refactorings

| Refactoring | When |
|---|---|
| Extract Function | Block of code with single purpose appears ≥2 times OR a function exceeds ~30 lines |
| Extract Module/Class | Group of functions share state and concept |
| Rename | Identifier doesn't communicate intent |
| Inline | A trivial wrapper adds no value |
| Replace Conditional with Polymorphism | Long `if/else` or `switch` keyed on a type tag |
| Introduce Parameter Object | Function takes ≥4 related params |
| Replace Magic Number | A literal appears with implicit meaning |
| Decompose Conditional | Complex `if` predicate hides intent |

## Characterization Tests (when no tests exist)

If the existing code has no tests, write them BEFORE refactoring:

1. Identify inputs that exercise each branch (read the code, not the spec).
2. Run the code, capture actual output verbatim.
3. Write tests that assert the captured output — even if "wrong."
4. Now refactor; if tests stay green, behavior preserved.
5. Fix actual bugs in a separate commit, with the test updated to assert the corrected output.

## Safety Rails

- **Never combine refactor + feature** in one commit.
- **Never change public API** in a refactor commit (that's a deprecation, not a refactor).
- **Run the full suite**, not just adjacent tests — refactors have action at a distance.
- **If a refactor takes >2 hours without a green checkpoint**, you went too big. Revert; restart smaller.

## Output Template

```
═══════════════════════════════════════════
  ♻️ REFACTOR — <description>
═══════════════════════════════════════════

🎯 GOAL: <one sentence>
📋 SCOPE: <files touched>
🧪 SAFETY NET: <test files used>
📊 BEHAVIOR PRESERVED: ✅ all tests green
🚫 NO API CHANGES: ✅ confirmed
🚫 NO FEATURE CHANGES: ✅ confirmed
📝 COMMITS: N atomic refactors

CONFIDENCE: XX/100
═══════════════════════════════════════════
```

## Red Flags to Stop

- Tests broke and you "fixed" them by changing assertions → that's a behavior change, not a refactor
- Diff is hard to review → you bundled too much
- You can no longer state in one sentence what changed
