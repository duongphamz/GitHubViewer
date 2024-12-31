//
//  MockUserDetailUseCase.swift
//  GitHubViewerTests
//
//  Created by Duong Pham on 31/12/24.
//

import Foundation
import Combine
@testable import GitHubViewer

class MockUserDetailUseCase: UserDetailUseCaseType {
    var userDetailToReturn: User?
    var errorToReturn: APIError?

    func fetchUserDetail(userName: String) -> AnyPublisher<User?, APIError> {
        if let error = errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        } else {
            return Just(userDetailToReturn).setFailureType(to: APIError.self).eraseToAnyPublisher()
        }
    }
}
