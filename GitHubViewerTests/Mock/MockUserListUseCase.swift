//
//  MockUserListUseCase.swift
//  GitHubViewerTests
//
//  Created by Duong Pham on 31/12/24.
//

@testable import GitHubViewer
import Combine

class MockUserListUseCase: UserListUseCaseType {
    
    // MARK: - Stub
    var shouldReturnError = false
    var usersToReturn: [User] = []

    func fetchUsers(since: Int) -> AnyPublisher<[User], APIError> {
        if shouldReturnError {
            return Fail(error: APIError.unknown)
                .eraseToAnyPublisher()
        } else {
            return Just(usersToReturn)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }
    }
}
