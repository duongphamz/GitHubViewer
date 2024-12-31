//
//  MockUserListLocalDataSource.swift
//  GitHubViewerTests
//
//  Created by Duong Pham on 31/12/24.
//

import Foundation
@testable import GitHubViewer

class MockUserListLocalDataSource: UserListLocalDataSourceProtocol {
    var usersToReturn: [User]?
    
    func fetchUsers() -> [User]? {
        return usersToReturn
    }
    
    func saveUsers(_ users: [User]) {
        // Do nothing for this mock
    }
}
