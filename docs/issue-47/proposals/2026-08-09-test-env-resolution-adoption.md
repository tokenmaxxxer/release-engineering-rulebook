---
status: proposed
files:
  - docs/specs/test-env-resolution.md
  - tests/lib/resolve-core.sh
  - proposal-norm/hooks/tests/allow-deny-check.sh
  - readiness-checklist/hooks/tests/allow-deny-check.sh
  - error-budget-policy/hooks/tests/allow-deny-check.sh
  - rollout-plan/hooks/tests/allow-deny-check.sh
  - postmortem/hooks/tests/allow-deny-check.sh
---

## Request
Adopt the canonical test-env resolution convention (on-the-record
docs/specs/test-env-resolution.md, issue #551) in this rulebook: the 5
`allow-deny-check.sh` scripts that depend on core's `gate-lib.sh` must
SKIP (not misleadingly FAIL) when core is unreachable outside the spawn
env, using the convention's exact message and exit code (75), without
weakening any assertion that runs when core IS reachable.

## Constraints
- Resolution order fixed by the convention: `$CLAUDE_PLUGIN_ROOT_CORE` →
  caller-supplied sibling candidates → SKIP. No path may be hardcoded
  inside a shared resolver; candidates are supplied by each caller.
- SKIP message and exit code are fixed by the convention verbatim:
  `SKIP: core plugin unreachable — unverifiable outside spawn env` to
  stderr, exit `75`.
- Must not touch `tests/deny-only-check.sh` or `tests/role-name-check.sh`
  — the convention's own "Empty state" exception covers them (no core
  dependency at all).
- No network fetch fallback (explicitly out of the canonical contract).
- Every allow-deny assertion that currently passes when core IS reachable
  (verified via `CLAUDE_PLUGIN_ROOT_CORE` pointed at a real core checkout)
  must still pass unchanged.

## Rationale
The convention's reference implementation is a Python module
(`gates/test_env_resolve.py`, invoked as
`python3 -m gates.test_env_resolve <candidates>`). Considered adopting it
literally — vendoring/copying that Python module into this repo and
shelling out to it from each Bash test script — and rejected it: this
repo's entire test suite is Bash-only today (no `pytest`, no `gates/`
package, no other Python runtime dependency anywhere in the tree per the
survey), so adding a Python subprocess call for one resolution check
would introduce a new interpreter dependency into every plugin's test
path for a single order-of-checks decision that Bash expresses natively.
Instead: implement one small shared Bash resolver
(`tests/lib/resolve-core.sh`) that reproduces the same order, the same
message string, and the same exit code (75) — matching the convention's
own explicitly-named "Bash test runner" consumer shape, which the doc
describes as invoking a resolution step and branching on its exit code,
not as requiring the reference module's language. Each `allow-deny-check.sh`
sources this one shared file instead of five copy-pasted resolution
blocks.

## What will be done
1. Add `docs/specs/test-env-resolution.md` (local, short): summarizes the
   convention, links to the canonical on-the-record doc + issue #551 by
   name, and states this repo's Bash-native adoption choice — so the
   acceptance check's `grep -r test-env-resolution` finds a real
   reference, not a copy that can drift from the source of truth.
2. Add `tests/lib/resolve-core.sh`: a sourceable Bash function
   `resolve_core "$@"` implementing the 3-step order above over
   caller-supplied candidate paths, checking each candidate's
   `hooks/lib/gate-lib.sh` is both present and non-empty (mirrors the
   reference implementation's zero-byte-stub guard). On success it sets
   a resolved path variable; on failure it prints the fixed SKIP message
   to stderr and returns 75.
3. In each of the 5 `allow-deny-check.sh` scripts: before running any
   fixture, source `tests/lib/resolve-core.sh` and call `resolve_core`
   with that plugin's own candidate list (its existing
   `${CLAUDE_PLUGIN_ROOT_CORE}` behavior plus the existing
   `../../core`-relative fallback the gate script already assumes). If
   it returns 75, the test script itself exits 75 immediately (no
   fixtures run, no misleading FAIL/PASS lines) instead of letting every
   fixture run against a gate that can't source its own lib. If it
   resolves, export `CLAUDE_PLUGIN_ROOT_CORE` to the resolved path for
   the remainder of the script so the existing fixture logic is
   unchanged.

## Out of scope
- `tests/deny-only-check.sh`, `tests/role-name-check.sh` — no core
  dependency, convention's own exception applies.
- Any change to gate script logic/assertions themselves (`*-gate.sh`) —
  only the test scripts' env-resolution wrapping changes.
- Copying the on-the-record Python reference module into this repo.
- A CI-level `run-gate-tests.sh` aggregator — none exists in this repo
  today; out of scope to add one.

## How you'll know it worked
- On this plain checkout (no `CLAUDE_PLUGIN_ROOT_CORE`, no `../../core`
  sibling): each of the 5 `allow-deny-check.sh` scripts exits 75 and
  prints the exact SKIP message to stderr — zero FAIL lines.
- With `CLAUDE_PLUGIN_ROOT_CORE` pointed at a real core checkout (or a
  reachable `../../core` sibling): all existing fixtures in all 5 scripts
  still pass exactly as before (same rc per fixture, same count of `ok`
  lines).
- `grep -rl test-env-resolution .` finds `docs/specs/test-env-resolution.md`
  and all 5 updated test scripts.
