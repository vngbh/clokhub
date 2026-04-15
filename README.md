# clokhub

clokhub is a lightweight iOS time tracker for following three activity buckets through a simple daily cycle. The app keeps the active timer moving across foreground, background, and termination events, stores data locally, and summarizes each logical day with pie chart analytics.

## Features

- Track one of three activity buckets from a focused circular timer.
- Keep elapsed time continuous across app lifecycle changes.
- Choose a custom daily reset time for logical day boundaries.
- Use Japan Standard Time for day grouping and reset calculations.
- Review daily activity distribution in a monthly analytics view.
- Store timer state and settings with `UserDefaults`.
- Store historical daily percentages locally with Core Data.
- Run as a native SwiftUI app with lightweight animations and reusable components.

## Requirements

- Xcode 16 or later
- iOS 18.5 or later
- macOS with an iOS simulator runtime, or a physical iPhone or iPad
- Apple Developer account for device signing or App Store distribution

## Getting Started

Clone the repository and open the Xcode project:

```bash
git clone https://github.com/vngbh/clokhub.git
cd clokhub
open clokhub.xcodeproj
```

In Xcode, select the `clokhub` scheme, choose a simulator or device, then run the app.

## Build

Use Xcode for normal development, or build from the command line:

```bash
xcodebuild \
  -project clokhub.xcodeproj \
  -scheme clokhub \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

If that simulator is unavailable, list installed devices and choose an available iOS simulator:

```bash
xcrun simctl list devices available
```

## Project Structure

```text
clokhub/
|-- README.md
|-- SKILL.md
|-- PRIVACY_POLICY.md
|-- Docs/
|   |-- APP_STORE_CHECKLIST.md
|   `-- APP_STORE_INFO.md
|-- clokhub.xcodeproj/
`-- clokhub/
    |-- App/
    |   `-- clokhubApp.swift
    |-- Assets.xcassets/
    |-- Components/
    |-- Models/
    |-- Persistence/
    |   |-- clokhubModel.xcdatamodeld/
    |   |-- PersistenceController.swift
    |   `-- PieStatsRepository.swift
    |-- Support/
    |   `-- Extensions/
    |-- ViewModels/
    `-- Views/
```

Folder responsibilities:

- `App`: app entry point, app-level defaults, and root scene wiring.
- `Views`: SwiftUI screens such as launch, timer, analytics, profile, and settings.
- `Components`: reusable SwiftUI components shared across screens.
- `ViewModels`: observable state and derived analytics for the UI.
- `Models`: lightweight data transfer models.
- `Persistence`: Core Data stack, managed object classes, value transformers, and repositories.
- `Support`: shared colors, formatters, and small extensions.
- `Assets.xcassets`: app icons, launch logo, accent color, avatar, and runtime image assets.
- `Docs`: App Store and release preparation documentation.

## Architecture

clokhub keeps the interface layer in SwiftUI and the persistence layer in Core Data:

- `ContentView` owns the live timer interaction and writes lightweight timer state to `UserDefaults`.
- `PieStatsViewModel` prepares live and historical values for analytics views.
- `PieStatsRepository` reads and writes daily percentage values through Core Data.
- `PersistenceController` owns the shared `NSPersistentContainer`.
- `Formatters`, color definitions, and extensions live under `Support`.

The app currently stores all user data locally on device. It does not use cloud storage or an external backend.

## Data Model

Core Data stores `DayStat` records keyed by logical date. Each record contains the daily activity distribution as a `[Double]` value transformed through `DoubleArrayTransformer`.

Live in-progress state is stored separately in `UserDefaults`:

- `startHour` and `startMinute` for the daily reset time.
- `lastResetDate` for reset bookkeeping.
- `accumulatedTimes`, `selectedIndex`, and `lastSavedTime` for timer continuity.

## Documentation

- `SKILL.md` defines repository conventions for future work.
- `Docs/APP_STORE_INFO.md` contains App Store listing content.
- `Docs/APP_STORE_CHECKLIST.md` contains release preparation notes.
- `PRIVACY_POLICY.md` describes the app privacy policy.

## Development Notes

- Keep product spelling as `clokhub` in lowercase.
- Keep project documentation, code comments, branch names, commits, and pull requests in English.
- Put reusable UI in `Components` unless a component only belongs to one screen.
- Keep Core Data and persistence behavior under `Persistence`.
- Add test targets before introducing high-risk calculation, persistence migration, or user-flow changes.
