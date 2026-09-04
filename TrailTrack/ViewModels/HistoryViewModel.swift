//
//  HistoryViewModel.swift
//  TrailTrack
//
//  Created by Arpit Parekh on 04/09/26.
//

import Foundation
import Observation
import SwiftData
import os

@MainActor
@Observable
final class HistoryViewModel {

    private static let logger = Logger(
        subsystem: "com.bk.trailtrack.TrailTrack",
        category: "HistoryViewModel"
    )

    private(set) var sessions: [TrackedSession] = []

    /// Injected from the view's `.modelContext` environment.
    var modelContext: ModelContext?

    /// Deletes a session from the store and refreshes the list.
    func deleteSession(_ session: TrackedSession) {
        guard let modelContext else {
            Self.logger.error("No modelContext injected — cannot delete session")
            return
        }
        modelContext.delete(session)
        do {
            try modelContext.save()
            sessions.removeAll { $0 === session }
            Self.logger.info("Deleted TrackedSession — id: \(session.id.uuidString, privacy: .public)")
        } catch {
            Self.logger.error("Failed to save after delete: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Re-fetches all sessions, most recent first.
    func loadSessions() {
        guard let modelContext else {
            Self.logger.error("No modelContext injected — cannot load sessions")
            return
        }
        let descriptor = FetchDescriptor<TrackedSession>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        do {
            sessions = try modelContext.fetch(descriptor)
        } catch {
            Self.logger.error("Failed to fetch sessions: \(error.localizedDescription, privacy: .public)")
        }
    }
}
