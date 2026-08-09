---
kind: coding-record
subject: issue-47
code_under_review:
  - docs/specs/test-env-resolution.md
  - tests/lib/resolve-core.sh
  - proposal-norm/hooks/tests/allow-deny-check.sh
  - readiness-checklist/hooks/tests/allow-deny-check.sh
  - error-budget-policy/hooks/tests/allow-deny-check.sh
  - rollout-plan/hooks/tests/allow-deny-check.sh
  - postmortem/hooks/tests/allow-deny-check.sh
type: feature
breaking: false
verdict: pass
loop_state: landed
---

## Summary of work
Adopted the canonical test-env resolution convention (on-the-record
docs/specs/test-env-resolution.md, issue #551) per the approved
phase-1 proposal `docs/issue-47/proposals/2026-08-09-test-env-resolution-adoption.md`:

- Added `docs/specs/test-env-resolution.md`: local summary of the
  convention and this repo's Bash-native adoption choice.
- Added `tests/lib/resolve-core.sh`: sourceable `resolve_core()`
  implementing `$CLAUDE_PLUGIN_ROOT_CORE` -> caller candidates -> SKIP
  (exit 75, fixed message to stderr).
- Patched all 5 `hooks/tests/allow-deny-check.sh` scripts
  (proposal-norm, readiness-checklist, error-budget-policy,
  rollout-plan, postmortem) to source the resolver and exit 75 before
  running any fixture when core is unreachable, otherwise export the
  resolved `CLAUDE_PLUGIN_ROOT_CORE` and proceed unchanged.

## Why
Basis: `docs/issue-47/proposals/2026-08-09-test-env-resolution-adoption.md`,
approved via the issue-comment `APPROVE issue-47/implementation` from
approvers.md account `JiwonJung94`. Without this, the 5 test scripts
misleadingly FAIL (not SKIP) on any checkout outside the spawn env
because their target gate scripts hard-exit 2 when `gate-lib.sh` isn't
reachable, before any fixture assertion runs.

## Doc-placement ladder outcomes
- [x] `docs/specs/test-env-resolution.md` — convention summary (spec doc, required same turn per the doctrine ladder for a cross-plugin test convention).
- [x] No new env var, dependency, or migration introduced — no additional handbook entry required.

## What did not work
- Expected: `resolve_core`'s `[ -s candidate/hooks/lib/gate-lib.sh ]`
  check to only ever match a real file. Actual: the before-landing
  warrant hunt (stance 2) found it also matches a directory named
  `gate-lib.sh` (bash `-s` reports directories as nonzero-size),
  silently resolving a malformed core instead of hitting the SKIP
  path. Fixed by adding `[ -f ... ]` before the `-s` check in
  `tests/lib/resolve-core.sh:16`; see
  `docs/reports/2026-08-09-hunt-test-env-resolution-adoption.md`.

## Open findings
None.

## Verification performed (this build's own confirmation run, not a review pass)
- `env -u CLAUDE_PLUGIN_ROOT_CORE bash <plugin>/hooks/tests/allow-deny-check.sh` for
  all 5 plugins: each exits 75 with the exact SKIP message on stderr,
  zero FAIL lines.
- `CLAUDE_PLUGIN_ROOT_CORE=<real core checkout> bash <plugin>/hooks/tests/allow-deny-check.sh`
  for all 5 plugins: every previously-passing fixture still passes
  (`ok` for every line, matching the pre-change fixture set and rc
  values), including the scripts' own "missing core" fixture, which
  still exercises the gate script's fail-closed path unaffected by the
  new default resolution (it overrides `CLAUDE_PLUGIN_ROOT_CORE` per
  subprocess).
- `grep -rl test-env-resolution .` (excluding `.git`) finds
  `docs/specs/test-env-resolution.md`, `tests/lib/resolve-core.sh`,
  and all 5 updated `allow-deny-check.sh` scripts.
- `tests/deny-only-check.sh` and `tests/role-name-check.sh` untouched,
  per the convention's own empty-state exception and the proposal's
  out-of-scope list.

## Closed checks (warrant-hunter input)
- closed_checks:
  - name: skip-path-zero-fixtures
    ref: tests/lib/resolve-core.sh:1
    Confirmed no fixture runs (no ok/FAIL lines) before the SKIP exit
    in all 5 scripts when core is unreachable.
  - name: core-reachable-parity
    ref: tests/lib/resolve-core.sh:1
    Confirmed identical `ok` output (same fixtures, same rc) in all 5
    scripts with a real core checkout, vs. the pre-change baseline
    fixture list read from each script's source.
