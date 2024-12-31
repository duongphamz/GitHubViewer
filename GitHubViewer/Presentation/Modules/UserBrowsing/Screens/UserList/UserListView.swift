//
//  UserListView.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import SwiftUI
import Combine

struct UserListView: View {
    
    // MARK: - Properties
    
    @StateObject var viewModel: UserListViewModel = UserListViewModel()
    @State private var navigationPath = NavigationPath() // Manages navigation stack
    @State private var didLoad: Bool = false // Ensures data is only loaded once during the view's lifecycle
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(viewModel.users) { user in
                // Display each user's information
                UserInfoView(
                    avatar: user.avatar,
                    userName: user.loginUserName,
                    type: .landingPage(user.landingPage)
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .onTapGesture {
                    // Navigate to UserDetailView when a user is tapped
                    if let userName = user.loginUserName {
                        navigationPath.append(userName)
                    }
                }
                .onAppear {
                    // Trigger loading more users when the last item appears
                    viewModel.viewInput.triggerLoadMoreIfNeed.send(user.id)
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle("Github Users", displayMode: .inline)
            .navigationDestination(for: String.self) { userName in
                // Navigate to the detail view when a user is tapped
                UserDetailView(userName: userName)
            }
            .onAppear {
                // Load the user list only once when the view first appears
                guard !didLoad else { return }
                didLoad.toggle()
                viewModel.fetchUserList()
            }
            .showErrorAlert(isError: $viewModel.isError, errorMessage: viewModel.errorMessage) // Show error alerts if needed
            .showLoadMoreIndicator(isLoading: $viewModel.isLoading) // Show a loading indicator when loading more data
        }
    }
}

#Preview {
    UserListView()
}
