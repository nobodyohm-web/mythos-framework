# /marketplace — Skills & Agents Marketplace

**Purpose:** Discover, verify, and install curated Mythos skills & subagents from a versioned registry of GitHub-hosted sources. Every install is HEAD-probed, frontmatter-validated, and (optionally) SHA-256 pinned.

---

## Workflow

### 1. Inventory the host

Run `bin/mythos-detect` and capture the tags. They drive recommendations.

```bash
bin/mythos-detect
```

If no tags surface, you're in a tooling/meta repo — universal `["*"]` entries still apply.

### 2. Browse the catalog

```bash
bin/mythos-skill list
bin/mythos-agent list
```

Or search:

```bash
bin/mythos-skill search testing
bin/mythos-agent search security
```

### 3. Show recommendations

Detect-driven suggestions for THIS repo:

```bash
bin/mythos-skill recommend
bin/mythos-agent recommend
```

### 4. Install

Single entry:

```bash
bin/mythos-skill install epistemic-rigor
bin/mythos-agent install planner
```

Bulk install by tag or project type:

```bash
bin/mythos-skill install-all --tag meta
bin/mythos-skill install-all --project-type python
```

Every install:
1. HEAD-probes the GitHub raw URL.
2. Downloads to a tempfile.
3. Validates frontmatter (agents: `name:` + `description:` required).
4. If a SHA-256 is pinned, verifies bytes.
5. Atomically moves into place.

### 5. Add a third-party entry

```bash
bin/mythos-skill add \
  --id my-skill \
  --name "My Skill" \
  --summary "What it does" \
  --repo someuser/somerepo \
  --ref main \
  --path skills/foo.md \
  --tags python,testing
```

The CLI HEAD-probes the URL **before** persisting. Entries added this way are marked `verified:false` — review the source before installing.

To pin integrity:

```bash
bin/mythos-skill refresh-sha my-skill
```

### 6. Re-verify the catalog periodically

```bash
bin/mythos-skill verify-all
bin/mythos-agent verify-all
```

Flags any URL that has rotted, branch that has moved, or pinned hash that no longer matches.

---

## When to use this command

- New project — bootstrap a base of skills/agents matched to the stack.
- After `/assimilate` — pull in domain-specific skills the host needs.
- Sharing — publish your own skills on GitHub, then `add` them to your local registry.

## Reporting

After installing, summarize:
- Detected project tags
- Installed skill ids + paths
- Installed agent ids + paths
- Any entries that failed verification
