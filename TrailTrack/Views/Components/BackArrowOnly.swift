//
//  BackArrowOnly.swift
//  TrailTrack
//
//  Created by Arpit Parekh on 04/09/26.
//

import SwiftUI

extension View {
    /// Replaces the system back button (which repeats the previous screen's
    /// title) with a bare chevron.
    func backArrowOnly() -> some View {
        modifier(BackArrowOnlyModifier())
    }
}

private struct BackArrowOnlyModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .fontWeight(.semibold)
                    }
                    .accessibilityLabel("Back")
                }
            }
    }
}
