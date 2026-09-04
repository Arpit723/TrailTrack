//
//  TrackingViewModelTests.swift
//  TrailTrackTests
//
//  Created by Arpit Parekh on 04/09/26.
//

import SwiftData
import Testing
@testable import TrailTrack

@MainActor
struct TrackingViewModelTests {

    @Test func stopTrackingSavesSessionToSwiftData() throws {
        let container = try ModelContainer(
            for: TrackedSession.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(container)
        let viewModel = TrackingViewModel(locationManager: LocationManager())
        viewModel.modelContext = context

        viewModel.startTracking()
        viewModel.stopTracking()

        let sessions = try context.fetch(FetchDescriptor<TrackedSession>())
        #expect(sessions.count == 1)

        let session = try #require(sessions.first)
        #expect(session.routePoints.isEmpty)
        #expect(session.distanceMeters == 0)
        #expect(session.endDate >= session.startDate)
    }
}
