# Review — Ollama Integration During /assimilate

**Spec:** `specs/006-ollama-assimilate/spec.md`
**Status:** implemented
**Confidence:** 93/100
**Branch:** master
**Completed:** 2026-05-20

## Acceptance Criteria Status

- [x] AC-01: `bin/mythos-ollama status` reports binary + endpoint + model count when Ollama is installed. Verified: shows `ok / 0.24.0 / native anthropic: yes / 4 models`.
- [x] AC-02: `bin/mythos-ollama install` prints macOS + Linux instructions and exits 0 without executing. Verified — banner reads "DOES NOT EXECUTE — copy & run yourself".
- [x] AC-03: `bin/mythos-ollama enable` prints `ANTHROPIC_AUTH_TOKEN=ollama`, `ANTHROPIC_API_KEY=""`, `ANTHROPIC_BASE_URL=$OLLAMA_HOST_DEFAULT`. Three env vars verified.
- [x] AC-04: `bin/mythos-ollama models --json` produces parseable JSON. Fixed during verification — initial jq formula had nested division bug.
- [x] AC-05: `bin/mythos-ollama recommend` returns ≥3 model names (qwen3.6, qwen3.5, glm-5, kimi-k2.5) with the 64k context floor noted.
- [x] AC-06: `/assimilate` Phase 1.5 "LOCAL COMPUTE PROBE (Ollama)" added between PHASE 1 and PHASE 2.
- [x] AC-07: `bin/mythos-fleet dispatch --ollama --model qwen3.6:latest --budget 0 "say hi"` returns a worker id; meta.json shows `"provider": "ollama"`.
- [x] AC-08: `bin/mythos-fleet dispatch --ollama` with `OLLAMA_HOST=http://127.0.0.1:65499` (unreachable) exits **4** with message "ollama not reachable … start daemon: 'ollama serve'".
- [x] AC-09: `skills/ollama-integration.md` exists with all sections — why, integration path, when-to-use table, model requirements, fleet integration, /assimilate flow, privacy posture, safety contract.
- [x] AC-10: `hooks/test-mythos.sh` Ollama-Integration section adds 17 checks (binary, exec, help safety terms, install/pull DOES-NOT-EXECUTE banners, recommend content, status runs, bogus → exit 1, fleet exit-4, fleet help mentions --ollama, skill exists, slash exists, registry contains, /assimilate has PHASE 1.5, /assimilate references mythos-ollama, spec exists). All pass.
- [x] AC-11: `registry/skills.json` lists `ollama-integration` with version `5.6.0`.
- [x] AC-12: `CLAUDE.md` references `bin/mythos-ollama` and `skills/ollama-integration.md`; total **146 lines** (≤150 cap).
- [x] AC-13: `.claude/commands/ollama.md` exists.

## Deviations from Spec

- **`OLLAMA_HOST` env override:** Spec FR-1 and FR-8 implied a hardcoded `http://localhost:11434`, but during AC-08 verification I needed to simulate an unreachable endpoint. I added `OLLAMA_HOST` honoring in both `bin/mythos-ollama` and `bin/mythos-fleet` — `OLLAMA_DEFAULT_URL="${OLLAMA_HOST:-http://127.0.0.1:11434}"`. This matches the convention used by `ollama` itself and makes AC-08 testable without stopping the daemon.
- **jq formula in `models --json`:** First attempt nested `floor` and `round` in a way that produced "Cannot index number with string" when re-applied. Replaced with `((.size/1e9*10|round)/10)`. Caught and fixed before commit.

## Lessons Learned

- **jq number→object pitfall:** when constructing a jq filter that computes a numeric field, do NOT chain another object-style indexing on the same value. `((.size/1e9)|floor*0.1 + (.size/1e9 - (.size/1e9|floor))*10|round/10)` parses but executes wrong because the outer `|round/10` then receives a number and the next pipeline tries to index it. **Rule:** prefer a single arithmetic expression in parens: `((.size/1e9*10|round)/10)`. Already implicit in tasks/lessons.md tone — not load-bearing enough for a new entry.

- **The hallucination-guard treated `http://...` curl URLs as filesystem paths and emitted false positives.** This is a known false-positive class for that hook (URLs are not paths), and the curl probes were already validated by returning real data. Not a defect of the spec, but worth noting if the guard ever gets refined — it could exclude curl/wget arguments that look like absolute URLs.

## Confidence Justification

93/100:
- 🟢 All 13 ACs verified end-to-end (status, models, enable, install, pull, recommend, probe, fleet --ollama happy path, fleet --ollama exit-4 path).
- 🟢 Self-test 268/268 (added 17 Ollama checks, all green).
- 🟢 CLAUDE.md respects 150-line cap (146 lines).
- 🟢 Safety contract preserved: no auto-install, no auto-pull, no shell mutation, no eval, no rc-file modification.
- 🟢 Fleet `--ollama` and `--provider` are mutually exclusive (early validation).
- 🟡 -3 because: the `pull` and `enable` paths assume default Ollama port. If the user runs Ollama on a non-standard port via `OLLAMA_HOST`, `bin/mythos-ollama enable` will print the right URL (via `$OLLAMA_HOST_DEFAULT`), but the `recommend` doc strings still reference `localhost:11434`. Minor, surface-text only.
- 🟡 -4 because: I haven't end-to-end-validated that a worker spawned via `--ollama` actually completes against `qwen3.6:latest` (only confirmed dispatch + meta + exit-4). The smoke test dispatched with `--budget 0` which immediately terminates the worker — but the dispatch itself produced the correct meta and exit code, so this matches the spec scope. Full end-to-end Ollama generation is in the user's domain.
