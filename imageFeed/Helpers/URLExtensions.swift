////
////  URLExtensions.swift
////  imageFeed
////
////  Created by Alex on /85/23.
////
//
import Foundation

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL? = DefaultBaseURL) -> URLRequest? {
                
                guard let baseURL = baseURL else {
                    print("baseURL is nil")
                    return nil
                }
                
                guard let url = URL(string: path, relativeTo: baseURL) else {
                    print("Invalid URL string: \(path)")
                    return nil
                }
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod
            return request
        }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {

            let fulfillCompletion: (Result<T, Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }

            let task = dataTask(with: request, completionHandler: {data, responce, error in
                if let data = data,
                   let responce = responce,
                   let statusCode = (responce as? HTTPURLResponse)?.statusCode {
                    if 200..<300 ~= statusCode {
                        do {
                            let decoder = JSONDecoder()
                            let json = try decoder.decode(T.self, from: data)
                            fulfillCompletion(.success(json))
                        } catch {
                            fulfillCompletion(.failure(error))
                        }
                    } else {
                        fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                    }
                } else if let error = error {
                    fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
                }
            })
            return task
        }
}
