//
//  LocationManager.swift
//  TrailTrack
//
//  Created by Arpit Parekh on 03/09/26.
//

import CoreLocation
import Observation
import os

/// Wraps CLLocationManager for recording a walk/run route.
///
/// Note: tracking correctly stops if the user force-quits the app — this is
/// expected iOS behavior, not a bug to work around.
@MainActor
@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {

    private static let logger = Logger(
        subsystem: "com.bk.trailtrack.TrailTrack",
        category: "LocationManager"
    )

    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    private(set) var isTracking = false
    private(set) var routePoints: [CLLocationCoordinate2D] = []
    private(set) var lastLocationDate: Date?

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
        let leftoverCount = routePoints.count
        routePoints = []
        lastLocationDate = nil
        if leftoverCount > 0 {
            Self.logger.info("New session: dropped \(leftoverCount) leftover route point(s)")
        }

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
        Self.logger.info("Location updates started")
    }

    func stopTracking() {
        manager.allowsBackgroundLocationUpdates = false
        manager.stopUpdatingLocation()
        isTracking = false
        Self.logger.info("Location updates stopped — route contains \(self.routePoints.count) point(s)")
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            Self.logger.log("Authorization status: \(String(describing: manager.authorizationStatus), privacy: .public)")
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Temporary debug logging — remove after verifying delegate firing rate.
        for location in locations {
            print("DEBUG didUpdateLocations: \(location.coordinate.latitude), \(location.coordinate.longitude) @ \(location.timestamp.formatted(.iso8601))")
        }
        Task { @MainActor in
            guard self.isTracking else { return }
            self.routePoints.append(contentsOf: locations.map(\.coordinate))
            self.lastLocationDate = Date()
            Self.logger.debug("Recorded \(locations.count) location(s); route total: \(self.routePoints.count)")
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            Self.logger.error("Location update failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
