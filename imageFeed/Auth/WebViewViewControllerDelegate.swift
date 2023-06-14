//
//  WebViewViewControllerDelegate.swift
//  imageFeed
//
//  Created by Alex on /294/23.
//

import UIKit


protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}


