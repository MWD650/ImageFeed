//
//  ImagesListService.swift
//  imageFeed
//
//  Created by Alex on /295/23.
//

import UIKit

class ImagesListService {
    
    private (set) var photos: [Photo] = [] // Для хранения последовательности всех загруженных из сети фотографий
    static let shared = ImagesListService()
   // private var lastLoadedPage: Int = 1
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private var task: URLSessionTask? // URLSessionTask текущего сетевого запроса
    private var lastLoadedPage: Int?
    private let oAuthTokenStorage = OAuth2TokenStorage()
    
    func fetchPhotosNextPage() { // Функция для получения очередной страницы
        
        assert(Thread.isMainThread)
        task?.cancel()
        
        let nextPage: Int
        if let lastPage = lastLoadedPage {
            nextPage = lastPage + 1
        } else {
            nextPage = 1
        }
        
        var request = URLRequest.makeHTTPRequest(path: "/photos/?page" + "\(nextPage)" + "&&per_page=10", httpMethod: "get")
        
        if let token = oAuthTokenStorage.token {
            request!.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let session = URLSession.shared
        
        // TODO: Определяем идет ли сейчас загрузка фото: Добавить свойство task: URLSessionTask? (сохраняем в нём результат urlSession.objectTask), и если task != nil, то сетевой запрос в прогрессе.
        let task = session.objectTask(for: request!, completion: { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photoResult):
                self.fetchPhoto(photoResult)
                NotificationCenter.default.post(
                    name: ImagesListService.DidChangeNotification,
                    object: self,
                    userInfo: ["photos": self.photos])
            case .failure(_):
                break
            }
        })
        self.task = task
        task.resume()
    }
    
    
    
    func clearData() { //очисткf загруженных фото и обнуление счетчика фото
        photos.removeAll()
        lastLoadedPage = nil
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<PhotoLikeResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let token = OAuth2TokenStorage().token else { return }
        
        guard let request = isLike ? deleteLikeRequest(token, photoId: photoId) : postLikeRequest(token, photoId: photoId) else {return }
        
        let session = URLSession.shared
        let task = session.objectTask(for: request, completion: { (result: Result<PhotoLikeResult, Error>) in
            completion(result)
        })
        self.task = task
        task.resume()
    }
    
    private func postLikeRequest(_ token: String, photoId: String) -> URLRequest? {
        var postRequest = URLRequest.makeHTTPRequest(
            path: "/photos/" + "\(photoId)" + "/like",
            httpMethod: "POST")
        postRequest?.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return postRequest
    }
    
    private func deleteLikeRequest(_ token: String, photoId: String) -> URLRequest? {
        var deleteRequest = URLRequest.makeHTTPRequest(
            path: "/photos/" + "\(photoId)" + "/like",
            httpMethod: "DELETE")
        deleteRequest?.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return deleteRequest
    }
    
    struct PhotoLikeResult: Codable {
        let photo: PhotoResult
    }
    
    func fetchPhoto(_ photoResult: [PhotoResult]) {
        for result in photoResult {
            let photo = Photo(
                id: result.id,
                size: CGSize(width: result.width, height: result.height),
                createdAt: result.createdAt,
                welcomeDescription: result.welcomeDescription,
                thumbImageURL: result.urls.thumb,
                largeImageURL: result.urls.full,
                isLiked: result.isLiked)
            photos.append(photo)
        }
    }
    struct Photo {
        let id: String
        let size: CGSize
        let createdAt: String
        let welcomeDescription: String?
        let thumbImageURL: String?
        let largeImageURL: String?
        let isLiked: Bool
    }
    struct PhotoResult: Codable {
        let id: String
        let width: Int
        let height: Int
        let createdAt: String
        let welcomeDescription: String?
        let isLiked: Bool
        let urls: UrlsResult
        
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case width = "width"
            case height = "height"
            case createdAt = "created_at"
            case welcomeDescription = "description"
            case isLiked = "liked_by_user"
            case urls = "urls"
        }
        
        func asPhoto() -> Photo {
            Photo(
                id: id,
                size: CGSize(width: width, height: height),
                createdAt: createdAt,
                welcomeDescription: welcomeDescription,
                thumbImageURL: urls.thumb,
                largeImageURL: urls.full,
                isLiked: isLiked)
        }
    }
    
    struct UrlsResult: Codable {
        let full: String
        let thumb: String
    }
}
