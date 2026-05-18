# Skill: Tree-of-Thoughts (ToT)

**Source:** arXiv:2601.12560v1 (Jan 2026), §"cognitive architecture dimension". `[E]`

> "Early systems relied on linear planning loops such as ReAct. To deal with more complex problems, recent work has adopted hierarchical structures that use tree search methods, for example Tree of Thoughts, and recursive decomposition as in ReAcTree."

## When to use

- When the task has multiple plausible decompositions and you don't know which is best.
- When you'd otherwise generate three candidate plans inline and pick one by feel — externalize the comparison instead.
- When backtracking is likely: keeping the tree on disk means you can prune a branch without losing the others.

## CLI

```bash
# 1. Start a tree.
bin/mythos-tot init my-task "Reduce p99 query latency to <200ms"

# 2. Expand the root into candidate strategies.
bin/mythos-tot expand my-task n1 \
  "Add a Redis read-through cache" \
  "Rewrite the N+1 query as a join" \
  "Pre-compute the result in a materialized view"

# 3. (Optionally expand further; nodes are addressed by id.)
bin/mythos-tot expand my-task n3 "Use Postgres covering index" "Use plain b-tree"

# 4. Score leaves (after spike, benchmark, or judgment).
bin/mythos-tot score my-task n2 35 "redis dep adds ops burden"
bin/mythos-tot score my-task n5 80 "covering idx — measured 90ms p99"
bin/mythos-tot score my-task n6 60 "b-tree — measured 140ms p99"
bin/mythos-tot score my-task n4 25 "materialized view stale by 10min"

# 5. Pick the winner.
bin/mythos-tot best my-task        # → {best:"n5", score:80, path:[n1,n3,n5], goal:"..."}
bin/mythos-tot show my-task        # render tree
```

## State

Stored at `.claude/state/tot/<task>.json`. Survives compaction; readable by any agent.

## Rules

1. **Score leaves only.** Internal nodes are decompositions, not candidates.
2. **Use evidence in `reason`.** "Felt better" is not a score — measure something.
3. **Prune branches you've ruled out.** `mythos-tot prune n4` marks the subtree dead — `best` ignores it. Don't delete; the rejection itself is data.
4. **Don't expand past depth 4** without a fresh review — deeper trees usually mean the problem isn't decomposed; it's bloated.

## Anti-patterns

- **Inline ToT in chat**: defeats the point. The whole win is durable state another agent can read.
- **Equal scores everywhere**: means your scorer isn't discriminating. Find a sharper signal.
- **Expanding before scoring**: breadth-first will balloon the tree. Score one branch fully, then expand the next.
