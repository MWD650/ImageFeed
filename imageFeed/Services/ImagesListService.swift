//
//  ImagesListService.swift
//  imageFeed
//
//  Created by Alex on /295/23.
//

import UIKit

//final class ImagesListService {
//    private (set) var photos: [Photo] = []
//
//    private var lastLoadedPage: Int?
    
    // ...
    
//    func fetchPhotosNextPage() {
//
//        let nextPage = lastLoadedPage == nil
//        ? 1
//        : lastLoadedPage!.number + 1
//
//        // ...
 //   }
    class ImagesListService {
        
        
        private (set) var photos: [Photo] = [] // Для хранения последовательности всех загруженных из сети фотографий
        static let shared = ImagesListService()
        static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")  // Нотификация, когда фотографии обновлены
        private var task: URLSessionTask? // URLSessionTask текущего сетевого запроса
        
        // Последняя загруженная страница
        private var lastLoadedPage: Int?
        private let oAuthTokenStorage = OAuth2TokenStorage()
        
        // Загружает следующую страницу фотографий
        func fetchPhotosNextPage() { // Функция для получения очередной страницы
                assert(Thread.isMainThread)
                task?.cancel()
                
                let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1 // Какую страницу загружать
                
                var request = URLRequest.makeHTTPRequest(path: "/photos/?page" + "\(nextPage)" + "&&per_page=10", httpMethod: "get")
                
                if let token = oAuthTokenStorage.token {
                    request!.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                
                let session = URLSession.shared
                
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
                // TODO: Определяем идет ли сейчас загрузка фото: Добавить свойство task: URLSessionTask? (сохраняем в нём результат urlSession.objectTask), и если task != nil, то сетевой запрос в прогрессе.
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
        }

        struct UrlsResult: Codable {
            let full: String
            let thumb: String
        }
    }





