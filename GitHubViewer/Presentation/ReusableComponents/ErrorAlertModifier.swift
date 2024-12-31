//
//  ErrorAlertModifier.swift
//  GitHubViewer
//
//  Created by Duong Pham on 31/12/24.
//

import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    @Binding var isError: Bool
    let errorMessage: String?
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: $isError) {
                Alert(
                    title: Text("Error!!!"),
                    message: Text(errorMessage ?? ""),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
}

extension View {
    func showErrorAlert(isError: Binding<Bool>, errorMessage: String?) -> some View {
        self.modifier(ErrorAlertModifier(isError: isError, errorMessage: errorMessage))
    }
}
