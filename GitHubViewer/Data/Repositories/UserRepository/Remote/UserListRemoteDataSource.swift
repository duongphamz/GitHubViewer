//
//  UserListRemoteDataSource.swift
//  GitHubViewer
//
//  Created by Duong Pham on 31/12/24.
//

import Foundation
import Combine

protocol UserListRemoteDataSourceProtocol {
    func fetchUsers(since: Int) -> AnyPublisher<[User], APIError>
    func fetchUserDetail(userName: String) -> AnyPublisher<User?, APIError>
}

class UserListRemoteDataSource: UserListRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func fetchUsers(since: Int) -> AnyPublisher<[User], APIError> {
        let endpoint = UserListEndpoint(since: since)
        return networkService.request(endpoint: endpoint, responseType: [User].self)
    }
    
    func fetchUserDetail(userName: String) -> AnyPublisher<User?, APIError> {
        let endpoint = UserDetailEndpoint(userName: userName)
        return networkService.request(endpoint: endpoint, responseType: User?.self)
    }
}
