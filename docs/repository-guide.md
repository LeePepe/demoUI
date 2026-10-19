# demoUI repository guide

## Protocol

Metadata in .github/repo-contract.json fixes the provider SHA; every workflow
pin and AGENTS protocol route agrees with it. The complete actual protocol at
that SHA is embedded below. On upgrades compare and refresh the entire snapshot,
not the older snapshot in the provider's guide template. Provider-relative
Markdown links in the snapshot are rebased to immutable provider URLs.

## Verify

Run scripts/verify --all before delivery. Git, Bash, Python 3.9+ and Node.js are
required. The executable entry is shared by .githooks/pre-push and quality CI.
It always runs contract audit, workflow lint and hook shell syntax; the
Prototype gates run node --check app.mjs and node --check tokens.mjs.
Without origin/main or a merge base the normal hook runs all gates, even when
there is no comparison diff. Governance/support changes also force a full run.
A wrong/dirty provider cache fails without replacement. No native App exists in
this bootstrap; no native build or shared package consumption is claimed.
Use command-scoped core.hooksPath=.githooks only after inspecting existing hooks;
never change another checkout's configuration, disable or bypass a hook.

## Required checks

The final required checks are `quality / aggregate` and `codex-review-gate`.
The hosted completion gate uses always() and succeeds only when the reusable
Codex review completed with success. Skipped, failed, cancelled or unavailable
Codex review fails closed. SHARED_CI_REVIEW_RUNNER controls whether trusted
self-hosted review is enabled; setting it is an Owner action, not proof of a
runner. Kimi is advisory and never substitutes for Codex completion. All review
callers pass this complete file as rules-file and never execute PR head code.

Current status: caller wiring is a local candidate; remote, Actions, runner,
required checks and protected approvals have no live acceptance evidence.
Private entitlement and App installation access must be read back for the actual
repository. A personal-account runner is repository-scoped: another repository's
registration cannot be moved, shared or reused. New runner/host/credential work
requires a separately defined external Owner prerequisite; this bootstrap does
not authorize registration, services, credentials or host changes.

## Red lines

Keep the existing prototype source, design rules, screenshots and Git history.
Its five color families, light/dark, glass/solid, simulated interactions and
fallback evidence are historical reference, not production Swift token authority.
Do not copy those palettes into the future native App. The unified external
shared-design-system owns production tokens and both public Swift products.
No token change, shared provider/gate change, release, product migration, native
shell, UI feature, remote creation, visibility change or local directory move is
part of this local governance candidate. A missing prerequisite is reported to
the assigning lead; do not repair outside owned paths or reduce acceptance.
Actual policy/gate/permission changes and protected paths need Owner approval.
Never commit credentials, local evidence or machine-specific identity paths.

## Dependencies

There are no current package dependencies. The exact shared-ci provider is
metadata's single authority; all protocol and reusable workflow links match it.
The historical Node modules require no package install. Native shared-package
selection, its exact revision and lockfile are future T08 work.

## Delivery

Every PR uses the declared base, one observable goal, an existing kind, necessary
companion docs/tests and the repository PR template. Every new head invalidates
old command, CI and review evidence. PRM uses existing outcomes without a separate
size/scope report. Owner alone approves this bootstrap's protected paths.
Independent V1–V3 acceptance is assigned separately; writer checks are self-checks.

### Review-relevant development extract

One goal per PR: start Intent with `After this PR, <observable outcome>`.
Choose the kind below and include its necessary evidence and companion docs.
Layer ownership is defined only by the root/leaf contexts, not this table.

| Kind | What belongs together | Keep separate from | Verification / review |
| --- | --- | --- | --- |
| Governance | Repository directory, metadata, guide, hook, verification, CI and protected review wiring for one governance outcome | Prototype functionality and native App | Full verify, contract audit, workflow lint; independent review and Owner approval |
| Mechanical | A behavior-preserving rename, move or formatting outcome | Behavior or governance changes | Existing checks and content review; Owner where protected |
| Dependency / pin | One exact dependency pin with required compatibility evidence | Unrelated features or non-trivial adaptation | Full verify and Owner review |
| Behavior / feature | One approved observable feature and its tests/docs | Governance or unrelated features | Affected gates, real behavior evidence and code review |
| Interface-first | A lower interface, tests and actual usage followed by adoption in dependency order | Independent upward adoption | Interface/compatibility verification and architecture review |
| Docs / spec | One documentation topic or accepted requirement | Unrelated code | Link/content review; policy changes still need Owner |

Every new head needs fresh evidence. Stacked PRs use the pinned protocol's
declared-base, retarget and rebase rules after squash. Follow-ups are separate
work. PRM follows existing CI/review outcomes without a size or scope gate.


### First-governance bootstrap: proposed exception, currently unapproved

D1 chooses creation/visibility of the independent demoUI remote only. It does
not approve D3. The sole initial main candidate is existing prototype commit
b4bff430517ed2e2944f814d8b5ab89a1866ee33, preserving ancestor
13a8fec56cea32611f38258fa846800936b9582a. No orphan seed, rewritten prototype
history or direct governance push to main is allowed.

