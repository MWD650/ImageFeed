//
//  Profile.swift
//  imageFeed
//
//  Created by Alex on /115/23.
//

import Foundation

struct Profile {
    let username: String
    let first_name: String
    let last_name: String
    let name: String
    let loginName: String
    let bio: String
    
    init(username: String, first_name: String, last_name: String, bio: String) {
        self.username = username
        self.first_name = first_name
        self.last_name = last_name
        self.name = "\(first_name) \(last_name)"
        self.loginName = "@\(username)"
        self.bio = bio
    }
}
