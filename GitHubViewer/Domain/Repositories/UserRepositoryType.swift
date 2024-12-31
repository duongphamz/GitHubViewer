//
//  UserRepositoryType.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import Combine

protocol UserRepositoryType {
    func fetchUsers(since: Int) -> AnyPublisher<[User], APIError>
    func fetchUserDetail(userName: String) -> AnyPublisher<User?, APIError>
}
