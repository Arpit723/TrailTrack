//
//  LocationManager.swift
//  TrailTrack
//
//  Created by Arpit Parekh on 03/09/26.
//

import CoreLocation
import Observation

/// Wraps CLLocationManager for recording a walk/run route.
///
/// Note: tracking correctly stops if the user force-quits the app — this is
/// expected iOS behavior, not a bug to work around.
@MainActor
@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {

    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private(set) var isTracking = false
    private(set) var routePoints: [CLLocationCoordinate2D] = []

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
    }

    /// Call once at app launch to show the initial When-In-Use permission prompt.
    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        // Each tracking session is a fresh recording: drop any points left
        // over from a previous session.
        routePoints = []

        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            // Upgrade to Always so the route keeps recording in the background.
            // Background delivery only actually happens once Always is granted.
            manager.requestAlwaysAuthorization()
        default:
            break
        }

        // "Location updates" background mode (NOT Background Fetch).
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        manager.startUpdatingLocation()
        isTracking = true
    }

    func stopTracking() {
        manager.allowsBackgroundLocationUpdates = false
        manager.stopUpdatingLocation()
        isTracking = false
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard self.isTracking else { return }
            self.routePoints.append(contentsOf: locations.map(\.coordinate))
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            print("LocationManager error: \(error.localizedDescription)")
        }
    }
}
