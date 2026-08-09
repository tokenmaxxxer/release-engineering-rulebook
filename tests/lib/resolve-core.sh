# Shared Bash resolver for the test-env resolution convention
# (docs/specs/test-env-resolution.md, on-the-record issue #551).
# Sourced by hooks/tests/allow-deny-check.sh scripts. Not executable on
# its own — provides resolve_core() only.

# resolve_core CANDIDATE...
# Order: $CLAUDE_PLUGIN_ROOT_CORE -> each CANDIDATE arg, in order -> SKIP.
# A candidate is accepted only if its hooks/lib/gate-lib.sh exists and is
# non-empty. On success, prints the resolved core root to stdout and
# returns 0. On failure, prints the fixed SKIP message to stderr and
# returns 75.
resolve_core() {
  local candidate
  for candidate in "${CLAUDE_PLUGIN_ROOT_CORE:-}" "$@"; do
    [ -n "$candidate" ] || continue
    if [ -f "$candidate/hooks/lib/gate-lib.sh" ] && [ -s "$candidate/hooks/lib/gate-lib.sh" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  echo "SKIP: core plugin unreachable — unverifiable outside spawn env" >&2
  return 75
}
