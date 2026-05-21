## Summary

One or two sentences. What changed, why.

## Type

- [ ] Bug fix (non-breaking)
- [ ] New skill / agent / CLI / hook
- [ ] Refactor (no behavior change)
- [ ] Documentation
- [ ] Breaking change (file layout, CLI flags, or hook contract)

## Checklist

- [ ] `bash hooks/test-mythos.sh` reports `✓ ALL CLEAR` after this PR.
- [ ] If I added behavior, I added tests for it.
- [ ] If I added a CLI / hook / skill / agent, I cited the paper or named the engineering principle behind it (see `PAPERS.md`).
- [ ] I've tagged claims with epistemic tiers `[E] [D] [C] [S]` where appropriate (no inflated confidence).
- [ ] `CHANGELOG.md` updated (under `Unreleased` or the next version).
- [ ] If I added a new file, it follows the naming convention from `constitution.md`.
- [ ] If I added a new dependency, I justified it in the PR description.

## How I tested

```bash
# the exact commands you ran
```

## Risk

- **Reversibility:** can this change be reverted cleanly? Yes / No.
- **Blast radius:** which files / hooks / commands does this affect?
- **Bus factor:** does this introduce a single point of failure?

## Screenshots / output (optional)

If your change is visible (CLI output, a new command, etc.), paste a `bash`-block of the before/after.

## Related issues / PRs

Closes #
Related to #
