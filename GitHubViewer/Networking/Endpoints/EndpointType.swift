//
//  EndpointType.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import Foundation

protocol EndpointType {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
    var body: Data? { get }
}

extension EndpointType {
    var baseURL: URL {
        // Default Base URL
        return URL(string: "https://api.github.com")!
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    var queryParameters: [String: String]? {
        return nil
    }

    var body: Data? {
        return nil
    }

    func urlRequest() -> URLRequest {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        
        // Add query parameters if present
        if let queryParameters = queryParameters {
            urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }
}

