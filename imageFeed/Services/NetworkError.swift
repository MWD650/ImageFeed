//
//  NetworkError.swift
//  imageFeed
//
//  Created by Alex on /85/23.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}
