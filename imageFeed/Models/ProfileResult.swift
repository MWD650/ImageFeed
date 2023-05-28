//
//  ProfileResult.swift
//  imageFeed
//
//  Created by Alex on /115/23.
//
import Foundation

struct ProfileResult: Codable {
    let username: String
    let first_name: String
    let last_name: String
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case username = "username"
        case first_name = "first_name"
        case last_name = "last_name"
        case bio = "bio"
    }
}
