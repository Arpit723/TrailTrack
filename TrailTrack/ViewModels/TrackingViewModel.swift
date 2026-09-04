//
//  TrackingViewModel.swift
//  TrailTrack
//
//  Created by Arpit Parekh on 03/09/26.
//

import CoreLocation
import Foundation
import Observation
import SwiftData
import os

@MainActor
@Observable
final class TrackingViewModel {

    private static let logger = Logger(
        subsystem: "com.bk.trailtrack.TrailTrack",
        category: "TrackingViewModel"
    )

    private let locationManager: LocationManager

    private(set) var isTracking = false
    private(set) var elapsedSeconds: TimeInterval = 0

    private var sessionStartDate: Date?
    private var ticker: Task<Void, Never>?

    /// Injected from the view's `.modelContext` environment so completed
    /// sessions can be persisted to SwiftData.
    var modelContext: ModelContext?

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
        let now = Date()
        sessionStartDate = now
        elapsedSeconds = 0
        locationManager.startTracking()
        isTracking = true
        startTicker()
        Self.logger.info("Tracking session started at \(now.formatted(.iso8601), privacy: .public)")
    }

    func stopTracking() {
        guard isTracking else { return }
        ticker?.cancel()
        ticker = nil
        locationManager.stopTracking()
        isTracking = false
        Self.logger.info("Tracking session stopped")
        saveCompletedSession()
    }

    private func saveCompletedSession() {
        guard let modelContext else {
            Self.logger.error("No modelContext injected — completed session was NOT saved")
            return
        }
        guard let sessionStartDate else { return }
        let session = TrackedSession(
            startDate: sessionStartDate,
            endDate: Date(),
            distanceMeters: distanceMeters,
            routePoints: locationManager.routePoints.map {
                RoutePoint(latitude: $0.latitude, longitude: $0.longitude)
            }
        )
        modelContext.insert(session)
        do {
            try modelContext.save()
            Self.logger.notice("Saved TrackedSession — id: \(session.id.uuidString, privacy: .public), start: \(session.startDate.formatted(.iso8601), privacy: .public), end: \(session.endDate.formatted(.iso8601), privacy: .public), points: \(session.routePoints.count), distance: \(session.distanceMeters, format: .fixed(precision: 1)) m, duration: \(session.endDate.timeIntervalSince(session.startDate), format: .fixed(precision: 1)) s")
        } catch {
            Self.logger.error("Failed to save tracked session: \(error.localizedDescription, privacy: .public)")
        }
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
