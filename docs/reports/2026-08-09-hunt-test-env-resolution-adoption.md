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

## before-landing — stance 2: assume this guard goes silent when its own input is malformed — make it go silent

Verdict: FINDING — resolve_core's validity check `[ -s "$candidate/hooks/lib/gate-lib.sh" ]` treats a directory named gate-lib.sh as a valid non-empty file, so a malformed core (where gate-lib.sh is a directory instead of a script) is silently accepted (rc=0) instead of triggering the SKIP/exit-75 path.
Kind: silent-failure
Seed: tests/lib/resolve-core.sh (resolve_core), sourced by proposal-norm/hooks/tests/allow-deny-check.sh, readiness-checklist/hooks/tests/allow-deny-check.sh, error-budget-policy/hooks/tests/allow-deny-check.sh, rollout-plan/hooks/tests/allow-deny-check.sh, postmortem/hooks/tests/allow-deny-check.sh
cap_seconds: 180
tier: size:large
diff_stat_lines: 7 files touched
started_at: 2026-08-09T09:53:00+09:00
ended_at: 2026-08-09T09:58:00+09:00

### Reproduce
```
mkdir -p /tmp/coretest/hooks/lib/gate-lib.sh   # gate-lib.sh created as a DIRECTORY, not a file
cd /home/jwjung/.tokenmaxxxer/work/release-engineering-rulebook-issue-47-implementation
env -u CLAUDE_PLUGIN_ROOT_CORE bash -c '
  source tests/lib/resolve-core.sh
  resolved_core="$(resolve_core "/tmp/coretest")"
  rc=$?
  echo "rc=$rc resolved_core=$resolved_core"
'
```

### Observed
```
rc=0 resolved_core=/tmp/coretest
```
`[ -s /tmp/coretest/hooks/lib/gate-lib.sh ]` is true because bash's `test -s` on a directory reports it as having nonzero size (per filesystem block allocation), so the candidate is accepted as valid and printed to stdout with rc 0 — the SKIP branch is never reached.

### Expected
resolve_core should reject a candidate whose `hooks/lib/gate-lib.sh` is not a regular file (e.g. by also checking `[ -f ... ]`), and fall through to the SKIP branch (stderr message, return 75) exactly as it does for a missing or empty gate-lib.sh. Instead, callers get a resolved (but broken) CLAUDE_PLUGIN_ROOT_CORE and will fail later downstream with a confusing "gate-lib.sh: is a directory" error instead of the intended loud SKIP.

### Resolution
Fixed in `tests/lib/resolve-core.sh:16`: the candidate check now requires
`[ -f "$candidate/hooks/lib/gate-lib.sh" ] && [ -s ... ]`, rejecting a
directory (or any non-regular-file) named `gate-lib.sh`. Re-ran the
repro above post-fix: `rc=75`, SKIP message printed, `resolved_core`
empty. Full 5-plugin allow-deny-check.sh matrix re-verified after the
fix, both with core unreachable (all 5 SKIP/75) and with core reachable
(all fixtures still `ok`, no regressions).
