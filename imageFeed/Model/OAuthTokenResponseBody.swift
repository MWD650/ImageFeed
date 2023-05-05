//
//  OAuthTokenResponseBody.swift
//  imageFeed
//
//  Created by Alex on /55/23.
//

import UIKit

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
