//
//  TrackingView.swift
//  TrailTrack
//
//  Created by Arpit Parekh on 03/09/26.
//

import MapKit
import SwiftUI

@MainActor
struct TrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @State private var viewModel = TrackingViewModel(locationManager: LocationManager())
    @State private var cameraPosition: MapCameraPosition = .userLocation(
        followsHeading: true,
        fallback: .automatic
    )

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLocationPermissionDenied {
                    permissionDeniedView
                } else {
                    ZStack {
                        mapLayer
                        VStack(spacing: 8) {
                            statsCard
                            if viewModel.isWaitingForSignal {
                                waitingForSignalChip
                            }
                            Spacer()
                            startStopButton
                        }
                        .padding(16)
                    }
                    .onChange(of: viewModel.routePoints.count) { _, _ in
                        guard viewModel.isTracking, let newCoordinate = viewModel.latestCoordinate else { return }
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: newCoordinate,
                                latitudinalMeters: 500,
                                longitudinalMeters: 500
                            )
                        )
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Label("History", systemImage: "clock.fill")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
            .task {
                viewModel.modelContext = modelContext
                viewModel.requestLocationAuthorization()
            }
            .navigationTitle("TrailTrack").navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Permission denied

    private var permissionDeniedView: some View {
        VStack(spacing: 8) {
            Image(systemName: "location.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
                .padding(.bottom, 8)
            Text("Location Access Needed")
                .font(.headline)
            Text("TrailTrack needs location access to record your walks and runs. Enable it in Settings to start tracking.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    openURL(settingsURL)
                }
            } label: {
                Label("Open Settings", systemImage: "gearshape.fill")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding(16)
    }

    // MARK: - GPS signal

    private var waitingForSignalChip: some View {
        Label("Waiting for GPS signal…", systemImage: "antenna.radiowaves.left.and.slash")
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.thinMaterial, in: Capsule())
    }

    // MARK: - Map

    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
            if viewModel.routePoints.count > 1 {
                MapPolyline(
                    MKPolyline(
                        coordinates: viewModel.routePoints,
                        count: viewModel.routePoints.count
                    )
                )
                .stroke(.blue, lineWidth: 4)
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Stats overlay

    private var statsCard: some View {
        HStack(spacing: 8) {
            StatCard(title: "Distance", value: distanceText)
            StatCard(title: "Time", value: viewModel.elapsedTime)
            StatCard(title: "Pace", value: viewModel.currentPace)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var distanceText: String {
        let kilometers = viewModel.distanceMeters / 1000
        return kilometers.formatted(.number.precision(.fractionLength(2))) + " km"
    }

    // MARK: - Start / Stop

    private var startStopButton: some View {
        Button {
            viewModel.isTracking ? viewModel.stopTracking() : viewModel.startTracking()
        } label: {
            Label(
                viewModel.isTracking ? "Stop" : "Start",
                systemImage: viewModel.isTracking ? "stop.fill" : "play.fill"
            )
            .font(.title2.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .background(
            viewModel.isTracking ? Color.red : Color.green,
            in: Capsule()
        )
        .animation(.easeInOut(duration: 0.2), value: viewModel.isTracking)
    }
}

#Preview {
    TrackingView()
}
