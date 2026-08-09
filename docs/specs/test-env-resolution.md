# Test-env core resolution convention

Local summary of the canonical on-the-record convention
(docs/specs/test-env-resolution.md at on-the-record, issue #551). See
that document for the full rationale; this file states this repo's
adoption choice only.

## Convention

A Bash test script that depends on core's `hooks/lib/gate-lib.sh` must
resolve core in this fixed order before running any fixture:

1. `$CLAUDE_PLUGIN_ROOT_CORE`, if set and its `hooks/lib/gate-lib.sh` is
   present and non-empty.
2. Caller-supplied sibling candidate paths (e.g. `../../core` relative to
   the test script), same present-and-non-empty check.
3. Otherwise: **SKIP**, not FAIL. Print
   `SKIP: core plugin unreachable — unverifiable outside spawn env` to
   stderr and exit `75`.

This turns "core unreachable" into a distinct, explicit, non-misleading
outcome instead of a wall of FAIL lines from fixtures that never had a
chance to run.

## This repo's adoption

The canonical reference implementation is a Python module
(`gates/test_env_resolve.py`). This repo's test suite is Bash-only, so
instead of shelling out to Python for one order-of-checks decision, the
convention is reproduced natively in `tests/lib/resolve-core.sh` — a
sourceable Bash function `resolve_core` implementing the same order, the
same SKIP message, and the same exit code (75). Each plugin's
`hooks/tests/allow-deny-check.sh` sources this file and calls
`resolve_core` with its own candidate list before running any fixture.
