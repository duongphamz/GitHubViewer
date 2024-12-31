//
//  UserListLocalDataSource.swift
//  GitHubViewer
//
//  Created by Duong Pham on 31/12/24.
//

import Foundation

protocol UserListLocalDataSourceProtocol {
    func saveUsers(_ users: [User])
    func fetchUsers() -> [User]?
}

class UserListLocalDataSource: UserListLocalDataSourceProtocol {
    private let cacheManager: CacheManagerProtocol
    private let cacheKey = "UserListCache"

    init(cacheManager: CacheManagerProtocol = CacheManager()) {
        self.cacheManager = cacheManager
    }

    func saveUsers(_ users: [User]) {
        cacheManager.save(users, forKey: cacheKey)
    }

    func fetchUsers() -> [User]? {
        return cacheManager.load(forKey: cacheKey, as: [User].self)
    }
}
