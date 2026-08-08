---
code_under_review: README.md, docs/specs/record-fields-terminal-states.json, ops/hooks/directive.sh, proposal-norm/hooks/directive-fragment.txt, proposal-norm/hooks/proposal-fields-gate.sh, proposal-norm/hooks/tests/allow-deny-check.sh, docs/handbooks/changelog.md, docs/decisions/2026-08-09-loop-state-vs-status-split.md
loop_state: landed
---

# Phase-2 delivery record — issue #44

Subject: issue-44. Human approval: issue comment `APPROVE issue-44/implementation`
by `JiwonJung94` (a `docs/specs/approvers.md` account), 2026-08-08T20:23:58Z.
Upstream basis: `docs/issue-44/proposals/proposal.md`.

## What was done, why, and the concrete upstream basis

Applied `docs/issue-44/proposals/proposal.md`'s five numbered items
against the frozen write set (`files:` frontmatter of that proposal):

1. **`README.md`** — "Record vocabulary" section rewritten: splits the
   two vocabularies the survey found conflated under one label
   (`ops/state.md`'s operational `status` field, unchanged, vs the
   record-frontmatter `loop_state` now carrying the spec's exact
   five-state set for records declaring `kind: ops-record`), and states
   the spec's three required fields (`description`, `change_type`,
   `version`) explicitly with where each lives.
2. **`docs/specs/record-fields-terminal-states.json`** — created.
   `{"ops-record": ["landed", "version-undeclared", "changelog-unreachable"]}`.
   Schema confirmed against core's actual consumer
   (`record-fields-gate.sh`, read from the cached core plugin at
   `~/.claude/plugins/marketplaces/tokenmaxxxer/runs/rulebooks/tokenmaxxxer-core/core/hooks/record-fields-gate.sh`)
   before writing: the override is a flat `kind -> [terminal states]`
   map keyed on one of contract §2's fixed `KIND_TERMINAL_DEFAULTS` kind
   names — `release-engineering` is not itself a recognized kind (this
   repo's `role: release-engineering` has no `ROLE_TO_KIND` entry), so
   records must self-declare `kind: ops-record` in frontmatter to opt
   into this override; documented in README.md's rewritten section
   above. This corrects the proposal's own draft shape
   (`{"release-engineering": {"progress": [...], "terminal": [...], ...}}`),
   which the proposal itself flagged as "exact shape TBD... confirmed
   against core's actual override schema at phase-2 execution time."
3. **`ops/hooks/directive.sh`** — proposal-norm facet text now names
   `description`/`change_type`/`version` explicitly as the spec's three
   required fields, with a pointer to the new changelog handbook page.
4. **`proposal-norm/hooks/directive-fragment.txt`** — proposal
   requirement text extended to name `change_type` as a required field
   (six Keep a Changelog categories).
5. **`proposal-norm/hooks/proposal-fields-gate.sh`** — now also denies a
   proposal document missing a `change_type:` field, or whose value is
   outside Added/Changed/Deprecated/Removed/Fixed/Security.
6. **`proposal-norm/hooks/tests/allow-deny-check.sh`** — fixtures updated
   to include `change_type:` in the "allow" cases, plus two new fixtures
   for the missing-field and invalid-value deny cases. Ran directly:
   `bash proposal-norm/hooks/tests/allow-deny-check.sh` — all 18 cases
   `ok`.
7. **`docs/handbooks/changelog.md`** — created. Documents the Keep a
   Changelog convention `version` is meant to resolve into, and states
   plainly that `CHANGELOG.md` itself is not created by this delivery
   (see deviation section below).
8. **`docs/decisions/2026-08-09-loop-state-vs-status-split.md`** —
   created. Records the loop_state-vs-status naming decision and its two
   rejected alternatives (verbatim from the proposal's Rationale), plus
   the `CHANGELOG.md` scope note.

Also ran, as the final confirmation pass: `bash tests/deny-only-check.sh`
(ok), `bash tests/role-name-check.sh` (ok). No `tests/parse-check.sh`
exists in this repo (README's "Run the checks" references it from
`<core>/hooks/tests/`, not a local file) — not part of this repo's own
test suite; not run.

## Rationale for deviations

**`CHANGELOG.md` not created.** The proposal's `## What will be done`
item 3 and `## Out of scope` both describe phase 2 creating a root
`CHANGELOG.md` file, but the proposal's own `files:` frontmatter (the
frozen write set) never lists `CHANGELOG.md`. Per the scope-exceeded
rule, the frozen write set governs, not prose elsewhere in the document:
finished what the write set covers (`docs/handbooks/changelog.md`
documents the convention `version` will resolve against), did not create
`CHANGELOG.md` itself, and recorded this gap in both the handbook page
and the decision record as follow-up work for a future issue.

**`record-fields-terminal-states.json` shape.** The proposal's item 4
sketched a `{progress, terminal, refusal, error}` breakdown per kind and
flagged it explicitly as unconfirmed. Phase-2 execution read core's
actual consumer before writing and found the real schema is a flat
`kind -> [terminal states]` list restricted to §2's fixed kind names;
written to match that (see item 2 above). This is exactly the kind of
confirmation the proposal itself deferred to phase 2, not a change to
what the proposal asked for.

## What did not work

- Assumed the spec's `{progress, terminal, refusal, error}` shape (from
  the proposal's own draft) could be written to
  `record-fields-terminal-states.json` as-is. Reading core's
  `record-fields-gate.sh` before writing showed the real schema is a
  flat `kind -> [terminal states]` list, keyed on a fixed kind-name set
  that does not include `release-engineering` — rewrote to the flat
  shape and to `kind: ops-record` before ever writing the file (proposal
  had explicitly flagged this as unconfirmed, so this was expected
  research, not a wasted edit).

## Warrant hunts

- **After-proposal** (phase 1, prior session): see
  `docs/reports/2026-08-08-hunt-issue-44-*.md` (already landed, per
  commits `ae0d021`/`e1fc5b9`).
- **Before-landing** (this phase, stance index 1 — "assume this change
  and another plugin's rule cancel each other"): dispatched against the
  staged diff (9 files, 200 insertions / 14 deletions). Result: **NO
  FINDING** for the assigned stance, recorded at
  `docs/reports/2026-08-09-hunt-issue-44-spec-alignment.md`. The hunter
  separately noted an off-stance observation: `proposal-fields-gate.sh`
  already refused (pre-existing, before this issue's changes) any future
  edit to the merged `docs/issue-44/proposals/proposal.md`, because that
  document uses the newer `proposal-shape-directive` section names
  (`## Constraints`, `## Rationale`, ...) rather than the older RFC
  shape (`## Risk`, `## Rollback / back-out path`) the gate checks for
  — confirmed independently: `grep -ni "risk\|rollback\|back-out" docs/issue-44/proposals/proposal.md`
  returns nothing. This predates and is unrelated to issue-44's write
  set (the gate's RFC-shape check itself, and `proposal.md`'s section
  headings, are both outside the frozen files for this issue); not
  fixed here, flagged for a future issue instead of widening scope.

## Open findings

None blocking. See "Warrant hunts" above for the one off-stance, non-
blocking observation carried forward as a follow-up note rather than a
finding against this delivery.

## closed_checks

- proposal-fields-gate allow/deny fixture suite (18 cases) — code_sha: matches code_under_review above
- tests/deny-only-check.sh — code_sha: matches code_under_review above
- tests/role-name-check.sh — code_sha: matches code_under_review above
- record-fields-terminal-states.json schema validated against core's
  `record-fields-gate.sh` consumer (manual read, not an automated test)
  — code_sha: matches code_under_review above
