# Decision: split `ops/state.md`'s operational field from record-frontmatter `loop_state` (issue-44)

## Context

`roles/specs/release-engineering.spec.json` (on-the-record marketplace)
requires this rulebook to carry a `loop_state` vocabulary of exactly
`changelog-unreachable, drafting, landed, reviewing, version-undeclared`.
The survey for issue-44 found this repo already used the label
`loop_state` for a *different* field: README.md's "Record vocabulary"
section applied it to `ops/state.md`'s rollout/incident state machine
(`idle, readiness, rollout, steady, incident`), even though every gate
script (`readiness-fields-gate.sh`, `error-budget-gate.sh`,
`postmortem-review-gate.sh`) parses that field as `status:`, never
`loop_state:`. Only the README's own heading introduced the collision.

## Decision

Two vocabularies, two names:

- `ops/state.md`'s field is documented as `status` (matching what the
  gates already parse), vocabulary unchanged:
  `idle, readiness, rollout, steady, incident`.
- The record-frontmatter `loop_state` field (contract v3's per-role
  record convention) carries the spec's exact five-state set, scoped via
  `docs/specs/record-fields-terminal-states.json`'s `ops-record` entry
  (terminal: `landed, version-undeclared, changelog-unreachable`;
  non-terminal/progress: `drafting, reviewing`).

## Alternatives rejected

**Overwrite `ops/state.md`'s vocabulary with the spec's five states.**
Rejected: `idle/readiness/rollout/steady/incident` is real, load-bearing
methodology (three gates key off those exact transitions); the spec's
words describe an authoring lifecycle (draft → review → land a
document), not a release's operational state, and forcing one vocabulary
to serve both would either break the gates or misdescribe what `drafting`
means mid-rollout. The issue explicitly forbids deleting methodology.

**Keep the field named `loop_state` on `ops/state.md` and add the spec's
vocabulary as a second field on the same file.** Rejected: it does not
close the acceptance check's literal grep target — a field literally
named `loop_state` would still document a five-member set
(`idle, readiness, rollout, steady, incident`) that is not the spec's
set, which the acceptance check reads as stale/extra members under that
label. Renaming the already-`status`-labeled field removes the collision
at its source.

## Scope note: `CHANGELOG.md`

`version` (the spec's third required field) is meant to reference an
entry in a root `CHANGELOG.md` (documented in
`docs/handbooks/changelog.md`). Issue-44's phase-1 proposal's `files:`
write set did not list `CHANGELOG.md` itself among the frozen paths, so
this phase-2 delivery does not create it — creating `CHANGELOG.md` is
follow-up work for a future issue, per the scope-exceeded rule (finish
what the frozen write set covers, do not widen it mid-build).
