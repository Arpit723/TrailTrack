# TrailTrack — UI Conventions

## Screen Structure
- Use `NavigationStack` for navigation between the tracking screen and history screen
- Every screen's root view should be a single, clearly named SwiftUI `View` struct — no deeply nested anonymous views

## Visual Style
- Use SF Symbols for all icons (e.g., `location.fill`, `play.fill`, `stop.fill`, `clock.fill`)
- Standard padding: 16pt for screen edges, 8pt between related elements
- Use `.font(.headline)` for section titles, `.font(.subheadline)` or `.font(.caption)` for secondary text (e.g., timestamps, distances in history list)

## Live Tracking Screen
- Map should fill the majority of the screen
- Distance / time / pace overlay should float over the map (e.g., a rounded rectangle card at the top or bottom), not push the map into a smaller area
- Start/Stop button should be large, clearly reachable with a thumb, and change color/label based on state (e.g., green "Start" vs red "Stop")

## History Screen
- Use a simple `List` with one row per session: date, distance, duration
- Empty state (no sessions yet) should show a clear message and icon, not a blank screen

## General
- Support both light and dark mode using system colors (`.primary`, `.secondary`, system backgrounds) rather than hardcoded colors
- Keep view code readable — extract repeated UI into small reusable subviews rather than duplicating layout code
