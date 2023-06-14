////
////  OAuth2TokenStorage.swift
////  imageFeed
////
////  Created by Alex on /25/23.
////
//
//
import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let storage = KeychainWrapper.standard
    private let keyStorage = "API.bearerKey"

    var token: String? {
        get {
            return storage.string(forKey: keyStorage)
        }
        set {
            if let data = newValue {
                storage.set(data, forKey: keyStorage)
            } else {
                storage.removeObject(forKey: keyStorage)
            }
        }

    }
}
