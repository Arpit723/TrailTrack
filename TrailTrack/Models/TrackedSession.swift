//
//  TrackedSession.swift
//  TrailTrack
//
//  Created by Arpit Parekh on 03/09/26.
//

import Foundation
import SwiftData

/// A single coordinate recorded during a tracking session, stored as plain
/// Doubles because CLLocationCoordinate2D is not directly storable in SwiftData.
struct RoutePoint: Codable, Equatable {
    let latitude: Double
    let longitude: Double
}

@Model
final class TrackedSession {
    var id: UUID
    var startDate: Date
    var endDate: Date
    var distanceMeters: Double
    var routePoints: [RoutePoint]

    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        distanceMeters: Double,
        routePoints: [RoutePoint] = []
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.distanceMeters = distanceMeters
        self.routePoints = routePoints
    }

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    var formattedDuration: String {
        Self.formatDuration(duration)
    }

    var formattedDistance: String {
        (distanceMeters / 1000).formatted(.number.precision(.fractionLength(2))) + " km"
    }

    var formattedPace: String {
        Self.formatPace(elapsedSeconds: duration, distanceMeters: distanceMeters)
    }

    static func formatDuration(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    static func formatPace(elapsedSeconds: TimeInterval, distanceMeters: Double) -> String {
        let kilometers = distanceMeters / 1000
        guard kilometers >= 0.01, elapsedSeconds > 0 else { return "--:--" }
        let paceMinutes = (elapsedSeconds / 60) / kilometers
        let minutes = Int(paceMinutes)
        let seconds = Int((paceMinutes - Double(minutes)) * 60)
        return String(format: "%d:%02d /km", minutes, seconds)
    }
}
