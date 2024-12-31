//
//  UserListViewModel.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Constants

private enum Constant {
    static let usersPerPage: Int = 20 // Number of users to fetch per page
}

// MARK: - View Model

class UserListViewModel: ObservableObject {
    // MARK: - Properties
    
    // Use case for fetching user list, injected for better testability and abstraction
    let userListUseCase: UserListUseCaseType
    
    // Published properties to update the UI
    @Published var users: [User] = [] // List of users fetched from the backend
    @Published var isLoading: Bool = false // Indicates if a fetch operation is in progress
    @Published var errorMessage: String? // Stores an error message when an operation fails
    @Published var isError: Bool = false // Indicates if there is an error to display
    
    // Private properties
    private var cancellables: Set<AnyCancellable> = [] // Set to manage Combine subscriptions
    private var currentOffset: Int = 0 // Tracks the current offset for pagination
    private var isLoadMoreEnabled: Bool = true // Enables/disables further data loading
    
    // Input structure to handle events from the view
    struct ViewInput {
        let triggerLoadMoreIfNeed = PassthroughSubject<Int?, Never>() // Subject to trigger load-more logic
    }
    let viewInput: ViewInput = .init()
    
    // MARK: - Initializer
    
    init(userListUseCase: UserListUseCaseType = UserListUseCase()) {
        self.userListUseCase = userListUseCase
        setupViewInputs()
    }
    
    // Deinitializer to clear subscriptions
    deinit {
        cancellables.removeAll()
    }
    
    // MARK: - Setup Methods
    
    /// Sets up view inputs and binds the load-more trigger to the fetch logic
    private func setupViewInputs() {
        viewInput
            .triggerLoadMoreIfNeed
            .removeDuplicates() // Ensures the same trigger isn't processed multiple times
            .filter { [weak self] itemId in
                guard let self else { return false }
                // Trigger load more only if the last user matches the given ID, not loading, and loading more is still enabled
                return self.users.last?.id == itemId && !self.isLoading && self.isLoadMoreEnabled
            }
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                self.fetchUserList() // Fetch more users when the conditions are met
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Data Fetching
    
    /// Fetches the user list from the use case
    func fetchUserList() {
        
        isLoading = true // Set loading state to true at the beginning of the operation
        errorMessage = nil // Clear any previous error messages
        
        userListUseCase.fetchUsers(since: currentOffset)
            .receive(on: DispatchQueue.main) // Ensure updates are performed on the main thread
            .sink(receiveCompletion: { [weak self] completion in
                // Handle the result of the fetch operation
                switch completion {
                case .finished:
                    break // Do nothing when the operation is successful
                case .failure(let error):
                    // Update error state and message when an error occurs
                    self?.errorMessage = error.localizedDescription
                    self?.isError = true
                }
                // Set loading state to false when operation is completed
                self?.isLoading = false
            }, receiveValue: { [weak self] users in
                guard let self else { return }
                self.users.append(contentsOf: users)
                self.currentOffset += users.count
                self.isLoadMoreEnabled = users.count == Constant.usersPerPage
            })
            .store(in: &cancellables)
    }
}
