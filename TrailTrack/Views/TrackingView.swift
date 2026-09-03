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
    @State private var viewModel = TrackingViewModel(locationManager: LocationManager())
    @State private var cameraPosition: MapCameraPosition = .userLocation(
        followsHeading: true,
        fallback: .automatic
    )

    var body: some View {
        ZStack {
            mapLayer
            VStack(spacing: 8) {
                statsCard
                Spacer()
                startStopButton
            }
            .padding(16)
        }
        .task { viewModel.requestLocationAuthorization() }
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
