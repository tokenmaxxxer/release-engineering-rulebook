---
axis: branching-release-strategy
rule_count_floor: 12
---

# Branching and release strategy

## Rules

1. **When** a team integrates changes at least daily and wants the
   ability to release from the main line at any time, **choose**
   trunk-based development (short-lived branches merged straight to
   trunk) over long-lived release branches.
   source: LaunchDarkly, "Git Branching Strategies vs. Trunk-Based
   Development" —
   https://launchdarkly.com/blog/git-branching-strategies-vs-trunk-based-development/

2. **When** a feature needs multiple days/weeks of incremental work but
   the team is on trunk-based development, **choose** to merge
   incomplete work behind a feature flag rather than keep a long-lived
   feature branch open — this is what makes trunk-based development
   viable for multi-day work.
   source: Flagsmith, "How to Use Feature Flags for Trunk-Based
   Development" —
   https://www.flagsmith.com/blog/trunk-based-development-feature-flags

3. **When** a service needs a stabilization window before a scheduled
   release (e.g. regulated or hardware-adjacent software with a fixed
   release train), **choose** a release-branch cut from trunk near the
   release date, with only fixes cherry-picked onto it — never continued
   feature development on the release branch itself.
   source: sre.google, "Release Engineering" (hermetic-build/versioning
   discussion of release branches) — https://sre.google/sre-book/release-engineering/

4. **When** an old release must be patched (e.g. a security fix on a
   version customers still run), **choose** to cherry-pick the fix onto
   that release's branch using the *original* build toolchain/compiler
   version from that time — not the current toolchain — to avoid
   introducing incompatibilities the original release never had.
   source: sre.google, "Release Engineering" (hermetic builds) —
   https://sre.google/sre-book/release-engineering/

5. **When** choosing how to bundle configuration with a release,
   **choose** based on change frequency: config that changes often goes
   in an external system separate from the binary; config that changes
   once per release is bundled with the binary in one package; config
   that must update independently of the binary is packaged separately
   with a shared label.
   source: sre.google, "Release Engineering" —
   https://sre.google/sre-book/release-engineering/

6. **When** release velocity and testing burden are in tension,
   **choose** more frequent, smaller releases over infrequent, large
   ones — fewer changes between versions simplifies both testing and
   troubleshooting when something breaks.
   source: sre.google, "Release Engineering" —
   https://sre.google/sre-book/release-engineering/

7. **When** many product teams need to release independently at scale,
   **choose** a self-service release process (teams trigger their own
   releases; humans engage only when something goes wrong) over a
   centralized release-engineering gatekeeper for every release.
   source: sre.google, "Release Engineering" —
   https://sre.google/sre-book/release-engineering/

8. **When** long-lived feature branches accumulate merge conflicts and
   integration risk grows with branch age, **choose** to migrate the
   team toward trunk-based development rather than invest further in
   branch-merge tooling — the risk source is branch lifetime itself, not
   the merge process.
   source: Ardalis, "Trunk-Based Development vs. Long-Lived Feature
   Branches" — https://ardalis.com/trunk-based-development-vs-long-lived-feature-branches/

9. **REMOVAL** — **when** a release branch has served its stabilization
   window and shipped, **choose** to delete (or archive) the branch
   rather than leave it open indefinitely as a second parallel trunk —
   an open old release branch invites accidental commits that never
   reach production.
   source: LaunchDarkly, "Git Branching Strategies vs. Trunk-Based
   Development" —
   https://launchdarkly.com/blog/git-branching-strategies-vs-trunk-based-development/

10. **REMOVAL** — **when** a codebase runs both long-lived feature
    branches and feature flags for the same class of change, **choose**
    to retire the long-lived-branch path for that class rather than keep
    two parallel risk-management mechanisms — the overlap doubles review
    surface without doubling safety.
    source: Harness, "Trunk-based vs. Feature-based Development" —
    https://www.harness.io/blog/trunk-based-vs-feature-based-development

11. **When** classic branching's overhead (merge queues, integration
    freezes) is the actual bottleneck slowing releases, **choose**
    trunk-based development's granular, per-commit control over
    continuing to add branch-management process on top of the existing
    strategy.
    source: getunleash.io, "Trunk-based development: process, examples,
    strategy" — https://www.getunleash.io/blog/how-to-implement-trunk-based-development-a-practical-guide

12. **When** a hotfix is needed for production while trunk holds
    unreleased, unstable work, **choose** to cut the hotfix from the
    last known-good release tag (not from current trunk) and cherry-pick
    forward, so the fix ships without pulling in trunk's in-flight
    changes.
    source: sre.google, "Release Engineering" (rollback/build-artifact
    tracking) — https://sre.google/sre-book/release-engineering/
