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
        
        guard var urlComponents = URLComponents(string: API.urlToFetchAuthToken) else { return }
        urlComponents.queryItems = [
            .init(name: "client_id", value: API.accessKey),
            .init(name: "client_secret", value: API.secretKey),
            .init(name: "redirect_uri", value: API.redirectURI),
            .init(name: "code", value: code),
            .init(name: "grant_type", value: "authorization_code")
            
        ]
        
        guard let url = urlComponents.url else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
               // guard let authToken = body.accessToken else { return }
               // OAuth2TokenStorage().token = authToken
                self.task = nil
                completion(.success(body))
            case .failure(let error):
                self.lastCode = nil
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
        
    }
}

