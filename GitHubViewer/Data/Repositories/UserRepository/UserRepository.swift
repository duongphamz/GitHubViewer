//
//  UserRepository.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import Foundation
import Combine

// MARK: - CacheType
// Enum defining the cache strategy: prioritize cache or remote data
enum CacheStrategyType {
    case cacheFirst    // Prefer cache first, then remote
    case remoteFirst   // Prefer remote first, then cache
}

// MARK: - UserRepositoryImpl
// Implementation of UserRepositoryType to manage fetching user data from remote and local sources
class UserRepositoryImpl: UserRepositoryType {
    
    // MARK: - Properties
    private let remoteDataSource: UserListRemoteDataSourceProtocol
    private let localDataSource: UserListLocalDataSourceProtocol
    private let cacheType: CacheStrategyType
    
    // MARK: - Initializer
    init(
        remoteDataSource: UserListRemoteDataSourceProtocol = UserListRemoteDataSource(),
        localDataSource: UserListLocalDataSourceProtocol = UserListLocalDataSource(),
        cacheType: CacheStrategyType = .cacheFirst
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.cacheType = cacheType
    }

    // MARK: - Public Methods
    
    // Fetches users based on cache strategy
    func fetchUsers(since: Int) -> AnyPublisher<[User], APIError> {
        switch cacheType {
        case .cacheFirst:
            return fetchWithCacheFirst(since: since)
        case .remoteFirst:
            return fetchWithRemoteFirst(since: since)
        }
    }
    
    // Fetches user details from remote data source
    func fetchUserDetail(userName: String) -> AnyPublisher<User?, APIError> {
        return remoteDataSource.fetchUserDetail(userName: userName)
    }

    // MARK: - Private Methods
    
    // Fetches users with cache-first strategy
    private func fetchWithCacheFirst(since: Int) -> AnyPublisher<[User], APIError> {
        if since == 0, let cachedUsers = localDataSource.fetchUsers() {
            return Just(cachedUsers)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }

        return remoteDataSource.fetchUsers(since: since)
            .handleEvents(receiveOutput: { [weak self] users in
                guard since == 0 else { return }
                self?.localDataSource.saveUsers(users)
            })
            .eraseToAnyPublisher()
    }

    // Fetches users with remote-first strategy
    private func fetchWithRemoteFirst(since: Int) -> AnyPublisher<[User], APIError> {
        remoteDataSource.fetchUsers(since: since)
            .handleEvents(receiveOutput: { [weak self] users in
                guard since == 0 else { return }
                self?.localDataSource.saveUsers(users)
            })
            .eraseToAnyPublisher()
    }
}