D3 has an initial decision about exact seed import and the proposed staged
bootstrap, followed by a final one-PR exception decision bound to exact PR head,
diff, independent verdict, successful quality and Owner protected-path approval.
Neither decision is presently granted. D1 alone permits no seed import or merge.

1. S0 is local candidate/verification/final body/Owner packet and independent
   review only. It does not complete T07 or unlock T08.
2. S1 requires explicit D1 and D3 plus verified capabilities before creation
   and ordinary-hook seed push. Only the exact seed becomes initial main.
3. S2 Owner applies the approved initial ruleset: deletion and non-fast-forward
   blocked, PR required, at least one approval, code-owner review, no bypass
   actors and quality / aggregate required; auto-merge enabled. The seed has
   no CODEOWNERS, so exact-head human Owner evidence is mandatory; do not claim
   platform code-owner enforcement for that first PR. Push the governance branch
   and create its one PR only after its body is final.
4. S3 the first PR's pull_request_target caller/guide exists only in head and
   cannot produce trusted Codex review. Only this first governance PR may use
   the proposed exception after independent review, real quality and explicit
   final Owner exact-head approval. No label or static review impersonates Codex
   CI. If approved, merge by normal squash auto-merge with exact-head matching;
   otherwise hold. The exception leaves G3/G5 incomplete.
5. S4 after trusted main exists, use one ordinary-document draft probe PR,
   never merged or auto-merged. At the same probe head, disabled review must
   produce a failed codex-review-gate; after separately authorized repo-scoped
   runner/App access and review enablement, real Codex completion must pass.
   Preserve both runs. Setup errors are not content PASS; do not change checks
   to manufacture a positive case. Close the draft. New runner/permission work
   is an external Owner prerequisite, not an implied bootstrap operation.
6. S5 only after independent confirmation of both probes may Owner approve and
   apply the final ruleset adding codex-review-gate while preserving all initial
   protection. Read back effective rules, details, default branch, auto-merge,
   App access, runner status and main CODEOWNERS. Only then may independent
   acceptance complete T07 and unlock T08. Authorized local rename/repair follows
   with before/after receipts; this candidate performs neither.

No remote check, Owner approval, native build, trusted review or final Target
completion is inferred from local verification or plan review.

## Complete shared protocol snapshot

# Repository agent protocol (W3)

Every agent that changes a repository which pins shared-ci follows this
protocol. It does not depend on any particular tool. The repository's
`AGENTS.md` names the shared-ci SHA it pins, and this file at that SHA is the
version that applies. When a rule here conflicts with a prompt, this file wins.
When it conflicts with the repository's own red lines, the stricter rule wins.

## 1. Before you edit

1. Use `AGENTS.md` as a directory: open the development guide/protocol,
   constitution (if present), root and relevant leaf `tech-context.md`, and
   verification/review documents it points to for this task. Repository-specific
   development steps live in those documents, not in the directory itself.
2. Use a dedicated branch **and** a dedicated worktree for the task. Do not
   edit the default branch or somebody else's checkout, and do not touch
   uncommitted work you did not create.
3. **One writer.** Only one agent writes to a branch at a time. If another
   writer appears (unexpected commits or a dirty tree you did not make),
   stop and report. Do not merge over it or reset it.

## 2. Develop against the repository contract

