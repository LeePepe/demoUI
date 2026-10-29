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
Prototype gates run node --check app.mjs and node --check tokens.mjs, and the
ShowcaseApp gate runs swift test --package-path app.
Without origin/main or a merge base the normal hook runs all gates, even when
there is no comparison diff. Governance/support changes also force a full run.
A wrong/dirty provider cache fails without replacement. The native ShowcaseApp
build and tests are verified through the Swift package gate.
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
The public repository choice and initial seed/bootstrap scheme are approved.
App installation access must still be read back for the actual repository. A personal-account runner is repository-scoped: another repository's
registration cannot be moved, shared or reused. New runner/host/credential work
requires a separately defined external Owner prerequisite; this bootstrap does
not authorize registration, services, credentials or host changes.

## Red lines

Keep the existing prototype source, design rules, screenshots and Git history.
Its five color families, light/dark, glass/solid, simulated interactions and
fallback evidence are historical reference, not production Swift token authority.
Do not copy those palettes into the future native App. The unified external
shared-design-system owns production tokens and both public Swift products.
This governance diff adds no token change, shared provider/gate change, release,
product migration, native shell or UI feature. Approved public remote creation
and exact seed import are separate S1 operations. Live settings and local
directory move remain later stages. A missing prerequisite is reported to
the assigning lead; do not repair outside owned paths or reduce acceptance.
Actual policy/gate/permission changes and protected paths need Owner approval.
Never commit credentials, local evidence or machine-specific identity paths.

## Dependencies

The exact shared-ci provider is metadata's single authority; all protocol and
reusable workflow links match it. The native app pins
LeePepe/shared-design-system@8b30a919485345da6c9b9c94faa9c79537477376 in
`.github/repo-contract.json`, `app/Package.swift`, and `app/Package.resolved`.
The historical Node modules require no package install.

## Delivery

Every PR uses the declared base, one observable goal, an existing kind, necessary
companion docs/tests and the repository PR template. Every new head invalidates
old command, CI and review evidence. PRM uses existing outcomes without a separate
size/scope report. Owner alone approves this bootstrap's protected paths.
Independent V1–V3 acceptance is assigned separately; writer checks are self-checks.

### Automated Strata synchronization

The `sync-strata` workflow listens for `shared-design-system` updates, periodic
catch-up checks, and manual dispatches. It opens a dependency/pin PR after
running `scripts/verify --all`; it does not change the pinned shared-ci
provider or the embedded protocol snapshot.

For local development, link an adjacent checkout and restore the pinned
revision with:

```sh
python3 scripts/sync-strata.py --local-override ../shared-design-system
python3 scripts/sync-strata.py --reset-override
```

Use `python3 scripts/sync-strata.py --check` to verify that metadata, the Swift
manifest, and the lockfile agree.

### TestFlight release wiring

The `testflight` workflow runs after successful `ci` on `main`, on the
scheduled cadence, or by manual dispatch. `scripts/testflight-gate.py` checks
the `testflight/last-released..HEAD` range and releases only when native app or
release dependency paths changed (unless manually forced). The self-hosted
release job fails closed when App Store Connect, keychain, bundle, or team
configuration is absent; credentials are supplied only through repository
secrets/variables. Local signing overrides belong in the ignored
`config/Signing.local.xcconfig`, copied from the committed example.

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


### First-governance bootstrap: initial scheme approved, final exception pending

Owner approved D1 creation of the independent public demoUI remote and separately
approved D3 initial exact seed import and the staged bootstrap scheme. The sole
initial main candidate is existing prototype commit
b4bff430517ed2e2944f814d8b5ab89a1866ee33, preserving ancestor
13a8fec56cea32611f38258fa846800936b9582a. No orphan seed, rewritten prototype
history or direct governance push to main is allowed.

D3 has an initial decision about exact seed import and the proposed staged
bootstrap, followed by a final one-PR exception decision bound to exact PR head,
diff, independent verdict, successful quality and Owner protected-path approval.
The initial decision is approved; the final one-PR exception remains unapproved.
The initial approvals do not grant live settings or a governance merge.

1. S0 is local candidate/verification/final body/Owner packet and independent
   review only. It does not complete T07 or unlock T08.
