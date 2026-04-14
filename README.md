# clokhub

clokhub is a lightweight iOS time tracker for following up to three activities in a simple daily cycle. It stores data locally, keeps the active timer moving across app lifecycle changes, and summarizes tracked time with pie chart analytics.

## Features

- Track three activity buckets from one focused timer screen.
- Keep timer state across foreground, background, and app termination events.
- Configure a custom daily reset time, with Japan Standard Time used for day boundaries.
- Review daily activity distribution in a monthly calendar.
- Store all activity data locally with Core Data.
- Use a clean SwiftUI interface with lightweight animations.

## Requirements

- Xcode 16 or later
- iOS 18.5 or later
- macOS with the iOS simulator runtime, or a physical iPhone or iPad
- Apple Developer account for device signing or App Store distribution

## Getting Started

```bash
git clone https://github.com/vngbh/clokhub.git
cd clokhub
open clokhub.xcodeproj
```

In Xcode, select the `clokhub` scheme, choose a simulator or device, then run the app.

## Project Structure

```text
clokhub/
  App/                 App entry point
  Assets.xcassets/     App icons, launch logo, colors, and image assets
  Components/          Reusable SwiftUI components
  Models/              Lightweight data transfer models
  Persistence/         Core Data stack, entities, transformers, and repositories
  Support/             Shared formatting, colors, and extensions
  ViewModels/          Observable view models
  Views/               App screens
```

## Architecture

- SwiftUI for the interface layer.
- ObservableObject view models for UI state and derived analytics.
- Core Data for local persistence.
- UserDefaults for lightweight timer and settings state.
- Repository-style persistence access through `PieStatsRepository`.

## Documentation

- `Docs/APP_STORE_INFO.md` contains App Store listing content.
- `Docs/APP_STORE_CHECKLIST.md` contains release preparation notes.
- `PRIVACY_POLICY.md` describes the app privacy policy.
