

## Mythosrun — 2026-05-20 v6.0 Reasoning Monster
### Task: User challenged: "Ollama apporte vraiment quelque chose de plus ? si non retire ollama, et fais des recherches profonde, etudie, MIT github et améliore en profondeur encore une ingenerie incroyable pour que claude code soit un monstre de resonnement"
### Spec: specs/007-reasoning-monster/
### Outcome: SUCCESS
### Summary: Anti-sycophancy verdict: Ollama integration (v5.6) is theater. Reverted (commit 22dd899). Pivoted to research-backed reasoning primitives. Added Chain-of-Verification (`bin/mythos-cove`) + Self-Consistency (`bin/mythos-sc`) as state machines. Both cite peer-reviewed ACL/ICLR papers. Self-test 274/274.
### Files Changed: bin/mythos-cove, bin/mythos-sc, skills/chain-of-verification.md, skills/self-consistency.md, .claude/commands/cove.md, .claude/commands/sc.md, specs/007-reasoning-monster/{spec,review}.md, CLAUDE.md (+4 lines, 147/150), registry/skills.json, specs/registry.json, hooks/test-mythos.sh (+23 checks), hooks/session-state.sh (JSON-escape fix)
### ACs: 15/15 passed
### Lessons: stdout-discipline-for-composability (write human messages to stderr in machine-readable verbs); pre-existing-bugs-surface-during-integration (the revert subject's quotes exposed a latent JSON-escape bug in session-state.sh)
### Confidence: 95/100
