//
//  UserDetailViewModel.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import Foundation
import Combine

class UserDetailViewModel: ObservableObject {
    
    // MARK: - Display Model
    
    // Structure to hold the user details to be displayed in the view
    struct DisplayModel {
        let userName: String?
        let avatar: String?
        let location: String?
        let followers: String?
        let following: String?
        let blog: String?
    }
    
    // MARK: - Properties
    
    let userDetailUseCase: UserDetailUseCaseType // Use case to fetch user details
    let userName: String
    
    private var cancellables = Set<AnyCancellable>() // Set to store Combine cancellables
    
    // Published properties to update the UI
    @Published var displayModel: DisplayModel? // The model to display user information in the view
    @Published var errorMessage: String? // Error message, if any, that occurred during data fetch
    @Published var isError: Bool = false // Flag to indicate if an error occurred
    
    // MARK: - Initializer
    
    init(userDetailUseCase: UserDetailUseCaseType = UserDetailUseCase(),
         userName: String) {
        self.userDetailUseCase = userDetailUseCase
        self.userName = userName
    }
    
    // MARK: - Deinitialization
    // Deinitializer to clear subscriptions
    deinit {
        cancellables.removeAll()
    }
    
    // MARK: - Methods
    
    // Function to fetch user details from the use case
    func fetchUserDetail() {
        // Reset any previous error messages
        errorMessage = nil
        
        // Call the use case to fetch user details
        userDetailUseCase.fetchUserDetail(userName: userName)
            .receive(on: DispatchQueue.main) // Ensure UI updates happen on the main thread
            .sink(receiveCompletion: { [weak self] completion in
                // Handle the completion of the network request
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // On failure, update the error message and flag
                    self?.errorMessage = error.localizedDescription
                    self?.isError = true
                }
            }, receiveValue: { [weak self] userDetail in
                // On success, convert the fetched user data into the display model
                self?.displayModel = self?.makeDisplayModel(from: userDetail)
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Private Helper Methods
    
    // Convert the fetched user networking data into a `DisplayModel`
    func makeDisplayModel(from user: User?) -> DisplayModel? {
        guard let user else { return nil }
        return DisplayModel(
            userName: user.loginUserName,
            avatar: user.avatar,
            location: user.location,
            followers: NumberFormatterUtils.formatGitHubNumber(user.followers ?? 0), // Formatted followers count
            following: NumberFormatterUtils.formatGitHubNumber(user.following ?? 0), // Formatted following count
            blog: user.blog
        )
    }
}
