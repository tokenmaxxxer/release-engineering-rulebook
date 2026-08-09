---
proposal: docs/issue-47/proposals/2026-08-09-test-env-resolution-adoption.md
---

# Hunt record — test-env-resolution-adoption

## after-proposal — stance 1: assume this change and another plugin's rule cancel each other — find the pair

Verdict: NO FINDING
Seed: docs/issue-47/proposals/2026-08-09-test-env-resolution-adoption.md, docs/issue-47/reports/implementation/survey.md (git diff HEAD~1 HEAD, 2 files, +181 lines, docs-only)
cap_seconds: 120
tier: default
diff_stat_lines: 181
started_at: 2026-08-09T00:00:00Z
ended_at: 2026-08-09T00:06:00Z

Investigated whether the planned top-level `resolve_core` SKIP-before-fixtures
wrapper (proposal step 3) would cancel out the existing "missing core
(CLAUDE_PLUGIN_ROOT_CORE unreachable, no ../../core fallback) -> deny (exit 2)"
fixture already present in each `allow-deny-check.sh` (e.g.
`proposal-norm/hooks/tests/allow-deny-check.sh:148`), which sets a broken
`CLAUDE_PLUGIN_ROOT_CORE` to assert the gate itself fails closed. Ran the
script in this repo's actual session environment (`CLAUDE_PLUGIN_ROOT_CORE`
already points at a real core checkout in this sandbox) - all 17 fixtures,
including the missing-core one, currently pass:
`bash proposal-norm/hooks/tests/allow-deny-check.sh` -> `ok    missing core
(...) -> deny (exit 2) (rc=2)`. On inspection, that fixture overrides
`CLAUDE_PLUGIN_ROOT_CORE` only for its own `run_payload`/gate subprocess
invocation, not for the test script's own top-level ambient env - so the
planned once-at-top `resolve_core` call (which reads ambient env, not the
per-fixture override) would still succeed and let this fixture run whenever
core is reachable at all, which is the only case where the fixture is
meaningful. Also checked for any aggregator/CI/hook that runs these test
scripts and interprets their exit codes: `grep -rln
"allow-deny-check|deny-only-check|role-name-check"` outside `hooks/tests/`
only matches `tests/deny-only-check.sh` and `tests/role-name-check.sh`
themselves (unrelated scripts, out of scope per the proposal); no
`.yml`/`.yaml` CI workflow files exist anywhere in the repo; no non-sample
`.git/hooks` exist; no `run-gate-tests.sh` aggregator exists (confirmed
absent, matching the proposal's own "Out of scope" note). No other plugin
rule, CI gate, or hook currently branches on exit 0/1/2 from these scripts
in a way that exit 75 would be misread as pass/fail/deny. No reproducible
collision found.
