---
layer: ShowcaseApp
owns: ["app/**"]
depends_on: []
gate:
  test: swift test --package-path app
red_lines:
  - Consume Strata and DesignTokens only from the pinned shared-design-system package; never copy palettes or invent local token tables.
  - Theme is explicit on every Strata component call; propagate DesignTokens errors unchanged.
  - No business backend, user account, or private credential in the showcase app.
---

# Native Strata Showcase App (`ShowcaseApp`)

## Responsibility and interfaces

`ShowcaseApp` (`app/Package.swift` and `app/project.yml`) is the native SwiftUI
component workbench for `shared-design-system` (`Strata` and `DesignTokens`).
It provides `StrataShowcase` (reusable SwiftUI catalog views and state models)
and `StrataShowcaseApp` (native macOS/iOS host executable and screenshot exporter).

## Verification

`scripts/verify` runs `swift test --package-path app`, which compiles and tests
all showcase sections, state transitions, and 5-brand x Light/Dark theme
resolutions against the pinned `shared-design-system` revision.
