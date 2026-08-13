---
axis: semver-bump-selection
rule_count_floor: 12
---

# Semver bump selection

## Rules

1. **When** a change removes or renames a public export, function
   signature, config key, or CLI flag that a consumer could already be
   depending on, **choose** a MAJOR bump — never fold it into MINOR/PATCH
   even if the removal "seems small."
   source: Semantic Versioning 2.0.0, spec item 8 — https://semver.org/spec/v2.0.0.md

2. **When** a change adds a new function, optional parameter, export, or
   CLI flag without altering any existing caller's behavior, **choose** a
   MINOR bump.
   source: Semantic Versioning 2.0.0, spec item 7 — https://semver.org/spec/v2.0.0.md

3. **When** a change only corrects internal behavior to match already-
   documented behavior (a bug fix) and touches no public interface,
   **choose** a PATCH bump.
   source: Semantic Versioning 2.0.0, spec item 6 — https://semver.org/spec/v2.0.0.md

4. **When** a MAJOR-worthy breaking change and a MINOR-worthy addition
   land in the same release, **choose** MAJOR — a release's version
   number is set by its highest-severity change, never averaged or
   chosen per-file.
   source: Semantic Versioning 2.0.0, spec item 8 (incompatible changes
   dominate) — https://semver.org/spec/v2.0.0.md

5. **When** unsure whether a change is actually breaking (e.g. a
   behavior change a consumer is unlikely to rely on), **choose** the
   higher bump — treat ambiguity as breaking rather than assume safety.
   source: jsmanifest, "Semantic Versioning: When to Bump Major, Minor,
   or Patch" — https://jsmanifest.com/semantic-versioning-when-to-bump

6. **When** a MAJOR bump ships, **choose** to accompany it with a
   migration note stating what changed, who is affected, what to do,
   and when the old behavior disappears — a bare version bump with no
   migration path is an incomplete release, not a complete one.
   source: PkgPulse, "Semantic Versioning: Breaking Changes Guide" —
   https://www.pkgpulse.com/blog/semantic-versioning-guide-breaking-changes-2026

7. **REMOVAL** — **when** a MINOR or PATCH release still carries a
   deprecated API surface that was scheduled for removal in this
   version, **choose** to hold the removal for the next MAJOR and instead
   only mark it deprecated in this release's changelog — do not perform
   the actual removal outside a MAJOR bump, even if the maintainer
   judges the surface unused.
   source: Semantic Versioning 2.0.0, spec item 8 — https://semver.org/spec/v2.0.0.md

8. **REMOVAL** — **when** version churn from over-cautious bumping (every
   PATCH bumped to MINOR "just in case") accumulates, **choose** to
   simplify by re-auditing recent releases against the actual API diff
   and correcting the versioning policy going forward, rather than
   adding a second parallel versioning scheme (e.g. a build-number
   suffix) to work around it.
   source: Baeldung, "A Guide to Semantic Versioning" —
   https://www.baeldung.com/cs/semantic-versioning

9. **When** a pre-release or experimental feature is versioned,
   **choose** a pre-release identifier (e.g. `-alpha.1`) rather than
   bumping MINOR/MAJOR for it — pre-release tags have lower precedence
   than the associated normal version and signal instability explicitly.
   source: Semantic Versioning 2.0.0, spec item 9 —
   https://semver.org/spec/v2.0.0.md

10. **When** two build artifacts share every version field but differ
    only in build metadata (e.g. a CI build number), **choose** to
    append build metadata with a `+` separator rather than mint a new
    version — build metadata does not participate in precedence
    comparisons.
    source: Semantic Versioning 2.0.0, spec item 10 —
    https://semver.org/spec/v2.0.0.md

11. **When** a dependency's own MAJOR bump forces a consuming library to
    change its public contract, **choose** to propagate a MAJOR bump to
    the consuming library too — a version bump is transitive across a
    breaking dependency change, not absorbed silently as a PATCH.
    source: Zuplo, "Semantic Versioning for APIs" —
    https://zuplo.com/learning-center/semantic-api-versioning

12. **When** in doubt between two adjacent severities on a specific
    change, **choose** to bump higher rather than lower — the cost of an
    unnecessary MAJOR is a consumer re-reading a changelog; the cost of
    a missed MAJOR is a silent production break.
    source: jsmanifest, "Semantic Versioning: When to Bump Major, Minor,
    or Patch" — https://jsmanifest.com/semantic-versioning-when-to-bump
