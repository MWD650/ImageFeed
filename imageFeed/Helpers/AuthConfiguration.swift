//
//  Constants.swift
//  imageFeed
//
//  Created by Alex on /264/23.
//

import Foundation

let AccessKey: String = "reLtp7ONWFJNpMo6N9L-4RiMdW9790VbIrUIP6QC_os"
let SecretKey: String = "N3lxndJ9EOZlUjqiJQYdmTNco66VLV06DRQmmGf3ffc"
let RedirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"

let DefaultBaseURL = URL(string: "https://api.unsplash.com")!
let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

let UrlToFetchAuthToken = "https://unsplash.com/oauth/token"
let BearerKey = "bearer"

struct AuthConfiguration {
   
    
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
       return AuthConfiguration(accessKey: AccessKey,
                                secretKey: SecretKey,
                                redirectURI: RedirectURI,
                                accessScope: AccessScope,
                                authURLString: UnsplashAuthorizeURLString,
                                defaultBaseURL: DefaultBaseURL
       )
    }
    
}

