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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
