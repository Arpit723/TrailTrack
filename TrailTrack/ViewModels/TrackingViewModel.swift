//
//  TrackingViewModel.swift
//  TrailTrack
//
//  Created by Arpit Parekh on 03/09/26.
//

import CoreLocation
import Foundation
import Observation

@MainActor
@Observable
final class TrackingViewModel {

    private let locationManager: LocationManager

    private(set) var isTracking = false
    private(set) var elapsedSeconds: TimeInterval = 0

    private var sessionStartDate: Date?
    private var ticker: Task<Void, Never>?

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }

    // MARK: - Route (pass-through for the map polyline)

    var routePoints: [CLLocationCoordinate2D] {
        locationManager.routePoints
    }

    // MARK: - Live stats

    /// Cumulative distance along the recorded route, summed between
    /// consecutive points (not straight-line start-to-end).
    var distanceMeters: Double {
        let points = locationManager.routePoints
        guard points.count > 1 else { return 0 }

        var total = 0.0
        for index in 1..<points.count {
            let previous = CLLocation(
                latitude: points[index - 1].latitude,
                longitude: points[index - 1].longitude
            )
            let current = CLLocation(
                latitude: points[index].latitude,
                longitude: points[index].longitude
            )
            total += current.distance(from: previous)
        }
        return total
    }

    var elapsedTime: String {
        let total = Int(elapsedSeconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var currentPace: String {
        let kilometers = distanceMeters / 1000
        guard kilometers >= 0.01, elapsedSeconds > 0 else { return "--:--" }
        let paceMinutes = (elapsedSeconds / 60) / kilometers
        let minutes = Int(paceMinutes)
        let seconds = Int((paceMinutes - Double(minutes)) * 60)
        return String(format: "%d:%02d /km", minutes, seconds)
    }

    // MARK: - Session control

    func startTracking() {
        guard !isTracking else { return }
        sessionStartDate = Date()
        elapsedSeconds = 0
        locationManager.startTracking()
        isTracking = true
        startTicker()
    }

    func stopTracking() {
        guard isTracking else { return }
        ticker?.cancel()
        ticker = nil
        locationManager.stopTracking()
        isTracking = false
    }

    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - Elapsed-time ticker

    private func startTicker() {
        ticker?.cancel()
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                self.refreshElapsedTime()
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    private func refreshElapsedTime() {
        guard let sessionStartDate else { return }
        elapsedSeconds = Date().timeIntervalSince(sessionStartDate)
    }
}
