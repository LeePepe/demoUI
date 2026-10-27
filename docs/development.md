# Development guide

## Architecture

[The root layer map](architecture/tech-context.md) and its layer leaves own
paths, interfaces and dependency direction. The runtime includes the historical
static browser prototype and the native `ShowcaseApp` SwiftUI showcase.
`ShowcaseApp` consumes the pinned `LeePepe/shared-design-system` package and its
native build/showcase verification runs through `swift test --package-path app`
via `scripts/verify`.

## PR kinds

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

## Verification and review sources

Prerequisites: Git, Bash, Python 3.9+ and Node.js supporting the existing .mjs
source. No npm install is needed. scripts/verify uses the metadata pin to obtain
a clean provider cache; it preserves and rejects any wrong or dirty cache.
An explicit SHARED_CI must already be a clean checkout at that exact SHA.

```sh
scripts/verify --all
scripts/verify --changed
```

The actual pre-push hook and CI invoke scripts/verify. With no origin/main or
merge base, the ordinary entry runs every layer. Contract audit and workflow
lint always run. Support/governance changes force all layer gates. For a local
Git command use `git -c core.hooksPath=.githooks ...` after checking no existing
hook would be replaced; do not change shared clone configuration or bypass an
existing hook. The bootstrap has no installed hooks by copying files alone.

| Check | Status and source |
| --- | --- |
| Tracked ownership, metadata, guide routing and fixed workflow pins | Enforced locally by the pinned context audit in scripts/verify; CI only after a real run |
| Workflow safety and full-SHA references | Enforced locally by pinned workflow lint in scripts/verify |
| Prototype JavaScript syntax | Enforced locally by Prototype gates through the same entry |
| Hook shell syntax | Enforced locally by bash -n in scripts/verify; actual hook evidence recorded externally |
| Prototype runtime/import direction and historical source preservation | Manual content/diff review; Node syntax is not an import-boundary test |
| Native App build, showcase and shared package consumption | `ShowcaseApp` (`app/**`) is verified by `swift test --package-path app` via `scripts/verify`; the package pin is `LeePepe/shared-design-system@30112ae881314a525f3ffcb3913a3b02b8d6cbe6` |
| Required checks, Owner review, App/Actions access and repository-scoped runner | Planned until exact remote capability/readback and current-head evidence exist |
| PR intent, kind and necessary companions | Manual independent content review, using this guide |

The protected repository guide embeds the complete pinned shared protocol and
the review-relevant PR kinds above. Update both in the same change when these
choices change. Review callers read that complete guide from trusted base;
a PR-head-only guide cannot establish trusted review.

## Shared design-system sync

`scripts/sync-strata.py` keeps the shared-design-system metadata, Swift package
manifest, lockfile, and guide reference aligned. The GitHub Actions workflow
opens a dependency/pin PR after `scripts/verify --all`; local work can use a
live checkout without changing the committed pin:

```sh
python3 scripts/sync-strata.py --local-override ../shared-design-system
python3 scripts/sync-strata.py --reset-override
python3 scripts/sync-strata.py --check
```

## Delivery

Use the repository PR template with the exact tested head. Keep evidence outside
the tracked tree. Never substitute local PASS for required CI or independent
acceptance. CODEOWNERS approval for protected changes remains with the Owner.
The two-stage first-repository bootstrap, its unapproved one-PR exception and
completion requirements are stated completely in the repository guide.
