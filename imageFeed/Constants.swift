//
//  Constants.swift
//  imageFeed
//
//  Created by Alex on /264/23.
//

import Foundation

struct API {
    static let accessKey = "reLtp7ONWFJNpMo6N9L-4RiMdW9790VbIrUIP6QC_os"
    static let secretKey = "N3lxndJ9EOZlUjqiJQYdmTNco66VLV06DRQmmGf3ffc"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
