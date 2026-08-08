---
loop_state: drafting
---

# Current-state survey — issue #44

## Spec read
`roles/specs/release-engineering.spec.json` (on-the-record marketplace,
read from `/home/jwjung/.claude/plugins/marketplaces/tokenmaxxxer/roles/specs/release-engineering.spec.json`):
required fields `version` (ref), `change_type` (enum: Added/Changed/
Deprecated/Removed/Fixed/Security — Keep a Changelog categories),
`description` (string); `write_scope`: `CHANGELOG.md` and
`docs/issue-<n>/reports/release-engineering.md`; `loop_state`: progress
`drafting, reviewing`, terminal `landed`, refusal `version-undeclared`,
error `changelog-unreachable`; `reference_resolution` (version must
resolve to a real CHANGELOG.md entry, checked by
`on-the-record/hooks/role-spec-reference-guard.sh` — external to this
repo); `recomputation` (change_type recomputed from the diff, enforcement
"TBD", explicitly out of scope for now).

## Existing rulebook state (this repo)

**Role identity.** Plugin dir `ops/` == marketplace plugin name
`release-engineering` (`.claude-plugin/marketplace.json:8-11`). Six
plugins total: `ops` (role directive composer), `proposal-norm` (phase 1),
`readiness-checklist`/`rollout-plan`/`error-budget-policy`/`postmortem`
(phase 2, composed).

**Required-field coverage today** (README.md:70-77, `ops/hooks/directive.sh`):
- `description` — already covered: proposal-norm's RFC shape
  (issue-27) requires a "scope/change description" section in every
  `docs/issue-<n>/proposals/*.md`, enforced by
  `proposal-norm/hooks/proposal-fields-gate.sh`. Direct match, no new
  field needed — strengthen by naming it explicitly.
- `change_type` — **absent**. No enum field anywhere maps release work
  to Added/Changed/Deprecated/Removed/Fixed/Security. `rollout-plan`
  tracks per-step `result: pass|fail|pending`, not a change-category
  field.
- `version` — **absent**. No field anywhere references a version or a
  CHANGELOG.md entry. `CHANGELOG.md` does not exist in this repo
  (`find` confirms no CHANGELOG.md at root or elsewhere) — the repo has
  no artifact for `version` to resolve against yet.

**loop_state vocabulary — two collisions found, not one field:**
1. **Record frontmatter `loop_state`** (contract v3, generic per-role
   terminal-states convention, e.g. `docs/issue-39/reports/release-engineering.md:15`
   reads `loop_state: landed`). No `docs/specs/record-fields-terminal-states.json`
   exists in this repo, so this role currently falls back to core's
   bare default terminal set (`landed` only) for record frontmatter —
   confirmed by grep: no `RECORD_FIELDS_TERMINAL_STATES` assignment
   exists in `ops/hooks/directive.sh` today, despite `docs/issue-28/reports/implementation.md:29-32`
   describing an intent to set one (`"steady idle"`) — that intent was
   never actually landed in the stub; the record documenting it is
   itself talking about a *different* vocabulary (see #2).
2. **`ops/state.md`'s own domain state field**, documented at
   README.md:70-77 under the heading "Record vocabulary" as
   `` `loop_state`: `idle, readiness, rollout, steady, incident` ``
   (settled: `steady`/`idle`) — this is the release's *operational*
   rollout/incident state machine (PRR → rollout → steady, or →
   incident → postmortem → steady), unrelated to record authorship.
   Notably, `ops/hooks/directive.sh` itself never calls this field
   `loop_state` — every reference inside the directive text calls it
   `status:` (e.g. `"ops/state.md status: readiness -> rollout"`,
   `"status: incident -> steady"`). Only README.md's heading applies
   the `loop_state` label to it. This is a naming collision the
   README introduced, not something the operative hooks/directive
   actually rely on.

Because the spec's five-word vocabulary (`changelog-unreachable,
drafting, landed, reviewing, version-undeclared`) reads as an authoring
lifecycle for a record/changelog entry (draft → review → land, refuse if
version undeclared, error if the changelog file is unreachable) — not an
operational rollout/incident machine — it maps cleanly onto vocabulary
#1 (record frontmatter `loop_state`, currently unset/default) and not
onto #2 (`ops/state.md`'s rollout state machine, which is real
methodology this repo must not delete per the issue's instruction).

## Write surfaces this proposal will need (anticipated)
- `README.md` — "Record vocabulary" section: state the record-frontmatter
  `loop_state` vocabulary explicitly (the spec's five states) and
  relabel the `ops/state.md` field as `status` (matching what the
  directive text already calls it) to remove the naming collision.
- `docs/specs/record-fields-terminal-states.json` — new file, the
  documented override mechanism (per core's
  `RECORD_FIELDS_TERMINAL_STATES` / repo-override convention) declaring
  this role's record kind's progress/terminal/refusal/error states as
  the spec's exact set.
- `ops/hooks/directive.sh` — HAND_OFF / PROPOSAL facet text: name
  `version`, `change_type`, `description` explicitly as the three
  required proposal/record fields, and reference `CHANGELOG.md` as a
  write surface phase 2 may touch.
- `proposal-norm/hooks/directive-fragment.txt` (or equivalent phase-1
  facet) — add `change_type` (enum) and `version` (ref) as proposal
  fields alongside the existing scope/description requirement.
- A new handbook page (`docs/handbooks/changelog.md`) documenting the
  Keep a Changelog convention this repo is adopting: CHANGELOG.md
  location/format, the six `change_type` categories, and that `version`
  must resolve to a real entry there (citing Keep a Changelog,
  https://keepachangelog.com/, the spec's own `source_standard`).
- `docs/decisions/` — one ADR-shaped entry recording the
  `loop_state`-vs-`status` naming resolution (why two vocabularies
  existed under one name, why they're now split), since this is a
  changed public naming convention other roles/tooling may already
  depend on (README.md is read by humans and by on-the-record).

## Alternatives considered while surveying
Collapsing both vocabularies into one `loop_state` field covering both
authoring and rollout state was considered and rejected during survey:
the two lifecycles are orthogonal (a record can be `drafting` while the
release itself is `steady`, or `landed` while the release is mid-`rollout`)
and the spec's five states have no rollout/incident member — forcing one
field to carry both would either lose the spec's exact vocabulary (fails
the acceptance check verbatim) or delete real rollout/incident
methodology (forbidden by the issue). Full reasoning and the rejected
alternative go in the proposal's own Rationale section.
