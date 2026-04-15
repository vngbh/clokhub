---
name: clokhub-project-conventions
description: Use this skill when working on the clokhub iOS project to follow repository structure, SwiftUI, persistence, documentation, Git, branch, commit, and pull request conventions.
---

# clokhub Project Conventions

Use this file as the working agreement for every task in this repository. Before changing code, read the current project structure and keep this file updated when the structure changes.

## Language Convention

Use English across the project:

- Write documentation, `SKILL.md` files, comments, commit messages, branch names, PR titles, and PR descriptions in English.
- Spell the product name as `clokhub` in lowercase everywhere, including headings, user-facing copy, documentation, branch names, and PR titles.
- Write code identifiers, file names, folders, test names, fixtures, and accessibility identifiers in English.
- Use English as the default user-facing product copy unless a task is explicitly about localization.
- Put translations in dedicated localization resources if localization is added later.
- If a task finds non-English project text outside an explicit localization context, convert it to English in the same PR when the change is safe and closely related.

## Current Project Structure

```text
clokhub/
|-- README.md
|-- SKILL.md
|-- PRIVACY_POLICY.md
|-- Docs/
|   |-- APP_STORE_CHECKLIST.md
|   `-- APP_STORE_INFO.md
|-- clokhub.xcodeproj/
|   |-- project.pbxproj
|   `-- project.xcworkspace/
`-- clokhub/
    |-- App/
    |   `-- clokhubApp.swift
    |-- Assets.xcassets/
    |-- Components/
    |-- Models/
    |   `-- DayStatDTO.swift
    |-- Persistence/
    |   |-- DayStat+CoreDataClass.swift
    |   |-- DayStat+CoreDataProperties.swift
    |   |-- DoubleArrayTransformer.swift
    |   |-- PersistenceController.swift
    |   |-- PieStatsRepository.swift
    |   `-- clokhubModel.xcdatamodeld/
    |-- Support/
    |   |-- AppColors.swift
    |   |-- Formatters.swift
    |   `-- Extensions/
    |-- ViewModels/
    |   `-- PieStatsViewModel.swift
    `-- Views/
        |-- AnalystView.swift
        |-- ContentView.swift
        |-- LaunchView.swift
        |-- PersonalView.swift
        |-- RootView.swift
        `-- SettingsView.swift
```

Planned structure as the app grows:

