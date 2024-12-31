//
//  APIError.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import Foundation

// MARK: - APIError
enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
    case serverError(Int)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server returned an error with status code: \(statusCode)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
