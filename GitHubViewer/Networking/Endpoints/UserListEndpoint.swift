//
//  UserListEndpoint.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import Foundation

struct UserListEndpoint: EndpointType {
    let since: Int
    let perPage: Int = 20
    
    var path: String {
        return "/users"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var queryParameters: [String : String]? {
        return [
            "per_page": String(perPage),
            "since": String(since)
        ]
    }
}
