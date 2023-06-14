//
//  AuthViewControllerDelegate.swift
//  imageFeed
//
//  Created by Alex on /55/23.
//
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}