```text
clokhub/
|-- SKILL.md
|-- App/
|-- Models/
|-- Views/
|-- Components/
|-- ViewModels/
|-- Persistence/
|-- Services/
|-- Support/
|-- Resources/
`-- Assets.xcassets/
```

Folder responsibilities:

- `App`: app entry point, app-level defaults, dependency setup, and root scene wiring.
- `Views`: SwiftUI screens and feature-level screen composition.
- `Components`: reusable SwiftUI components shared across screens.
- `ViewModels`: observable screen state, derived analytics, validation, and coordination between views and persistence.
- `Models`: plain Swift data types and lightweight data transfer models.
- `Persistence`: Core Data stack, entities, transformers, repositories, migrations, and persistence-specific helpers.
- `Services`: reusable business logic that is not persistence-specific. Create this folder only when needed.
- `Support`: app colors, formatters, extensions, and small generic helpers.
- `Resources`: localization, static data, and non-asset resource files. Create this folder only when needed.
- `Assets.xcassets`: compiled colors, icons, images, launch logo, and runtime image assets.
- `Docs`: App Store, release, and support documentation.

Structure change rule:

- Update this `SKILL.md` whenever files or folders are added, removed, renamed, or meaningfully reorganized.
- If a task introduces a new architectural layer, shared service, resource convention, or feature grouping, update this file in the same PR.
- If a task only edits implementation inside the existing structure, no structure update is required unless the current convention becomes misleading.

## SwiftUI And App Architecture

- Keep SwiftUI views focused on presentation, user interaction, and view composition.
- Put reusable visual building blocks in `Components`.
- Keep screen-specific state and derived values in `ViewModels` when the logic outgrows a single view.
- Keep business rules and persistence behavior out of SwiftUI views when they can live in testable Swift code.
- Keep timer continuity and reset behavior explicit because it spans app lifecycle notifications, `UserDefaults`, and analytics persistence.
- Use `@EnvironmentObject` only for shared app state that multiple screens need.
- Avoid adding global singletons beyond existing app-level persistence unless there is a clear lifecycle reason.

## Persistence And Data Rules

- Keep Core Data setup and access under `clokhub/Persistence`.
- Use `PersistenceController` for the Core Data container.
- Use repository types, such as `PieStatsRepository`, for Core Data reads and writes instead of spreading fetch requests through views.
- Store lightweight app settings and in-progress timer state in `UserDefaults`.
- Store historical daily analytics in Core Data.
- Preserve Japan Standard Time day-boundary behavior unless a task explicitly changes the product requirement.
- Treat Core Data model changes as migration-sensitive. Document model changes and verify app launch after editing `.xcdatamodeld`.

## Code Quality

- Prefer small, focused types and functions with clear names.
- Keep one responsibility per model, repository, view model, view, or component.
- Avoid duplicating business logic; extract shared calculation, formatting, or persistence logic when repetition becomes meaningful.
- Prefer readable code over clever code.
- Delete dead code instead of leaving commented-out blocks.
- Add comments only when intent is not obvious from the code itself.
- Keep public APIs minimal and meaningful.
- Preserve existing project style unless there is a strong reason to improve it.
- Keep unrelated refactors out of a task branch.

## Path And Import Hygiene

- Use repository-root-relative paths in documentation, for example `clokhub/Views/ContentView.swift`.
- Avoid hard-coded machine-specific paths in source code and documentation.
- Prefer platform APIs such as `Bundle`, `FileManager`, asset catalogs, Core Data, and typed resources instead of fragile hand-built paths.
- Keep imports minimal and remove unused imports when touching a file.
- Do not add global path helpers unless they remove real repetition or confusion.

## Documentation

- Keep README content current with the actual app structure, requirements, and architecture.
- Keep App Store and release notes under `Docs`.
- Keep privacy-facing content in `PRIVACY_POLICY.md`.
- When behavior changes user-visible functionality, update README or Docs if existing documentation would become inaccurate.
- Do not mix setup notes, release notes, and project conventions into one document; use README for onboarding and this file for working rules.

## Generated File Hygiene

- Keep generated build outputs, user-specific IDE state, simulator artifacts, `.DS_Store`, and local environment files out of Git.
- Prefer updating `.gitignore` when repeated generated files appear in `git status`.
- Do not ignore source files, shared project configuration, assets, fixtures, or documentation needed by other developers.
- If a generated file is already tracked, remove it from Git tracking in the same PR that adds the ignore rule, unless the user asks to keep the change documentation-only.

## Xcode Project Hygiene

- Treat `clokhub.xcodeproj/project.pbxproj` as tracked source configuration, not as a generated file.
- Commit `project.pbxproj` only when the task intentionally changes Xcode configuration, such as targets, build settings, packages, resources, signing, or asset catalog wiring.
- If `project.pbxproj` only changes because Xcode reordered sections, normalized whitespace, or rewrote equivalent content during open/build, restore that no-op diff before committing.
- Always inspect `git diff -- clokhub.xcodeproj/project.pbxproj` before staging it.
- Do not add `clokhub.xcodeproj/project.pbxproj` to `.gitignore`.

## Git Workflow

Every task should be done on its own branch and completed through a pull request. Do not push task changes directly to `main`.

Before starting a task:

```sh
git status --short --branch
git switch main
git pull --ff-only
git switch -c docs/short-doc-name
```

If the workspace has user changes, do not overwrite or revert them. If there is no remote or network access is unavailable, skip `git pull --ff-only` and note that validation.

Branch naming:

```text
feature/short-task-name
fix/short-bug-name
docs/short-doc-name
refactor/short-refactor-name
test/short-test-name
chore/short-maintenance-name
ci/short-ci-name
build/short-build-name
```

If the local Git environment cannot create slash-based branch names, use the same prefix with hyphens, for example `docs-update-readme`.

## Commit Convention

Commit messages must follow:

```text
type(scope): message
```

Use this shorter form when no clear scope is needed:

```text
type: message
```

Allowed types:

- `feat`: new feature or user-facing capability.
- `fix`: bug fix.
- `docs`: documentation-only change.
- `style`: formatting or visual polish without behavior changes.
- `refactor`: code restructuring without changing behavior.
- `test`: adding or updating tests.
- `chore`: maintenance, project settings, dependency, or tooling changes.
- `ci`: continuous integration workflows and checks.
- `build`: build system, Xcode project settings, dependency, packaging, or release build changes.
- `perf`: performance improvement without changing behavior.
- `revert`: revert a previous commit.

Examples:

```text
docs(readme): update project onboarding
feat(timer): add activity labels
fix(reset): preserve logical day boundary
refactor(persistence): isolate day stat fetches
test(stats): add logical date coverage
build(xcode): add test target
```

Keep commits focused. If one task changes unrelated areas, split it into separate commits or separate branches.

## Pull Request Convention

Each task should open a pull request before merging to `main`.

PR title format:

```text
[Edited Place] Content Here
```

Examples:

```text
[README] Refresh Project Onboarding
[Timer] Preserve Background Elapsed Time
[Persistence] Add Day Stat Migration
```

PR body format:

```markdown
## Summary
Short explanation of what changed and why.

## Details
+ Added ...
+ Updated ...
+ Fixed ...
+ Tested ...
```

Rules:

- Keep `Summary` concise and user-facing.
- Use `Details` for concrete implementation notes.
- Include testing notes in `Details`.
- Mention known limitations or follow-ups if the task is intentionally incomplete.
- Do not merge a PR if the app does not build or relevant tests fail, unless the PR explicitly documents why.

## Validation

Run a relevant build before opening a PR:

```sh
xcodebuild \
  -project clokhub.xcodeproj \
  -scheme clokhub \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

If the exact simulator does not exist, list available devices and pick one:

```sh
xcrun simctl list devices available
```

Always check the diff before committing:

```sh
git status --short --branch
git diff
```

There are no test targets in the current repository. Add unit or UI test targets before relying on automated tests for timer calculations, Core Data migrations, or user flows.
