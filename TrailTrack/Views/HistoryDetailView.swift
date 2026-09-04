//
//  HistoryDetailView.swift
//  TrailTrack
//
//  Created by Arpit Parekh on 04/09/26.
//

import MapKit
import SwiftUI

struct HistoryDetailView: View {
    let session: TrackedSession

    @State private var cameraPosition: MapCameraPosition

    init(session: TrackedSession) {
        self.session = session
        _cameraPosition = State(
            initialValue: Self.cameraPosition(covering: session.routePoints)
        )
    }

    var body: some View {
        ZStack {
            mapLayer
            VStack {
                Spacer()
                statsCard
            }
            .padding(16)
        }
        .navigationTitle(Text(session.startDate, format: .dateTime.day().month().hour().minute()))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Map (static route)

    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            if session.routePoints.count > 1 {
                MapPolyline(
                    MKPolyline(
                        coordinates: routeCoordinates,
                        count: routeCoordinates.count
                    )
                )
                .stroke(.blue, lineWidth: 4)
            }
        }
        .ignoresSafeArea()
    }

    private var routeCoordinates: [CLLocationCoordinate2D] {
        session.routePoints.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
    }

    /// Center-and-span camera that fits the whole recorded route.
    private static func cameraPosition(covering points: [RoutePoint]) -> MapCameraPosition {
        guard let first = points.first else { return .automatic }

        var minLatitude = first.latitude
        var maxLatitude = first.latitude
        var minLongitude = first.longitude
        var maxLongitude = first.longitude
        for point in points {
            minLatitude = min(minLatitude, point.latitude)
            maxLatitude = max(maxLatitude, point.latitude)
            minLongitude = min(minLongitude, point.longitude)
            maxLongitude = max(maxLongitude, point.longitude)
        }

        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLatitude - minLatitude) * 1.4, 0.01),
            longitudeDelta: max((maxLongitude - minLongitude) * 1.4, 0.01)
        )
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (minLatitude + maxLatitude) / 2,
                longitude: (minLongitude + maxLongitude) / 2
            ),
            span: span
        )
        return .region(region)
    }

    // MARK: - Stats

    private var statsCard: some View {
        HStack(spacing: 8) {
            StatCard(title: "Distance", value: distanceText)
            StatCard(title: "Duration", value: session.formattedDuration)
            StatCard(title: "Pace", value: paceText)
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var distanceText: String {
        (session.distanceMeters / 1000).formatted(.number.precision(.fractionLength(2))) + " km"
    }

    private var paceText: String {
        let kilometers = session.distanceMeters / 1000
        guard kilometers >= 0.01 else { return "--:--" }
        let paceMinutes = (session.duration / 60) / kilometers
        let minutes = Int(paceMinutes)
        let seconds = Int((paceMinutes - Double(minutes)) * 60)
        return String(format: "%d:%02d /km", minutes, seconds)
    }
}

#Preview("Route") {
    let points = (0..<10).map { i in
        RoutePoint(latitude: 37.33 + Double(i) * 0.001, longitude: -122.03 + Double(i) * 0.002)
    }
    let session = TrackedSession(
        startDate: .now.addingTimeInterval(-1800),
        endDate: .now,
        distanceMeters: 2350,
        routePoints: points
    )
    return NavigationStack {
        HistoryDetailView(session: session)
    }
}

#Preview("Empty route") {
    NavigationStack {
        HistoryDetailView(
            session: TrackedSession(
                startDate: .now.addingTimeInterval(-600),
                endDate: .now,
                distanceMeters: 0
            )
        )
    }
}
