---
axis: changelog-entry-categorization
rule_count_floor: 12
---

# Changelog entry categorization

## Rules

1. **When** an entry introduces a wholly new capability, **choose** the
   `Added` category — never `Changed`, even if it modifies an adjacent
   existing feature to expose the new one.
   source: Keep a Changelog v1.1.0 — https://keepachangelog.com/en/1.1.0/

2. **When** an entry alters existing, still-present functionality (e.g.
   a default value, an output format), **choose** `Changed`.
   source: Keep a Changelog v1.1.0 — https://keepachangelog.com/en/1.1.0/

3. **When** an entry marks a feature as scheduled for future removal but
   does not remove it yet, **choose** `Deprecated` — never `Removed`
   until the feature is actually gone in a later release.
   source: Keep a Changelog v1.1.0 — https://keepachangelog.com/en/1.1.0/

4. **When** an entry deletes a feature that was previously deprecated
   (or, rarely, removed without a deprecation period), **choose**
   `Removed`.
   source: Keep a Changelog v1.1.0 — https://keepachangelog.com/en/1.1.0/

5. **When** an entry corrects incorrect behavior, **choose** `Fixed` —
   never `Changed`, since a fix restores documented/intended behavior
   rather than altering the contract.
   source: Keep a Changelog v1.1.0 — https://keepachangelog.com/en/1.1.0/

6. **When** an entry closes a vulnerability, **choose** `Security` even
   if the underlying code change looks like a `Fixed` bug — security
   entries stay in their own category so a reader scanning for
   vulnerability history doesn't have to read every `Fixed` line.
   source: Keep a Changelog v1.1.0 — https://keepachangelog.com/en/1.1.0/

7. **When** writing any entry, **choose** language a human consumer can
   act on (what changed and why it matters) — never a copy-pasted commit
   message or raw diff summary, per the spec's own stated principle
   "Changelogs are for humans, not machines."
   source: Keep a Changelog v1.1.0, guiding principles —
   https://keepachangelog.com/en/1.1.0/

8. **When** a release has entries in more than one category, **choose**
   to group entries under their category heading (`### Added`, `###
   Fixed`, ...) in a fixed category order — never list entries flat
   under a bare version heading.
   source: Keep a Changelog v1.1.0 — https://keepachangelog.com/en/1.1.0/

9. **When** dating a release heading, **choose** ISO 8601
   (`YYYY-MM-DD`) — never a locale-specific date format that a
   non-English reader could misread as day/month swapped.
   source: Keep a Changelog v1.1.0 — https://keepachangelog.com/en/1.1.0/

10. **REMOVAL** — **when** an `Unreleased` section accumulates entries
    across many merged PRs, **choose** to cut it down at release time by
    collapsing near-duplicate entries into one (e.g. three PRs that all
    touched the same feature) rather than listing every PR verbatim —
    the changelog serves the reader's understanding, not a complete PR
    log.
    source: Keep a Changelog v1.1.0, guiding principles ("for humans") —
    https://keepachangelog.com/en/1.1.0/

11. **REMOVAL** — **when** an entry describes an internal refactor with
    no observable effect on any consumer, **choose** to omit it from the
    changelog entirely rather than force it into a category — an
    all-inclusive changelog that logs every commit stops being scannable
    and defeats the "for humans" principle.
    source: Keep a Changelog v1.1.0, guiding principles —
    https://keepachangelog.com/en/1.1.0/

12. **When** a category would otherwise be empty for a release, **choose**
    to omit that category heading rather than print it with no entries
    under it — an empty heading adds scanning cost with zero information.
    source: Keep a Changelog v1.1.0 — https://keepachangelog.com/en/1.1.0/
