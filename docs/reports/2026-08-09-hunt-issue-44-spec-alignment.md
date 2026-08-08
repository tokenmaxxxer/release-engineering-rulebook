---
proposal: docs/issue-44/proposals/proposal.md
---

# Hunt record — issue-44-spec-alignment

## after-proposal — stance 1: assume the write set cannot carry this work — find the path phase-2 execution will need that the proposal does not list

Verdict: FINDING — write set omits the three gate scripts that hardcode-parse `ops/state.md`'s `status:` field by regex, so renaming/relocating that field per the proposal's own rationale ("Renaming the already-`status`-labeled operational field...") leaves those gates matching a field that no longer exists.
Kind: composition
Seed: git show df17282 --stat (docs/issue-44/proposals/proposal.md, docs/issue-44/reports/implementation/survey.md — proposal-phase diff only)
cap_seconds: 120
tier: default
diff_stat_lines: 267 (proposal+survey docs; but finding concerns files NOT in the diff or write set)
started_at: 2026-08-09T00:00:00Z
ended_at: 2026-08-09T00:02:00Z

### Reproduce
```
grep -n 'status:' error-budget-policy/hooks/error-budget-gate.sh readiness-checklist/hooks/readiness-fields-gate.sh postmortem/hooks/postmortem-review-gate.sh
```
Each shows a Python regex `re.search(r'(?m)^status:\s*(\S+)', ...)` run against `ops/state.md` content, gating transitions `-> readiness`, `-> rollout`, `-> steady` by literal field name `status`. None of these three files appear in `docs/issue-44/proposals/proposal.md`'s `files:` frontmatter, which lists only `ops/hooks/directive.sh` (the directive prose) among ops-related files.

### Observed
The proposal's own rationale section states the operational field ("referred to as `status` everywhere inside `ops/hooks/directive.sh` itself") will be renamed away from `loop_state`/reconciled with the spec's vocabulary, and frames `ops/hooks/directive.sh` as the file to change — but the actual field-name consumers are the three `hooks/*-gate.sh` scripts under `error-budget-policy/`, `readiness-checklist/`, and `postmortem/`, each independently hardcoding the string `status:` via regex. None of the three is in the frozen `files:` write set.

### Expected
If phase-2 execution only touches the eight files in the write set (README.md, docs/specs/record-fields-terminal-states.json, ops/hooks/directive.sh, proposal-norm/hooks/directive-fragment.txt, proposal-norm/hooks/proposal-fields-gate.sh, proposal-norm/hooks/tests/allow-deny-check.sh, docs/handbooks/changelog.md, docs/decisions/2026-08-09-loop-state-vs-status-split.md), any change to the operational field's name or vocabulary in `ops/state.md`-facing prose leaves the three gate scripts' regex targets silently unchanged — a field-name mismatch that produces no error, just gates that permanently match (or permanently fail to match) the wrong string. The write set should list the three gate scripts (or explicitly declare the operational field name/vocabulary as unchanged and out of scope) rather than the proposal implying a rename while touching only documentation and directive text.

### Resolution
Confirmed by re-reading the three gate scripts directly: each already
parses `^status:\s*(\S+)` today (`error-budget-policy/hooks/error-budget-gate.sh:118`,
`readiness-checklist/hooks/readiness-fields-gate.sh`,
`postmortem/hooks/postmortem-review-gate.sh:102,128`) — the field is
*already* named `status` in the actual operational file/gates. The
proposal's "rename" is a `README.md` documentation-label fix only
(README currently mislabels this field `loop_state`); no gate script's
regex target changes, so no gate script belongs in the write set. Proposal
text updated (`docs/issue-44/proposals/proposal.md` item 5) to state this
explicitly, citing the three gates' current line numbers as evidence the
fix is documentation-only. Finding closed, no write-set change needed.

## before-landing — stance 1: assume this change and another plugin's rule cancel each other — find the pair

Verdict: NO FINDING
Seed: staged diff for issue-44 phase-2 (proposal-fields-gate.sh change_type requirement; README.md/record-fields-terminal-states.json split vocab; ops/hooks/directive.sh + proposal-norm/hooks/directive-fragment.txt text updates)
cap_seconds: 180
tier: default
diff_stat_lines: 200 insertions(+), 14 deletions(-) across 9 files
started_at: 2026-08-09T05:31:06+09:00
ended_at: 2026-08-09T05:52:00+09:00

Searched for a genuine two-plugin cancellation involving the new change_type
requirement: compared proposal-fields-gate.sh's PROPOSAL_RE (docs/issue-<n>/
proposals/*.md) against readiness-fields-gate.sh, rollout-plan-fields-gate.sh,
error-budget-gate.sh, and postmortem-review-gate.sh -- none of those match
proposal paths, they all key off ops/state.md or ops/rollout-plan.md, so
there is no path overlap for a rule to compose against. Checked kill-switch
env var names (PROPOSAL_FIELDS_GATE_OFF, READINESS_FIELDS_GATE_OFF,
ROLLOUT_PLAN_FIELDS_GATE_OFF, ERROR_BUDGET_GATE_OFF,
POSTMORTEM_REVIEW_GATE_OFF) for collisions -- all distinct, no shared switch
that could turn two gates off together or let one silently permit what
another refuses. Checked whether the new record-fields-terminal-states.json
spec file's "ops-record" kind is consumed by any gate script -- it is
referenced only from markdown text (README, the proposal, a decision
record), not from any .sh hook, so it cannot collide with another gate's
kind resolution.

Along the way, reproduced a real defect (proposal-fields-gate.sh denies a
trivial no-op Edit to the already-merged docs/issue-44/proposals/proposal.md,
citing missing risk/rollback/change_type -- run with CLAUDE_PLUGIN_ROOT_CORE
pointed at the cached core gate-lib, exit code 2), but this is the gate being
inconsistent with its own past target, not two plugins' rules cancelling
each other, so it does not fit this stance's required pair and is not
reported as this stance's finding.
