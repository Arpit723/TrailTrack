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
}
