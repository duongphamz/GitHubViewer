//
//  UserDetailViewModelTests.swift
//  GitHubViewerTests
//
//  Created by Duong Pham on 31/12/24.
//

import XCTest
import Combine
@testable import GitHubViewer

class UserDetailViewModelTests: XCTestCase {

    var viewModel: UserDetailViewModel!
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

    func testFetchUserDetail_Success() {
        // Given
        let expectation = XCTestExpectation(description: "User detail fetch succeeds")
        let mockUser = User(
            id: 1,
            loginUserName: "johndoe",
            avatar: "https://example.com/avatar.png",
            landingPage: "https://example.com",
            blog: "https://blog.example.com",
            location: "Somewhere",
            followers: 1000,
            following: 500
        )
        mockUseCase.userDetailToReturn = mockUser
        viewModel = UserDetailViewModel(userDetailUseCase: mockUseCase, userName: "johndoe")

        // When
        viewModel.fetchUserDetail()

        // Then
        viewModel.$displayModel
            .dropFirst()
            .sink { displayModel in
                XCTAssertEqual(displayModel?.userName, "johndoe")
                XCTAssertEqual(displayModel?.avatar, "https://example.com/avatar.png")
                XCTAssertEqual(displayModel?.location, "Somewhere")
                XCTAssertEqual(displayModel?.followers, "1K+")
                XCTAssertEqual(displayModel?.following, "500+")
                XCTAssertEqual(displayModel?.blog, "https://blog.example.com")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchUserDetail_Failure() {
        // Given
        let expectation = XCTestExpectation(description: "User detail fetch fails")
        mockUseCase.errorToReturn = APIError.serverError(500)
        viewModel = UserDetailViewModel(userDetailUseCase: mockUseCase, userName: "johndoe")

        // When
        viewModel.fetchUserDetail()

        // Then
        viewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                XCTAssertEqual(errorMessage, "Server returned an error with status code: 500")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testMakeDisplayModel_ValidUser() {
        // Given
        let mockUser = User(
            id: 1,
            loginUserName: "johndoe",
            avatar: "https://example.com/avatar.png",
            landingPage: "https://example.com",
            blog: "https://blog.example.com",
            location: "Somewhere",
            followers: 1000,
            following: 500
        )
        viewModel = UserDetailViewModel(userDetailUseCase: mockUseCase, userName: "johndoe")

        // When
        let displayModel = viewModel.makeDisplayModel(from: mockUser)

        // Then
        XCTAssertEqual(displayModel?.userName, "johndoe")
        XCTAssertEqual(displayModel?.avatar, "https://example.com/avatar.png")
        XCTAssertEqual(displayModel?.location, "Somewhere")
        XCTAssertEqual(displayModel?.followers, "1K+")
        XCTAssertEqual(displayModel?.following, "500+")
        XCTAssertEqual(displayModel?.blog, "https://blog.example.com")
    }

    func testMakeDisplayModel_NilUser() {
        // Given
        viewModel = UserDetailViewModel(userDetailUseCase: mockUseCase, userName: "johndoe")

        // When
        let displayModel = viewModel.makeDisplayModel(from: nil)

        // Then
        XCTAssertNil(displayModel)
    }
}
