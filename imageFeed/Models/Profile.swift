//
//  Profile.swift
//  imageFeed
//
//  Created by Alex on /115/23.
//

import Foundation

struct Profile {
    let username: String
    let firstName: String
    let lastName: String?
    let name: String
    let loginName: String
    let bio: String
    
    init(username: String, firstName: String, lastName: String?, bio: String) {
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        //self.name = "\(firstName) \(lastName ?? "")"
        if let lastName = lastName, !lastName.isEmpty {
               self.name = "\(firstName) \(lastName)"
           } else {
               self.name = firstName
           }
        self.loginName = "@\(username)"
        self.bio = bio
    }
}
