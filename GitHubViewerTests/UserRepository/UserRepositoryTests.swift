//
//  UserRepositoryTests.swift
//  GitHubViewerTests
//
//  Created by Duong Pham on 31/12/24.
//

import XCTest
import Combine
@testable import GitHubViewer

class UserRepositoryTests: XCTestCase {
    var sut: UserRepositoryImpl!
    var mockRemoteDataSource: MockUserListRemoteDataSource!
    var mockLocalDataSource: MockUserListLocalDataSource!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRemoteDataSource = MockUserListRemoteDataSource()
        mockLocalDataSource = MockUserListLocalDataSource()
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockRemoteDataSource = nil
        mockLocalDataSource = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Test CacheFirst Strategy
    func testFetchUsersWithCacheFirst_UsesCacheWhenAvailable() {
        // Given
        sut = UserRepositoryImpl(
            remoteDataSource: mockRemoteDataSource,
            localDataSource: mockLocalDataSource,
            cacheType: .cacheFirst
        )
        let cachedUsers = [
            User(id: 1, loginUserName: "cachedUser1", avatar: nil, landingPage: nil, blog: nil, location: nil, followers: nil, following: nil)
        ]
        mockLocalDataSource.usersToReturn = cachedUsers

        let expectation = self.expectation(description: "Should return cached users")
        
        // When
        sut.fetchUsers(since: 0)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success, got failure instead")
                }
            }, receiveValue: { users in
                // Then
                XCTAssertEqual(users.count, cachedUsers.count)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    func testFetchUsersWithCacheFirst_FallsBackToRemoteIfCacheNotAvailable() {
        // Given
        sut = UserRepositoryImpl(
            remoteDataSource: mockRemoteDataSource,
            localDataSource: mockLocalDataSource,
            cacheType: .cacheFirst
        )
        mockLocalDataSource.usersToReturn = nil
        let remoteUsers = [
            User(id: 1, loginUserName: "remoteUser1", avatar: nil, landingPage: nil, blog: nil, location: nil, followers: nil, following: nil)
        ]
        mockRemoteDataSource.usersToReturn = remoteUsers

        let expectation = self.expectation(description: "Should return remote users")
        
        // When
        sut.fetchUsers(since: 0)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success, got failure instead")
                }
            }, receiveValue: { users in
                // Then
                XCTAssertEqual(users.count, remoteUsers.count)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    // MARK: - Test RemoteFirst Strategy
    func testFetchUsersWithRemoteFirst_AlwaysFetchesFromRemote() {
        // Given
        sut = UserRepositoryImpl(
            remoteDataSource: mockRemoteDataSource,
            localDataSource: mockLocalDataSource,
            cacheType: .remoteFirst
        )
        let remoteUsers = [
            User(id: 1, loginUserName: "remoteUser1", avatar: nil, landingPage: nil, blog: nil, location: nil, followers: nil, following: nil)
        ]
        mockRemoteDataSource.usersToReturn = remoteUsers

        let expectation = self.expectation(description: "Should return remote users")
        
        // When
        sut.fetchUsers(since: 0)
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success, got failure instead")
                }
            }, receiveValue: { users in
                // Then
                XCTAssertEqual(users.count, remoteUsers.count)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }

    // MARK: - Test FetchUserDetail
    func testFetchUserDetail_ReturnsUserDetailFromRemote() {
        // Given
        sut = UserRepositoryImpl(
            remoteDataSource: mockRemoteDataSource,
            localDataSource: mockLocalDataSource
        )
        let expectedUser = User(id: 1, loginUserName: "testUser", avatar: nil, landingPage: nil, blog: nil, location: nil, followers: nil, following: nil)
        mockRemoteDataSource.userDetailToReturn = expectedUser

        let expectation = self.expectation(description: "Should return user detail")
        
        // When
        sut.fetchUserDetail(userName: "testUser")
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success, got failure instead")
                }
            }, receiveValue: { user in
                // Then
                XCTAssertEqual(user?.id, expectedUser.id)
                expectation.fulfill()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 2)
    }
}

