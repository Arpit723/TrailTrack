//
//  StatCard.swift
//  TrailTrack
//
//  Created by Arpit Parekh on 03/09/26.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    StatCard(title: "Distance", value: "3.42 km")
        .padding()
}
