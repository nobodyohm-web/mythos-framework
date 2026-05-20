# Mythos Registry — Skills & Agents Marketplace

A curated, verifiable catalog of Mythos-compatible **skills** and **subagents** that any project can pull on demand.

## What is this?

Two JSON files:

- `skills.json` — discoverable skill files (instruct Claude *how* to think/work for a topic).
- `agents.json` — discoverable subagent files (specialized agents Claude can spawn via the Task tool).

Each entry points at a **single file in a public GitHub repo** and is validated at install time:

1. **HEAD probe** — confirm the URL is reachable.
2. **Frontmatter check** — agents must declare `name:` + `description:` in YAML; skills must have a markdown heading or YAML.
3. **Optional SHA-256 pin** — if `sha256` is set, the downloaded bytes must match.

Failure on any step ⇒ install aborts, nothing written.

## Entry shape

```json
{
  "id": "kebab-slug",
  "name": "Human Name",
  "summary": "One-line purpose.",
  "tags": ["domain", "category"],
  "project_types": ["python", "node", "*"],
  "source": {
    "type": "github-file",
    "repo": "owner/repo",
    "ref": "main",
    "path": "skills/foo.md"
  },
  "install_path": "skills/foo.md",
  "sha256": "OPTIONAL — locks integrity",
  "version": "1.0.0",
  "license": "MIT",
  "verified": true
}
```

### `source.type` values

| Type          | Meaning                                           |
|---------------|---------------------------------------------------|
| `github-file` | Single file at `https://raw.githubusercontent.com/{repo}/{ref}/{path}` |
| `url`         | Direct URL (e.g., gist raw, GitLab raw)           |

### `project_types`

Tag entries with the stacks they apply to. `["*"]` = universal. Examples: `python`, `node`, `react`, `next`, `go`, `rust`, `django`, `fastapi`, `ruby`, `rails`, `terraform`.

`bin/mythos-detect` emits these tags from the host repo so `mythos-skill recommend` can match.

## Adding your own entry

The recommended path is `mythos-skill add` (or `mythos-agent add`), which validates the URL before writing:

```bash
bin/mythos-skill add \
  --id my-skill \
  --name "My Skill" \
  --summary "What it does" \
  --repo myorg/myrepo \
  --ref main \
  --path skills/my-skill.md \
  --tags python,testing
```

Or hand-edit the JSON file — but then **run `bin/mythos-skill verify --all`** to confirm every URL still resolves.

## Trust model

- The registry shipped with Mythos is small and seeded only with entries I can verify exist (the official `mythos-framework` repo).
- Adding a third-party entry installs *that author's code* — read it before you trust it. Mythos verifies integrity, not intent.
- For maximum safety, pin `sha256` on every third-party entry.