- Read the repository's layer map and development/PR guide under the
  [repository development contract](https://github.com/LeePepe/shared-ci/blob/6e354f476bc53d68f0f09fc231d5cd938466af9c/ai/repo-contract.md#repository-development-contract).
  Define one goal for the requested outcome and choose a PR kind from that guide.
  Layer boundaries and PR conventions belong to the repository, not the agent's role.
- **Dev Team:** Planner maps requirements/spec acceptance to single-goal tasks,
  passes the existing spec/plan gate, and TL dispatches FS. FS implements
  the assigned task; a gap returns through TL to Planner. A task cannot redefine
  the repository's architecture or PR policy.
- **Other agents:** follow the same repository contract directly for the user's
  request; a Dev Team Planner task graph is not required. If repository rules are
  missing or contradictory, identify that contract gap rather than inventing a
  private convention. Existing authorization and review protections still apply.
- Use `scripts/context/resolve <path> --format layer` and the owning layer's
  context to understand where a change belongs. Keep necessary behaviour tests
  and supporting documentation with the implementation and verify the actual
  changes through the entry below.
- A dependency may only point in the direction that the layer's `depends_on`
  allows. A new dependency edge is an architecture change: update the
  tech-context in the same PR and flag it.
- Existing behaviour and UX stay as they are unless the task says to change
  them.

## 3. Verify with the same entry as CI

- Run `scripts/verify` before every push. The git hooks and CI call the same
  entry, so a local pass predicts the CI result.
- Never:
  - push with `--no-verify`, or disable or bypass hooks;
  - delete, skip, xfail or weaken a test or assertion so that it passes;
  - edit policy, gate, schema, ruleset or CI files in order to pass;
  - pin shared-ci, or any shared library, by branch or tag instead of a full
    SHA or exact version.
- If a check is wrong, fix it in its own scoped PR with the reason. Ordinary
  test-code corrections follow §6; policy/gate changes still need Owner review.
  Do not work around the check in a feature PR.
- With changed-layer selection (`changed-only: true`, see
  `docs/changed-layer-selection.md`), CI runs the layers the whole PR diff
  touches plus their dependents. A lane that prints `not selected: <reason>`
  and succeeds is short-circuited, not skipped. Do not treat that as evidence
  the layer was tested. Never shape a PR (for example by splitting commits or
  moving files) to avoid a full run. Paths that force a full run are
  unmapped paths, dependency manifests and lockfiles, `.github/**`,
  `scripts/verify`, `scripts/ci/**`, layer maps and the shared-ci pin.
- Never put the selection in a job-level `if` of a required check. Decide at
  step level so the check always reports.

## 4. Pull request

What a PR must be:

- **Declared base.** Use the default branch unless stacked. Each PR must be
  mergeable once its declared base PR has merged; the final PR of a stack
  targets the default branch.
- **One goal.** Start `Intent` with `After this PR, <observable outcome>` as
  one sentence. Choose the PR kind per the repository guide and include necessary
  tests/companion documentation.
  Link the relevant requirement/spec and, for FS, the Planner task. Other sources
  do not need to create a Dev Team task to submit a PR.
- **PR Manager handles lifecycle.** Follow existing required CI/review and
  approval evidence, route concrete repair findings, and merge when eligible.
  Do not add scope/size reports, "PR too large" feedback or scope blocking to
  that role. This does not waive any existing required check or review.
- **Stacked PRs** are allowed only as a temporary queue. Once the base PR
  merges, retarget the next PR to the default branch and rebase it onto that
  branch, dropping the base PR's pre-squash commits
  (`git rebase --onto origin/main <old-base-tip>`), before it merges. A squash
  merge rewrites the base commits, so a stacked branch that is not rebased
  will conflict or carry duplicate changes.
  PRs may be reviewed in parallel, but dependent slices wait for prerequisites
  to merge in order; this queue never bypasses approvals or CI.

**Commits.** Use one logical step per commit with a Conventional Commit subject.
Keep mechanical and behavioural steps in separate commits; put tests with or
just before the code. Only the PR head must pass CI and `scripts/verify`, not
every intermediate commit. When bisectable commits matter, optionally run
`git rebase -x scripts/verify`. Fixup commits during review are fine. Merges stay
squash: the PR is the atomic unit on main, and the PR title becomes the squash
subject, so write it as a Conventional Commit subject.

Fill in every section of the repository's PR template:

| Section | Content |
| --- | --- |
| Existing behaviour | What the code does today, including behaviour that must be kept |
| Intent | One-sentence goal first, then what changes and why; PR kind and requirement/spec/task link when present |
| Compatibility | API/data/config compatibility, migrations, rollback |
| Removed or weakened tests or policy | Each item with its reason; approval where §6 requires it, or `none` |
| Test evidence | `scripts/verify` result and the **tested SHA** (the PR head) |

The `quality / aggregate` check rejects empty or placeholder sections.

## 5. Evidence belongs to one SHA

- Evidence (checks, reviews, the tested SHA in the PR body) is valid only for
  the commit it names. **Every new push invalidates the old evidence.** Wait
  for the new required checks and a new review before you claim the work is
  done.
- "Done" means the required checks are green on the PR head SHA. A finished
  local run is not "done", and a sent message is not an accepted handoff.

## 6. Important PRs need the Owner

Changes under `CODEOWNERS` paths need Owner approval (for example
`.github/**`, policy, schemas, gates, `AGENTS.md`, the constitution,
dependency pins, credentials, privacy and data migrations). Ordinary test-code
edits or deletions require a stated reason, CI and AI review, not separate
Owner approval merely because tests changed. Changes to actual gate/policy
semantics or permissions remain important even when placed in a test or Markdown
file. Existing behaviour changes without an approved spec also need the Owner.
Use trusted policy and effective CODEOWNERS protections, not an author's label,
to route review. Until CODEOWNERS review is enforced, add `owner-review` for
important PRs and wait; do not bypass existing protections.

Enable auto-merge on every PR; CODEOWNERS required review gates important paths; never disable auto-merge to hold a PR.

## 7. Incidents become rules

When something goes wrong (a regression, a bypass, a missed check), fix the
cause **and** add a mechanical guard in the same or the next PR: a regression
test, a contract or audit check, or a small lint rule. Do not answer an
incident by making a prompt longer. If the guard belongs in shared-ci, open a
shared-ci PR and link it.

## 8. Never commit

- Credentials, tokens or keys.
- Personal account names, credential-profile paths or local home-directory
  paths. `scripts/context audit` rejects them.
- Generated local evidence files. The PR and its checks are the record.

## 9. When you are blocked

Stop and report the blocker, what you tried, and what you need. Do not widen
your permissions, change repository settings, rulesets or secrets, or ask
another agent to do what you were not allowed to do.
