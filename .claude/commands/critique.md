# /critique — Adversarial Review (Separate Judge from Builder)

You are entering **CRITIQUE MODE**. This enforces the Anthropic principle: "Separate the judge from the builder."

## Target
Scope or task to critique: `$ARGUMENTS` (If no arguments, critique the most recent major changes or plan in `tasks/todo.md` or git diff).

## Protocol

### STEP 1 — Spawn the Judge
You, the current context, are the **Builder**. You cannot objectively review your own work.
Spawn a new `reviewer` or `security-auditor` subagent using the Task tool. Give it the following prompt:

```
You are an independent, adversarial judge. Read the code/plan at [target].
Do not try to validate it. Try to break it.
Look for:
1. Epistemic drift (claims that lack evidence, [S] presented as [E]).
2. Edge cases, race conditions, null derefs, unhandled states.
3. Security, Performance, Maintainability flaws.
4. Does this actually solve the original goal?

Provide a severity-tagged list of findings and a final verdict: APPROVE, CHANGES-REQUESTED, or BLOCK.
```

### STEP 2 — Await Verdict
Wait for the subagent to return its findings. Do not interrupt or guide it.

### STEP 3 — Resolve Findings
1. Read the judge's report.
2. If the verdict is `CHANGES-REQUESTED` or `BLOCK`:
   - Address every HIGH/CRITICAL finding. Do not dismiss them without empirical proof.
   - If you disagree with the judge, write an empirical test to prove who is right. Do not argue philosophically.
3. If the verdict is `APPROVE`:
   - Proceed with the workflow.

## Output Format

```
═══════════════════════════════════════════
  ⚖️ CRITIQUE REPORT
═══════════════════════════════════════════
🎯 TARGET: <scope>
👨‍⚖️ JUDGE: <subagent used>

📝 FINDINGS:
  - <Severity> — <Finding summary>
  - <Severity> — <Finding summary>

🚦 VERDICT: <APPROVE | CHANGES-REQUESTED | BLOCK>

🛠️ BUILDER'S RESOLUTION:
  - <Action taken to resolve finding 1>
  - <Action taken to resolve finding 2>
═══════════════════════════════════════════
```

## Constraints
- **Do not review the code yourself.** You must use a subagent to get a fresh context window.
- **Do not merge or ship if blocked.** You must resolve blockers.
