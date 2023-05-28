//
//  OAuth2Service.swift
//  imageFeed
//
//  Created by Alex on /25/23.
//

import UIKit

final class OAuth2Service {

    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    var lastCode: String?
    func fetchAuthToken(_ code: String, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code

        guard var urlComponents = URLComponents(string: API.urlToFetchAuthToken) else {
            completion(.failure(NSError(domain: "OAuth2Service", code: -1, userInfo: ["description": "Failed to create URL components"])))
            return
        }

        urlComponents.queryItems = [
            .init(name: "client_id", value: API.accessKey),
            .init(name: "client_secret", value: API.secretKey),
            .init(name: "redirect_uri", value: API.redirectURI),
            .init(name: "code", value: code),
            .init(name: "grant_type", value: "authorization_code")
        ]

        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "OAuth2Service", code: -2, userInfo: ["description": "Failed to create URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            self.task = nil
            switch result {
            case .success(let body):
                DispatchQueue.main.async {
                    completion(.success(body))
                }
            case .failure(let error):
                self.lastCode = nil
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
}
