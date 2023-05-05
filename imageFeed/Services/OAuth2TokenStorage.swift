//
//  OAuth2TokenStorage.swift
//  imageFeed
//
//  Created by Alex on /25/23.
//


import UIKit

final class OAuth2TokenStorage {
    private let storage = UserDefaults.standard
    private let keyStorage = "bearer"
    
    var token: String? {
        get {
            storage.string(forKey: keyStorage)
        }
        
        set {
            guard let data = newValue else { return }
            storage.set(data, forKey: keyStorage)
        }
    }
}
