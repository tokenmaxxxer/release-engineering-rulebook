# Changelog convention (issue-44)

`version` is one of `roles/specs/release-engineering.spec.json`'s three
required fields. It must reference an entry in a root `CHANGELOG.md`,
[Keep a Changelog](https://keepachangelog.com/) format — the spec's own
`source_standard`.

**Status: convention documented, `CHANGELOG.md` not yet created.**
Issue-44's frozen write set did not list `CHANGELOG.md` itself, so this
phase-2 delivery documents the convention without creating the file —
see `docs/decisions/2026-08-09-loop-state-vs-status-split.md` for the
scope note. Creating `CHANGELOG.md` and wiring `version:` references
into it is follow-up work for a future issue.

## Format, once `CHANGELOG.md` exists

- One `## [version] - YYYY-MM-DD` heading per release.
- Entries grouped under one of six category headings, matching
  `change_type`'s allowed values exactly: `Added`, `Changed`,
  `Deprecated`, `Removed`, `Fixed`, `Security`.
- A phase-1 proposal or phase-2 record's `version:` field names the
  `[version]` heading it resolves to. `change_type:` names the category
  the change falls under within that heading.

## Out of scope here

- `on-the-record/hooks/role-spec-reference-guard.sh`'s reference-
  resolution check (does `version:` actually resolve to a real
  `CHANGELOG.md` entry) — external tooling, not this repo's.
- `change_type` recomputation-from-diff enforcement — the spec itself
  marks this "TBD", a follow-up.
