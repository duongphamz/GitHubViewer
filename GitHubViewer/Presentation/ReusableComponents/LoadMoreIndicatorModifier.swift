//
//  LoadMoreIndicatorModifier.swift
//  GitHubViewer
//
//  Created by Duong Pham on 31/12/24.
//

import SwiftUI

struct LoadMoreIndicatorModifier: ViewModifier {
    @Binding var isLoading: Bool
    
    func body(content: Content) -> some View {
        VStack {
            content
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.8))
            }
        }
    }
}

extension View {
    /// Adds a "load more" indicator at the bottom of the view.
        /// - Parameter isLoading: A binding that determines whether the indicator is shown.
    func showLoadMoreIndicator(isLoading: Binding<Bool>) -> some View {
        modifier(LoadMoreIndicatorModifier(isLoading: isLoading))
    }
}
