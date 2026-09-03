# TrailTrack — Location Tracking Rules

## Required Setup (non-negotiable)
- Request `NSLocationAlwaysAndWhenInUseUsageDescription` AND `NSLocationWhenInUseUsageDescription` in Info.plist, both with clear, honest descriptions of why location is needed
- Enable the **"Location updates"** Background Mode capability in Signing & Capabilities
- Do NOT confuse this with "Background Fetch" — Background Fetch is a periodic, OS-scheduled refresh mechanism and is NOT suitable for continuous location tracking. Do not suggest or implement it for this purpose.

## CLLocationManager Configuration
- Set `desiredAccuracy` appropriately for fitness tracking (e.g., `kCLLocationAccuracyBest` or `kCLLocationAccuracyNearestTenMeters`)
- Set a sensible `distanceFilter` (e.g., 5-10 meters) to avoid excessive updates and battery drain
- Set `allowsBackgroundLocationUpdates = true` and `pausesLocationUpdatesAutomatically = false` while a tracking session is active
- Reset `allowsBackgroundLocationUpdates = false` when tracking is stopped, to avoid unnecessary background permission usage

## Explicitly Out of Scope / Incorrect Approaches
- Do NOT suggest silent push notifications as a mechanism for keeping location tracking alive — this is incorrect and must not be used
- Do NOT attempt to make tracking resume after the user force-quits (swipes away) the app — this is an intentional iOS platform restriction, not a bug. Acknowledge this limitation in code comments where relevant instead of trying to work around it.

## Route Drawing
- Store recorded GPS points as they arrive and render them as a live polyline/trail on the MapKit `Map` view
- Calculate cumulative distance using `CLLocation.distance(from:)` between consecutive points, not straight-line start-to-end distance
- Consider a minimum-movement threshold between points to reduce GPS jitter inflating distance readings
