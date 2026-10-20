---
layer: _root
support:
  - patterns: ["AGENTS.md", "CLAUDE.md", "README.md", "docs/repository-guide.md", "docs/development.md"]
    reason: repository entry points and protected development/reviewer rules; contract audit and content review
  - patterns: [".github/**", ".githooks/pre-push", "scripts/verify"]
    reason: governance wiring; contract audit, workflow lint, shell syntax and actual hook verification
  - patterns: [".gitignore"]
    reason: cache and local-artifact exclusions; contract audit and diff review
red_lines:
  - Preserve the historical prototype and all design evidence.
  - No native App or shared-package dependency is implemented by this bootstrap.
---

# demoUI architecture

| Layer | Responsibility | tech-context | depends_on |
| --- | --- | --- | --- |
| Prototype | Historical browser theme workbench and its design evidence | `prototype/tech-context.md` | (none) |

The root map itself is excluded by the resolver. Support entries are explicit
non-layer material with the checks named above. The verify script is support
wiring, not a hidden source directory. All present runtime source belongs to
Prototype. There is no native App layer yet; T08 adds its own ownership and
one-way public package wiring when authorized.

The historical browser layer imports only its local token module. It does not
consume the Swift package, and its palettes are not production token authority.
The unified shared-design-system package remains external to this repository.

Layer ownership is authoritative here and in the listed leaf; PR kinds and
review responsibilities are in [development](../development.md#pr-kinds).
