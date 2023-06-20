//
//  Constants.swift
//  imageFeed
//
//  Created by Alex on /264/23.
//

import Foundation

enum API {
    static let accessKey: String = "reLtp7ONWFJNpMo6N9L-4RiMdW9790VbIrUIP6QC_os"
    static let secretKey: String = "N3lxndJ9EOZlUjqiJQYdmTNco66VLV06DRQmmGf3ffc"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let urlToFetchAuthToken = "https://unsplash.com/oauth/token"
    static let bearerKey = "bearer"
}

struct AuthConfiguration {
   
    
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let authURLString: String
    let defaultBaseURL: URL
    
    
    
//    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
//        self.accessKey = accessKey
//        self.secretKey = secretKey
//        self.redirectURI = redirectURI
//        self.accessScope = accessScope
//        self.defaultBaseURL = defaultBaseURL
//        self.authURLString = authURLString
//    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: API.accessKey,
                                 secretKey: API.secretKey,
                                 redirectURI: API.redirectURI,
                                 accessScope: API.accessScope,
                                 authURLString: API.unsplashAuthorizeURLString,
                                 defaultBaseURL: API.defaultBaseURL
       )
    }
    
}

