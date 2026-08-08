---
status: proposed
subject: issue-44
role: release-engineering
files:
  - README.md
  - docs/specs/record-fields-terminal-states.json
  - ops/hooks/directive.sh
  - proposal-norm/hooks/directive-fragment.txt
  - proposal-norm/hooks/proposal-fields-gate.sh
  - proposal-norm/hooks/tests/allow-deny-check.sh
  - docs/handbooks/changelog.md
  - docs/decisions/2026-08-09-loop-state-vs-status-split.md
---

# Proposal — align rulebook with realized release-engineering spec (issue #44)

Current-state survey: `docs/issue-44/reports/implementation/survey.md`.

## Request
Layer `roles/specs/release-engineering.spec.json`'s required fields
(`version`, `change_type`, `description`) and `loop_state` vocabulary
(`changelog-unreachable`, `drafting`, `landed`, `reviewing`,
`version-undeclared`) onto this rulebook's existing docs/hooks/gates,
strengthening current methodology without deleting any of it. Phase 1
(this document): map every spec field onto an existing or new rulebook
concept, explicit about any field with no natural home.

## Constraints
- Never delete existing methodology (PRR readiness, canary rollout,
  error-budget hard stop, human-reviewed postmortem) — issue's explicit
  instruction.
- Every spec required-field name must appear in `docs/` or `README.md`
  after phase 2 (acceptance check 1).
- The rulebook's `loop_state` vocabulary must match the spec's five
  states exactly — no stale or extra states (acceptance check 2).
- No test suite exists in this repo beyond `tests/*.sh` shell checks —
  phase 2 must run those (acceptance check 3); there is no `pytest`.
- Any spec field with no natural home must be stated explicitly with
  reasoning, not silently dropped (issue's "empty state" rule).

## Rationale
**Chosen approach: split the vocabulary by concern instead of
overwriting `ops/state.md`'s rollout state machine.** The survey found
two things this repo currently calls (or nearly calls) `loop_state`:
(1) the generic record-frontmatter field contract v3 gives every
role's record, currently unset for this role (no
`docs/specs/record-fields-terminal-states.json` exists, so it falls back
to core's bare `landed`-only default); and (2) `ops/state.md`'s own
operational rollout/incident field, documented at README.md:70-77 under
the `loop_state` heading but referred to as `status` everywhere inside
`ops/hooks/directive.sh` itself. The spec's five-word vocabulary
(`drafting`/`reviewing`/`landed`/`version-undeclared`/`changelog-unreachable`)
reads as a record-authoring lifecycle, not an operational one — it has
no rollout/readiness/incident member.

**Alternative considered and rejected: overwrite `ops/state.md`'s
`idle, readiness, rollout, steady, incident` vocabulary with the spec's
five states.** This was the literal reading of "loop_state vocabulary
matches the spec set exactly." Rejected because `ops/state.md`'s vocabulary
is real, load-bearing methodology — `readiness-checklist`,
`rollout-plan`, `error-budget-policy`, and `postmortem`'s four gates all
key off `status: readiness -> rollout`, `status: steady -> readiness`,
`status: incident -> steady` transitions (`ops/hooks/directive.sh`
verbatim). Deleting or replacing those states to fit an unrelated
five-word set would delete methodology the issue explicitly forbids
deleting, and would leave the four phase-2 gates transitioning through
states (`drafting`, `reviewing`) that describe authoring a document, not
operating a release — a category error the gates would silently accept
since none of them validate state semantics, only state names.

**Second alternative considered and rejected: leave `ops/state.md`'s
field named `loop_state` and add the spec's vocabulary as a second,
differently-named field on the same file.** Rejected because it does not
resolve the acceptance check's literal grep target: whatever the check
actually inspects for "the rulebook's loop_state vocabulary," a second
field under a different name still leaves a field literally named
`loop_state` in README.md documenting `idle, readiness, rollout, steady,
incident` — stale/extra states by the check's own wording. Renaming the
already-`status`-labeled operational field closes that collision at the
source instead of working around it.

## What will be done
1. **`description`** → already covered by proposal-norm's existing
   RFC-shaped "scope/change description" section (issue-27); no new
   field, just name it explicitly as satisfying the spec's `description`
   requirement in `README.md` and `proposal-norm/hooks/directive-fragment.txt`.
2. **`change_type`** (enum: Added/Changed/Deprecated/Removed/Fixed/
   Security) → new required field. Add to `proposal-norm`'s RFC shape
   (phase-1 proposal) and to the phase-2 record
   (`docs/issue-<n>/reports/release-engineering.md`), enforced by
   `proposal-fields-gate.sh` (deny a proposal missing `change_type` or
   using a value outside the six Keep a Changelog categories). Note the
   spec's own `recomputation` rule (change_type must be recomputed from
   the actual diff, not hand-asserted) — its `checked_by` is stated as
   "TBD" in the spec itself; this proposal states the field and its
   allowed values only, and explicitly leaves recomputation enforcement
   as a follow-up, matching the spec's own stated scope.
