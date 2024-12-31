//
//  UserDetailUseCase.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import Combine

protocol UserDetailUseCaseType {
    func fetchUserDetail(userName: String) -> AnyPublisher<User?, APIError>
}

class UserDetailUseCase: UserDetailUseCaseType {
    var repository: UserRepositoryType

    init(repository: UserRepositoryType = UserRepositoryImpl()) {
        self.repository = repository
    }

    func fetchUserDetail(userName: String) -> AnyPublisher<User?, APIError> {
        repository.fetchUserDetail(userName: userName)
    }
}