2. S1 has explicit D1/public and D3 initial approval. The assigned writer uses
   the App route for the approved creation attempt, verifies an empty public
   remote and ordinary access, then uses the ordinary hook to push only the
   exact seed as initial main. Capability failure returns to the lead; do not
   switch identities, overwrite an existing repository or infer access from 404.
3. S2 Owner applies the approved initial ruleset: deletion and non-fast-forward
   blocked, PR required, approvals 0, no code-owner review, no bypass
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
   App access and runner status. Only then may independent
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
  [repository development contract](https://github.com/LeePepe/shared-ci/blob/fd8a187ef4872aa1aa69c4e9afec9782183cc02d/ai/repo-contract.md#repository-development-contract).
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
  test-code corrections follow §6; required checks and AI review remain mandatory.
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

Describe the source of a change accurately in PRs, commit messages and comments.
Unverifiable claims that the Owner requested or approved a change are non-blocking
notes, including for protected paths. Optional verified Owner decisions provide
context; they are never a prerequisite for a change or merge.

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
  exact-head evidence, enable GitHub auto-merge when the PR opens, and follow it
  through merged-state readback.
  Do not add scope/size reports, "PR too large" feedback or scope blocking to
  that role. This does not waive any existing required check or review.
- **Stacked PRs** are allowed only as a temporary queue. Once the base PR
  merges, retarget the next PR to the default branch and rebase it onto that
  branch, dropping the base PR's pre-squash commits
  (`git rebase --onto origin/main <old-base-tip>`), before it merges. A squash
  merge rewrites the base commits, so a stacked branch that is not rebased
  will conflict or carry duplicate changes.
  PRs may be reviewed in parallel, but dependent slices wait for prerequisites
  to merge in order; this queue never bypasses required checks or AI review.

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
| Removed or weakened tests or policy | Each item with its reason, or `none` |
| Test evidence | `scripts/verify` result and the **tested SHA** (the PR head) |

The `quality / aggregate` check rejects empty or placeholder sections.

## 5. Evidence belongs to one SHA

- Evidence (checks, reviews, the tested SHA in the PR body) is valid only for
  the commit it names. **Every new push invalidates the old evidence.** Wait
  for the new required checks and a new review before you claim the work is
  done.
- Handing over a PR is an intermediate lifecycle event, not "done". A finished
  local run is not "done", and a sent message alone is not an accepted
  handoff or completion signal.
- After PR handoff, the author may either:
  - remain active to wait for the required checks on the current PR head and
    repair failures; or
  - stop after handoff. The protocol does not require continued waiting.
- When an author remains active, it waits only for required checks and concrete
  repair results; it never waits for human approvals. Required checks and AI review remain
  mandatory; GitHub auto-merge performs the merge without human approval.
- PR Manager handles lifecycle as defined in §4 and serves as the backstop when
  the author is not waiting or is unavailable. PR Manager follows current-head
  CI and AI review evidence, and routes concrete repair findings through
  the original path. It does not write to the branch and gains no new gate.
- During repair, the author remains the sole branch writer under §1; nobody
  else is assigned to write concurrently, and unexpected writers still require
  stopping and reporting. Every repair push must follow §3 verification before
  pushing. Because each push invalidates prior checks, reviews and tested-SHA
  evidence, any later completion claim requires fresh evidence for the new
  PR head.
- "Done" means the required checks are green on the exact PR head SHA plus any
  required AI review evidence. No human approval is required; delivery also
  records the auto-merge result on the exact head. PR handoff never
  waives these gates.

## 6. Auto-merge without human approval

Every non-Draft PR uses GitHub auto-merge from the time it opens. Once required
checks and required AI review pass on the exact head, GitHub merges it without
Owner, code-owner or other approving reviews. This applies to all PR sources
and all paths, including gates, CI, review rules, CODEOWNERS and rulesets.
Do not add an approval label or wait for an Owner decision. CODEOWNERS is not
required for review, approval or protection. Never disable auto-merge to hold a PR. Track its checks and merge result, and route concrete repair findings
to the original writer.

Test changes still need a stated reason, CI and AI review. Security and privacy
red lines and CI trust boundaries remain blocking. Optional Owner decisions can
clarify intent but cannot waive those red lines or required checks. Unverifiable
Owner request/approval claims are non-blocking notes for every path.

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