3. **`version`** (ref) → new required field, referencing an entry in a
   new `CHANGELOG.md` (root, Keep a Changelog format — this repo has
   none today). Documented in a new `docs/handbooks/changelog.md`
   handbook page (doctrine ladder: new file convention → handbook, same
   turn). The spec's `reference_resolution` check
   (`on-the-record/hooks/role-spec-reference-guard.sh`) lives outside
   this repo (on-the-record's own tooling) — this repo's job is only to
   carry the `version:` field and the `CHANGELOG.md` file it must
   resolve into, not to re-implement that external guard.
4. **loop_state vocabulary** → add `docs/specs/record-fields-terminal-states.json`
   declaring this role's record kind:
   `{"release-engineering": {"progress": ["drafting", "reviewing"], "terminal": ["landed"], "refusal": ["version-undeclared"], "error": ["changelog-unreachable"]}}`
   (exact shape TBD against core's actual override schema at
   phase-2 execution time — the current-state survey did not find a
   worked example of this file in this repo or a sibling to copy
   verbatim; phase 2 confirms the schema against core's
   `record-fields-terminal-states.json` consumer before writing it).
   Update `README.md`'s "Record vocabulary" section to state this
   five-state set as the record-frontmatter `loop_state`.
5. **Naming-collision fix** → in `README.md`, relabel `ops/state.md`'s
   operational field from `loop_state` to `status` (matching
   `ops/hooks/directive.sh`'s own existing terminology), keeping its
   `idle, readiness, rollout, steady, incident` vocabulary completely
   unchanged — no methodology deleted, only the README label corrected
   to match what the hooks already call it. This is a documentation-only
   fix, confirmed by survey: `error-budget-policy/hooks/error-budget-gate.sh:118`,
   `readiness-checklist/hooks/readiness-fields-gate.sh`, and
   `postmortem/hooks/postmortem-review-gate.sh:102,128` already parse
   the field as `^status:\s*(\S+)` — none of the three gates, or any
   other file, reference a literal `loop_state:` field on `ops/state.md`
   anywhere in this repo, so no gate script needs editing for this fix
   (confirmed via after-proposal warrant hunt, stance "write set cannot
   carry this work" — the hunt's candidate finding, that the three gate
   scripts hardcode `status:` and are outside the write set, turned out
   to describe the current, correct, unedited state those gates are
   already in, not a gap this proposal's write set needs to add). Record
   this naming decision in
   `docs/decisions/2026-08-09-loop-state-vs-status-split.md`.

## Out of scope
- Implementing `on-the-record/hooks/role-spec-reference-guard.sh` or any
  other reference-integrity enforcement for `version` — external tool,
  not this repo's.
- Implementing `change_type` recomputation-from-diff enforcement — the
  spec itself marks this "TBD... a follow-up."
- Any change to `readiness-checklist`, `rollout-plan`,
  `error-budget-policy`, or `postmortem`'s existing gate logic or
  `status:` transitions — those are the methodology this proposal must
  not touch or delete.
- Creating actual `CHANGELOG.md` entries for past releases — phase 2
  creates the file and its format documentation, not a backfilled
  history.

## How you'll know it worked
- `grep -ri "version\|change_type\|description" docs/ README.md` finds
  all three spec field names post-phase-2 (acceptance check 1).
- `grep -ri "loop_state" README.md docs/specs/` shows exactly
  `changelog-unreachable, drafting, landed, reviewing,
  version-undeclared` as the documented `loop_state` vocabulary, with no
  stale `idle/readiness/rollout/steady/incident` member left under that
  label (acceptance check 2) — that vocabulary survives fully, relabeled
  `status`.
- `tests/parse-check.sh`, `tests/deny-only-check.sh`,
  `tests/role-name-check.sh`, and each plugin's `allow-deny-check.sh`
  still pass after the field/gate additions (acceptance check 3 — no
  `pytest` exists in this repo).
