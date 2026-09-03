# TrailTrack — Project Context

## What This Project Is
A SwiftUI iOS app that tracks a user's walk/run in real time, drawing their travelled path on a map, with session history. Built as a portfolio/interview-prep project — code quality and correctness matter more than speed of output.

## Tech Stack (do not deviate without asking)
- SwiftUI, iOS 17+
- Apple MapKit (`Map` view, `MapPolyline`) — NOT Google Maps
- Core Location (`CLLocationManager`)
- SwiftData for persistence — NOT Core Data, NOT UserDefaults
- No third-party dependencies / no CocoaPods / no SPM packages unless explicitly requested

## Architecture Conventions
- MVVM pattern: Views stay thin, business logic lives in `@Observable` view models
- SwiftData models are simple structs/classes with clear property names — no premature abstraction

## Scope Discipline
- Only build what's in the current task being requested — do not add extra screens, settings, or features not explicitly asked for
- If a task seems to need something outside current scope, ask before adding it rather than assuming

## Working Style
- After generating code for a task, briefly explain what was changed and why, in plain terms
- Flag any assumption made if the task description was ambiguous, rather than silently picking one interpretation
