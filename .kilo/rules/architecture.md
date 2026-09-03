# TrailTrack — Architecture

## Pattern: MVVM

## Folder Structure
```
TrailTrack/
├── App/
│   └── TrailTrackApp.swift        (app entry point, SwiftData ModelContainer setup)
├── Models/
│   └── TrackedSession.swift       (SwiftData model, RoutePoint struct)
├── Views/
│   ├── TrackingView.swift         (live tracking screen)
│   ├── HistoryView.swift          (session list screen)
│   ├── HistoryDetailView.swift    (single past session's route)
│   └── Components/                (small reusable subviews, e.g. StatCard, MapPolylineView)
├── ViewModels/
│   ├── TrackingViewModel.swift    (drives TrackingView: start/stop, live stats)
│   └── HistoryViewModel.swift     (drives HistoryView: fetching/listing sessions)
└── Services/
    └── LocationManager.swift      (CLLocationManager wrapper — see location-tracking.md)
```

## Layer Responsibilities

**Models** — plain data: `TrackedSession` (SwiftData `@Model`), `RoutePoint` (Codable struct for lat/lng). No logic beyond basic computed properties (e.g., a formatted duration string).

**Views** — SwiftUI views only. No direct `CLLocationManager` or SwiftData query logic inside a View — views read from and call methods on their ViewModel.

**ViewModels** — `@Observable` classes. Own the business logic:
- `TrackingViewModel` holds a reference to `LocationManager`, exposes live distance/time/pace, and handles start/stop actions, including saving a finished `TrackedSession` to SwiftData.
- `HistoryViewModel` queries SwiftData for past sessions and exposes them to `HistoryView`.

**Services** — `LocationManager` is the one Service in this app: it wraps `CLLocationManager` and knows nothing about UI or SwiftData. ViewModels talk to it, not Views directly.

## Data Flow
`CLLocationManager` (Service) → `TrackingViewModel` (transforms raw locations into distance/pace, manages session state) → `TrackingView` (renders it) → on Stop, `TrackingViewModel` saves a `TrackedSession` via SwiftData → `HistoryViewModel` reads saved sessions for `HistoryView`.

## Rule
Do not let a View talk directly to `LocationManager` or to the SwiftData `ModelContext` — always go through the relevant ViewModel. This keeps the architecture consistent and testable.
