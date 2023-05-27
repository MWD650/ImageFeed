//
//  ProfileImageService.swift
//  imageFeed
//
//  Created by Alex on /115/23.
//
import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    func fetchProfileImageURL(token: String, username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        if task != nil {
            return
        }
        
        var request = URLRequest.makeHTTPRequest(path: "/users/\(username)", httpMethod: "GET")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileImage, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let userResult):
                let smallImage = userResult.profile_image.small
                self.avatarURL = smallImage
                completion(.success(self.avatarURL!))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
        
        
    }
}
