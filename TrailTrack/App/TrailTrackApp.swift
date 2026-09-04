//
//  TrailTrackApp.swift
//  TrailTrack
//
//  Created by Arpit Parekh on 03/09/26.
//

import SwiftUI
import SwiftData

@main
struct TrailTrackApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TrackedSession.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TrackingView()
                .task { debugPrintSavedSessions() }
        }
        .modelContainer(sharedModelContainer)
    }

    #if DEBUG
    /// Debug check on launch: dumps all saved sessions to the console.
    private func debugPrintSavedSessions() {
        let context = ModelContext(sharedModelContainer)
        do {
            let sessions = try context.fetch(FetchDescriptor<TrackedSession>())
            print("DEBUG: \(sessions.count) saved TrackedSession(s) found on launch")
            for session in sessions {
                print(
                    "DEBUG: session \(session.id.uuidString) — "
                        + "start: \(session.startDate.formatted(.iso8601)), "
                        + "distance: \(String(format: "%.1f", session.distanceMeters)) m, "
                        + "points: \(session.routePoints.count)"
                )
            }
        } catch {
            print("DEBUG: failed to fetch saved sessions on launch: \(error)")
        }
    }
    #endif
}
