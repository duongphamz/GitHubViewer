//
//  UserListUseCase.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import Combine

protocol UserListUseCaseType {
    func fetchUsers(since: Int) -> AnyPublisher<[User], APIError>
}

class UserListUseCase: UserListUseCaseType {
    var repository: UserRepositoryType

    init(repository: UserRepositoryType = UserRepositoryImpl()) {
        self.repository = repository
    }

    func fetchUsers(since: Int) -> AnyPublisher<[User], APIError> {
        repository.fetchUsers(since: since)
    }
}


