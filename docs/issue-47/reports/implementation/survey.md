# Current-state survey — issue #47

## Canonical convention (read verbatim)
The on-the-record convention doc (issue #551) is not present in this repo.
Located and read from the sibling `on-the-record` working tree:
`/home/jwjung/.tokenmaxxxer/work/on-the-record-issue-551-implementation/docs/specs/test-env-resolution.md`.

Resolution order it defines:
1. `$CLAUDE_PLUGIN_ROOT_CORE`, if set and it contains a non-empty
   `hooks/lib/gate-lib.sh`.
2. First caller-supplied sibling-checkout candidate (e.g. `../core`,
   `../../tokenmaxxxer-core/core`) containing the same file, non-empty.
3. Otherwise **SKIP**: print
   `SKIP: core plugin unreachable — unverifiable outside spawn env` to
   stderr, exit `75` (`EX_TEMPFAIL`) — a code distinct from a gate's own
   pass(0)/fail(1)/deny(2).

Reference implementation is a Python module (`gates/test_env_resolve.py`)
living in the on-the-record repo, not vendored anywhere in this repo. The
doc's own "Adoption per consumer shape" section names a Bash test-runner
shape as one of two expected consumer shapes, invoked as a CLI subprocess
of that Python module — but does not require a literal Python dependency;
this repo's test scripts are pure Bash with no Python runtime currently
assumed anywhere else in the suite.

## This repo's test scripts
Two groups, by whether they depend on core being reachable:

**Depend on `CLAUDE_PLUGIN_ROOT_CORE` / core (5 scripts, one per plugin,
identical pattern):**
- `proposal-norm/hooks/tests/allow-deny-check.sh`
- `readiness-checklist/hooks/tests/allow-deny-check.sh`
- `error-budget-policy/hooks/tests/allow-deny-check.sh`
- `rollout-plan/hooks/tests/allow-deny-check.sh`
- `postmortem/hooks/tests/allow-deny-check.sh`

Each sources its plugin's `*-gate.sh`, which itself does:
```
. "${CLAUDE_PLUGIN_ROOT_CORE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../core" && pwd -P)}/hooks/lib/gate-lib.sh" || { echo "...: cannot source gate-lib.sh" >&2; exit 2; }
```
On a plain `main` checkout (no core sibling, no env var), this `exit 2`
fires for every invocation of the gate script. The test harness's `run` /
`run_payload` helpers compare against each fixture's *expected* rc (0, 2,
etc.) — so fixtures expecting rc=2 (deny cases) pass by accident, while
fixtures expecting rc=0 (allow cases) report `FAIL` even though nothing
about the gate's own logic regressed. This is exactly the "delivery
regression" vs. "environment" ambiguity issue #551 (and this issue)
describe — confirmed by running
`bash proposal-norm/hooks/tests/allow-deny-check.sh` in this checkout: no
core sibling exists at `../../core` relative to the hooks dir, and no
`CLAUDE_PLUGIN_ROOT_CORE` is set in this session.
- Verified: no `hooks/lib/gate-lib.sh` reachable at any of `../core`,
  `../../core` relative to this repo root, and `$CLAUDE_PLUGIN_ROOT_CORE`
  is unset in this session — this checkout is the exact unresolved case
  the convention targets.

**Do not touch core at all (2 scripts, out of scope per the convention's
own "Empty state" exception, same shape as `on-the-record`'s
`gates/test_skip_gate.py`):**
- `tests/deny-only-check.sh` — greps hooks source for a literal JSON
  key/value pattern; no sourcing, no core dependency.
- `tests/role-name-check.sh` — greps README/manifest files for banned
  brand tokens; no sourcing, no core dependency.

Both already run to a real pass/fail on a plain checkout; confirmed no
`CLAUDE_PLUGIN_ROOT_CORE` or `gate-lib.sh` reference in either file.

## No repo-local resolver exists yet
`grep -r test-env-resolution` and `grep -r EX_TEMPFAIL` across this repo:
zero hits. Nothing here currently implements any part of the convention;
this is a fresh adoption, not an update to an existing partial one.

## Gap line
- Convention provides: an env-var-then-candidates-then-SKIP order, a
  fixed message string, and exit code 75.
- This repo is missing: any of it. The 5 core-dependent scripts fail
  outright (misleading FAIL, not SKIP) outside spawn env; nothing greps
  for `test-env-resolution` anywhere in the tree.
- Open design question the proposal must settle: how a Bash-only test
  suite adopts a convention whose reference implementation is Python,
  without adding a new Python runtime dependency to this repo's test
  path.
