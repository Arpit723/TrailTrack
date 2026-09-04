//
//  HistoryView.swift
//  TrailTrack
//
//  Created by Arpit Parekh on 04/09/26.
//

import SwiftData
import SwiftUI

@MainActor
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HistoryViewModel()
    @State private var sessionPendingDeletion: TrackedSession?

    private var deleteConfirmationShown: Binding<Bool> {
        Binding(
            get: { sessionPendingDeletion != nil },
            set: { if !$0 { sessionPendingDeletion = nil } }
        )
    }

    var body: some View {
        Group {
            if viewModel.sessions.isEmpty {
                ContentUnavailableView(
                    "No sessions yet",
                    systemImage: "figure.walk",
                    description: Text("Record your first walk or run from the tracking screen.")
                )
            } else {
                List(viewModel.sessions) { session in
                    NavigationLink {
                        HistoryDetailView(session: session)
                    } label: {
                        SessionRow(session: session)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            sessionPendingDeletion = session
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
        .alert(
            "Should I delete the session?",
            isPresented: deleteConfirmationShown,
            presenting: sessionPendingDeletion
        ) { session in
            Button("Delete", role: .destructive) {
                viewModel.deleteSession(session)
            }
            Button("Cancel", role: .cancel) {}
        } message: { session in
            Text("The session from \(session.startDate, format: .dateTime.day().month().hour().minute()) will be permanently deleted.")
        }
        .task {
            viewModel.modelContext = modelContext
            viewModel.loadSessions()
        }
    }
}

private struct SessionRow: View {
    let session: TrackedSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.startDate, format: .dateTime.day().month().year().hour().minute())
                .font(.headline)
            HStack(spacing: 8) {
                Text(distanceText)
                Text(session.formattedDuration)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var distanceText: String {
        (session.distanceMeters / 1000).formatted(.number.precision(.fractionLength(2))) + " km"
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(for: TrackedSession.self, inMemory: true)
}
