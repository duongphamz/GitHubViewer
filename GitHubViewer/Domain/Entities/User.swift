//
//  User.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import Foundation

struct User: Identifiable, Codable {
    var id: Int?
    var loginUserName: String?
    var avatar: String?
    var landingPage: String?
    var blog: String?
    var location: String?
    var followers: Int?
    var following: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case loginUserName = "login"
        case avatar = "avatar_url"
        case landingPage = "html_url"
        case blog
        case location
        case followers
        case following
    }
}
