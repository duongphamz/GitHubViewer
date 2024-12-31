//
//  UserListViewModelTests.swift
//  GitHubViewerTests
//
//  Created by Duong Pham on 31/12/24.
//

import XCTest
import Combine
@testable import GitHubViewer

class UserListViewModelTests: XCTestCase {
    
    var viewModel: UserListViewModel!
    var mockUseCase: MockUserDetailUseCase!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockUseCase = MockUserDetailUseCase()
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockUseCase = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchUsers_Success() {
        // Given
        let mockUseCase = MockUserListUseCase()
        mockUseCase.usersToReturn = [
            User(
                id: 1,
                loginUserName: "johndoe",
                avatar: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
                landingPage: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
                blog: nil,
                location: nil,
                followers: nil,
                following: nil
            ),
            User(
                id: 2,
                loginUserName: "petersmith",
                avatar: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
                landingPage: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
                blog: nil,
                location: nil,
                followers: nil,
                following: nil
            )
        ]
        viewModel = UserListViewModel(userListUseCase: mockUseCase)
        
        // Create an expectation to wait for the asynchronous operation to finish
        let expectation = self.expectation(description: "Fetch users")
        
        // Observe changes to the users array to trigger the expectation when it is updated
        viewModel.$users.sink { users in
            if users.count == 2 { // Once we have 2 users in the array, fulfill the expectation
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        // When
        viewModel.fetchUserList()
        
        // Wait for the expectation to be fulfilled or time out
        wait(for: [expectation], timeout: 2) // Adjust timeout as needed
        
        // Then
        XCTAssertFalse(viewModel.isLoading) // Ensure loading is finished
        XCTAssertFalse(viewModel.isError)   // Ensure there's no error
        XCTAssertNil(viewModel.errorMessage) // Ensure no error message
        XCTAssertEqual(viewModel.users.count, 2) // Verify we have 2 users
        XCTAssertEqual(viewModel.users.first?.loginUserName, "johndoe") // Verify the first user
    }

    
    func testFetchUsers_Failure() {
        // Given
        let mockUseCase = MockUserListUseCase()
        mockUseCase.shouldReturnError = true
        viewModel = UserListViewModel(userListUseCase: mockUseCase)
        
        // Create an expectation to wait for the error state to be set
        let expectation = self.expectation(description: "Error state set")
        
        // Observe changes to the error state (or any other state related to the error)
        viewModel.$isError.sink { isError in
            if isError { // Once isError is set to true, fulfill the expectation
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        // When
        viewModel.fetchUserList()
        
        // Wait for the expectation to be fulfilled or time out
        wait(for: [expectation], timeout: 2.0) // Adjust timeout as needed
        
        // Then
        XCTAssertTrue(viewModel.isError) // Ensure isError is true
        XCTAssertNotNil(viewModel.errorMessage) // Ensure errorMessage is not nil
        XCTAssertEqual(viewModel.errorMessage, APIError.unknown.localizedDescription) // Ensure correct error message
    }
    
    func testFetchUsersAppend() {
        // Given
        let mockUseCase = MockUserListUseCase()
        mockUseCase.usersToReturn = [
            User(
                id: 1,
                loginUserName: "johndoe",
                avatar: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
                landingPage: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
                blog: nil,
                location: nil,
                followers: nil,
                following: nil
            ),
            User(
                id: 2,
                loginUserName: "petersmith",
                avatar: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
                landingPage: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
                blog: nil,
                location: nil,
                followers: nil,
                following: nil
            )
        ]
        viewModel = UserListViewModel(userListUseCase: mockUseCase)
        
        // Create an expectation to wait for the first fetch to complete
        let expectationFirstFetch = self.expectation(description: "First fetch completed")
        
        // Observe users array to be updated after the first fetch
        viewModel.$users.sink { users in
            if users.count == 2 { // Once two users are fetched, fulfill the expectation
                expectationFirstFetch.fulfill()
            }
        }
        .store(in: &cancellables)
        
        // When: Perform the first fetch
        viewModel.fetchUserList()
        
        // Wait for the first fetch to complete
        wait(for: [expectationFirstFetch], timeout: 2.0)
        
        // Now update the mock data for the second fetch
        mockUseCase.usersToReturn = [
            User(
                id: 3,
                loginUserName: "newuser",
                avatar: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
                landingPage: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
                blog: nil,
                location: nil,
                followers: nil,
                following: nil
            )
        ]
        
        // Create an expectation for the second fetch
        let expectationSecondFetch = self.expectation(description: "Second fetch completed")
        
        // Observe users array to be updated after the second fetch
        viewModel.$users.sink { users in
            if users.count == 3 { // Once three users are fetched, fulfill the expectation
                expectationSecondFetch.fulfill()
            }
        }
        .store(in: &cancellables)
        
        // When: Perform the second fetch
        viewModel.fetchUserList()
        
        // Wait for the second fetch to complete
        wait(for: [expectationSecondFetch], timeout: 2.0)
        
        // Then: Ensure that the second fetch appended the new user to the list
        XCTAssertEqual(viewModel.users.count, 3) // Total users should now be 3
        XCTAssertEqual(viewModel.users.last?.loginUserName, "newuser") // The new user's login name should be "newuser"
    }

    
    func testIsLoadingState() {
        // Given
        let mockUseCase = MockUserListUseCase()
        mockUseCase.usersToReturn = [User(
            id: 1,
            loginUserName: "johndoe",
            avatar: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
            landingPage: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
            blog: nil,
            location: nil,
            followers: nil,
            following: nil
        )]
        viewModel = UserListViewModel(userListUseCase: mockUseCase)
        
        // When
        viewModel.fetchUserList()
        
        // Then
        XCTAssertTrue(viewModel.isLoading)
    }
    
    func testLoadMoreTrigger_Success() {
        // Given
        let mockUseCase = MockUserListUseCase()
        
        // Initial set of users to return
        mockUseCase.usersToReturn = (1...20).map {
            User(
                id: $0,
                loginUserName: "newuser\($0!)",
                avatar: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
                landingPage: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
                blog: nil,
                location: nil,
                followers: nil,
                following: nil
            )
        }
        
        // Create the view model with the mock use case
        viewModel = UserListViewModel(userListUseCase: mockUseCase)
        
        // Create an expectation to wait for the first fetch to complete
        let expectationFirstFetch = self.expectation(description: "First fetch completed")
        
        // Observe users array to be updated after the first fetch
        viewModel.$users.sink { users in
            if users.count == 20 { // After the first fetch, we expect 20 users
                expectationFirstFetch.fulfill()
            }
        }
        .store(in: &cancellables)
        
        // When: Perform the first fetch
        viewModel.fetchUserList()
        
        // Wait for the first fetch to complete
        wait(for: [expectationFirstFetch], timeout: 2.0)
        
        XCTAssertEqual(viewModel.users.count, 20) // There should be 20 users now
        XCTAssertEqual(viewModel.users.last?.loginUserName, "newuser20") // The last user's login name should be "newuser20"
        
        // Now update the mock data for the second fetch (load more users)
        mockUseCase.usersToReturn = (21...40).map {
            User(
                id: $0,
                loginUserName: "newuser\($0!)",
                avatar: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
                landingPage: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
                blog: nil,
                location: nil,
                followers: nil,
                following: nil
            )
        }
        
        // Create an expectation for the load more fetch
        let expectationLoadMore = self.expectation(description: "Load more fetch completed")
        
        // Observe users array to be updated after the load more fetch
        viewModel.$users.sink { users in
            if users.count == 40 {
                expectationLoadMore.fulfill()
            }
        }
        .store(in: &cancellables)
        
        // When: Trigger the load more
        viewModel.viewInput.triggerLoadMoreIfNeed.send(20)
        
        // Wait for the load more to complete
        wait(for: [expectationLoadMore], timeout: 2.0)
        
        // Then: Ensure that the load more functionality correctly added more users
        XCTAssertEqual(viewModel.users.count, 40) // There should be 40 users now
        XCTAssertEqual(viewModel.users.last?.loginUserName, "newuser40") // The last user's login name should be "newuser40"
    }
}

