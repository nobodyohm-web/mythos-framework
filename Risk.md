# Risk Rules — Mythos Guardrails

> Imported by `CLAUDE.md` via `@Risk.md`. These rules apply to **every** session.

---

## Epistemic Risk (Anti-Drift)

| Rule | Enforcement |
|------|-------------|
| Never inflate confidence. Use the Epistemic Tier System. | Evaluated during `/reflect` |
| Never verify your own complex code without a fresh context. | Use `/critique` or `reviewer` subagent |
| Never cite a source without verifying its existence. | `skills/epistemic-rigor.md` |
| If a test fails, do not blindly alter the test to make it pass. | `debug-detective.md` |

## Code Risk

| Rule | Enforcement |
|------|-------------|
| Never commit `.env`, `.env.*`, secrets, credentials, `*.pem`, `*.key` | `permissions.deny` + `git-guardian.sh` |
| Never `git push --force` (or `-f`) to `main` / `master` | `permissions.deny` + `git-guardian.sh` |
| Never `--no-verify` to skip git hooks | `git-guardian.sh` blocks |
| Never `rm -rf /`, `rm -rf ~`, `rm -rf $HOME` | `permissions.deny` + `git-guardian.sh` |
| Never amend a published commit | CLAUDE.md OPERATING MODE |

## Confidence Risk

- **<70 confidence** → explain WHY and what would raise it. Do not ship without review.
- **Two consecutive <70** → suggest `/evolve`.
- Log every significant action's confidence to `tasks/confidence-log.md`.

## Operational Risk

- Test hooks behaviorally with crafted stdin before wiring.
- Validate every JSON config with `python3 -c "import json; json.load(open(P))"` before commit.
- Self-test (`hooks/test-mythos.sh`) must be green before any `/evolve` commit.
- CLAUDE.md ≤ 150 lines, hard cap. Move detail to skills.
