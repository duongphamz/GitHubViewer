//
//  UserDetailEndpoint.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import Foundation

struct UserDetailEndpoint: EndpointType {
    let userName: String

    var path: String {
        return "/users/\(userName)"
    }
    
    var method: HTTPMethod {
        return .get
    }
}
