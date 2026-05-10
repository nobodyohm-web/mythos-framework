---
name: tdd
description: Test-Driven Development cycle (Red → Green → Refactor). Use for new features, bug fixes, or any logic that can be expressed as input → output.
allowed-tools: Read Grep Glob Bash Edit Write
---

# 🧪 TDD — Red, Green, Refactor

> Write the test first. Watch it fail. Make it pass with the simplest code that works. Refactor without changing behavior.

## The Cycle

```
┌──────────┐    ┌──────────┐    ┌──────────┐
│ 1. RED   │───▶│ 2. GREEN │───▶│ 3. REFAC │
│ test     │    │ minimal  │    │ clean up │
│ fails    │    │ pass     │    │ no break │
└──────────┘    └──────────┘    └──────────┘
      ▲                              │
      └──────────────────────────────┘
            (next behavior)
```

## Phase 1 — RED (write the failing test)

1. **Pick the smallest behavior** to add. One assertion at a time when possible.
2. **Name the test for the behavior**, not the function: `it("returns null when user lacks permission")`, not `it("checkAuth")`.
3. **Arrange / Act / Assert** — three blocks, blank line between.
4. **Run it.** Confirm it fails for the *right reason* (not a typo, missing import, etc.).

```typescript
// Example
test("validateEmail rejects addresses without TLD", () => {
  // Arrange
  const input = "user@example";
  // Act
  const result = validateEmail(input);
  // Assert
  expect(result.valid).toBe(false);
  expect(result.error).toBe("MISSING_TLD");
});
```

If the test passes immediately, the behavior already exists or your assertion is wrong.

## Phase 2 — GREEN (simplest passing code)

1. Write the **minimum code** that passes the test. Even hardcoding `return false` is OK if that's all the test demands.
2. Resist the urge to "also handle…". Other behaviors get their own tests.
3. Run **only the new test** for fast feedback.
4. Then run the **full suite** — confirm no regression.

## Phase 3 — REFACTOR (improve without breaking)

With a green bar, you have permission to clean up:

- Extract duplication
- Rename for clarity
- Split long functions
- Improve types

After every change → re-run tests. If red, revert and try smaller.

**Never refactor without green tests as your safety net.**

## When TDD Doesn't Fit

- **Pure exploration / spike** — write throwaway code first, then rewrite with tests.
- **UI tweaks where visual diff is the spec** — use screenshot comparison instead.
- **One-line config changes** — TDD overhead exceeds benefit.

## Test Quality Bar

| Property | Required |
|---|---|
| Deterministic | No real network, no `Date.now()`, no `Math.random()` without seed |
| Isolated | Each test runs in any order, no shared mutable state |
| Fast | Unit tests <100ms each; integration tests <1s |
| Named for behavior | "returns 404 when..." not "test1" |
| One assertion concept | Multiple `expect` OK if same concept |

## Output Template

```
═══════════════════════════════════════════
  🧪 TDD CYCLE — <feature>
═══════════════════════════════════════════

📋 BEHAVIORS DRIVEN:
  ✅ <behavior 1> — test: <path>
  ✅ <behavior 2> — test: <path>
  ✅ <behavior 3> — test: <path>

📊 COVERAGE: XX% (target: ≥80% on new code)
🧪 TESTS: N new, all passing
♻️ REFACTORS: N safe refactors completed

CONFIDENCE: XX/100
═══════════════════════════════════════════
```
