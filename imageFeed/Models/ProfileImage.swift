//
//  ProfileImage.swift
//  imageFeed
//
//  Created by Alex on /115/23.
//

import Foundation

struct ProfileImage: Codable {
    let profile_image: ImageSizes
    
    private enum CodingKeys: String, CodingKey {
        case profile_image = "profile_image"
    }
}

struct ImageSizes: Codable {
    let small: String
    let medium: String
    let large: String

    private enum CodingKeys: String, CodingKey {
        case small = "small"
        case medium = "medium"
        case large = "large"
    }
}

