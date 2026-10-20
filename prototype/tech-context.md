---
layer: Prototype
owns: ["app.mjs", "tokens.mjs", "styles.css", "index.html", "design/**", "prototype/tech-context.md"]
depends_on: []
gate:
  check-app: node --check app.mjs
  check-tokens: node --check tokens.mjs
red_lines:
  - Preserve prototype source and historical design artifacts during governance bootstrap.
  - Browser palettes are historical reference, never SwiftUI production token authority.
  - No account, backend, business data or external service is introduced.
---

# Historical Strata browser prototype

## Responsibility and interfaces

The static workbench demonstrates five color families, light/dark and glass/solid
using local simulated Button/Card/List interactions. URL parameters persist the
selected theme; JSON download reports the effective material. The sole runtime
module import is app.mjs to ./tokens.mjs. HTML loads that module and styles.css;
there are no package dependencies, test targets or production Swift interfaces.
Design rules, screenshots and the previous browser validation remain in design/.

## Verification

The two declared Node syntax gates run through scripts/verify. They establish
JavaScript syntax only. Existing browser evidence in design/validation.md is
historical and is not refreshed or promoted to native/production acceptance.
Import-boundary enforcement is manual from the unchanged source; a declaration
and syntax checks do not establish runtime dependency or visual correctness.
No native build, UI tests, accessibility certification or package consumption is
claimed here.
