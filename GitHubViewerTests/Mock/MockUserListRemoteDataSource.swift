//
//  MockUserListRemoteDataSource.swift
//  GitHubViewerTests
//
//  Created by Duong Pham on 31/12/24.
//

import Foundation
import Combine
@testable import GitHubViewer

class MockUserListRemoteDataSource: UserListRemoteDataSourceProtocol {
    var usersToReturn: [User]?
    var userDetailToReturn: User?
    var errorToThrow: APIError?

    func fetchUsers(since: Int) -> AnyPublisher<[User], APIError> {
        if let error = errorToThrow {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(usersToReturn ?? [])
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }

    func fetchUserDetail(userName: String) -> AnyPublisher<User?, APIError> {
        if let error = errorToThrow {
            return Fail(error: error).eraseToAnyPublisher()
        }
        return Just(userDetailToReturn)
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }
}
