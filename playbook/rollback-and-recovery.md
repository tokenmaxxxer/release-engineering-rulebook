---
axis: rollback-and-recovery
rule_count_floor: 12
---

# Rollback and recovery

## Rules

1. **When** any release ships, **choose** to retain a detailed change
   report and the previous build's artifact alongside the new one — not
   just the new build — so a rollback target and a diff of "what
   changed" both exist the moment an incident starts.
   source: sre.google, "Release Engineering" (change reports and build
   artifacts enable targeted fixes/rollbacks) —
   https://sre.google/sre-book/release-engineering/

2. **When** a canary or rolling deployment's pre-declared error-rate
   threshold is crossed, **choose** automatic rollback over paging a
   human to decide — a pre-declared threshold exists specifically so the
   rollback decision doesn't wait on human judgment under incident
   pressure.
   source: TechTarget, "When to use canary vs. blue/green vs. rolling
   deployment" —
   https://www.techtarget.com/searchitoperations/answer/When-to-use-canary-vs-blue-green-vs-rolling-deployment

3. **When** a blue-green deployment shows a problem post-switch,
   **choose** to switch traffic back to the still-running previous
   (blue) environment immediately — never attempt a fix-forward patch
   on the new environment first, since the old environment is still
   live and rollback is a single switch.
   source: getunleash.io, "Canary vs. blue/green vs. rolling
   deployment: How to choose" —
   https://www.getunleash.io/blog/comparing-deployment-strategies-canary-blue-green-and-rolling

4. **When** an incident's root cause is unclear but a recent release
   correlates with onset, **choose** to roll back first and investigate
   after — restoring service takes priority over diagnosing root cause
   while the service is degraded.
   source: sre.google, "Release Engineering" (rollback as the standard
   recovery path, enabled by retained build artifacts) —
   https://sre.google/sre-book/release-engineering/

5. **When** a rollback itself requires a schema or data migration to
   reverse, **choose** to design the forward migration as
   rollback-compatible (e.g. additive-first, backward-compatible reads)
   at release time — never discover at incident time that the migration
   has no reverse path.
   source: sre.google, "Release Engineering" (hermetic, versioned builds
   as the basis for a reliable rollback path) —
   https://sre.google/sre-book/release-engineering/

6. **When** a rolling deployment must be rolled back, **choose** to
   budget incident response time for the slower, instance-by-instance
   reversal that rolling rollback requires, rather than assume rollback
   speed is uniform across deployment strategies.
   source: caduh, "Blue-Green vs Canary vs Rolling Deployments" —
   https://www.caduh.com/blog/blue-green-vs-canary-vs-rolling-deployments

7. **When** a rollback completes, **choose** to write a postmortem
   documenting what the rollback trigger was and whether the threshold
   fired at the right sensitivity — a rollback with no postmortem loses
   the chance to tune the next release's thresholds.
   source: sre.google, "Release Engineering" (release process feeds
   back into future release policy) —
   https://sre.google/sre-book/release-engineering/

8. **When** repeated manual rollback steps recur release after release
   with no growing insight from doing them by hand, **choose** to
   automate the rollback path — a manual, repetitive, automatable step
   that produces no enduring value is toil by definition.
   source: sre.google, "Eliminating Toil" —
   https://sre.google/sre-book/eliminating-toil/

9. **When** feature-flag-gated code is the mechanism carrying a risky
   change, **choose** flag-flip-off as the first rollback action (faster
   than a full binary rollback) before falling back to a full release
   rollback if flipping the flag doesn't resolve the incident.
   source: Flagsmith, "How to Use Feature Flags for Trunk-Based
   Development" —
   https://www.flagsmith.com/blog/trunk-based-development-feature-flags

10. **REMOVAL** — **when** engineering time goes disproportionately into
    manual, reactive rollback firefighting (SRE toil budget target:
    engineering work should stay >=50% of time, toil <=50%), **choose**
    to invest in automating the rollback trigger and execution path
    rather than accept the recurring manual cost as a fixed feature of
    releases.
    source: sre.google, "Eliminating Toil" (the 50% toil ceiling) —
    https://sre.google/sre-book/eliminating-toil/

11. **REMOVAL** — **when** a rollback runbook has accumulated steps for
    scenarios that no longer occur (e.g. a deprecated deployment target),
    **choose** to prune those steps from the runbook rather than leave
    them for someone to skip manually during an incident — a bloated
    runbook adds cognitive load exactly when speed matters most.
    source: sciencedaily.com, summary of Adams, Converse, Hales & Klotz,
    "People systematically overlook subtractive changes," Nature 592
    (2021) — https://sciencedaily.com/releases/2021/04/210407135801.htm

12. **When** a rollback is triggered, **choose** to confirm the rollback
    target build's artifact and config bundle are the exact pairing that
    was previously live (not just "the previous version number") — a
    mismatched config/binary pairing can reintroduce the same incident
    under a different version tag.
    source: sre.google, "Release Engineering" (binary/config pairing via
    shared labels) — https://sre.google/sre-book/release-engineering/
