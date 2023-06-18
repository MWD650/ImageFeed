//
//  ViewController.swift
//  imageFeed
//
//  Created by Alex on /63/23.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func ImagesListCellDidTapLike(_ cell: ImagesListCell)
}

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated()
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol? = ImagesListPresenter()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: String(describing: ImagesListCell.self))
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlack
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        return tableView
    }()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private var photos: [ImagesListService.Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    
    private var imagesListServiceObserver: NSObjectProtocol?
    private let isoDateFormatter = ISO8601DateFormatter()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        addSubviews()
        addViewConstraints()
        createViews()
//        imagesListServiceObserver = NotificationCenter.default
//                    .addObserver(
//                        forName: ImagesListService.DidChangeNotification,
//                        object: nil,
//                        queue: .main
//                    ) { [weak self] _ in
//                        guard let self = self else { return }
//                        self.updateTableViewAnimated()
//                    }
       UIBlockingProgressHUD.show()
    
        imagesListService.fetchPhotosNextPage()
        
        presenter?.view = self
        presenter?.viewDidLoad()
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount == 0 {
            tableView.reloadData()
        } else if oldCount != newCount {
            tableView.performBatchUpdates {
                var indexPaths: [IndexPath] = []
                for i in oldCount..<newCount {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
        
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func ImagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            switch result {
            case .success(let photoResult):
                let updatedPhoto = photoResult.photo.asPhoto()
                self?.photos[indexPath.row] = updatedPhoto
                cell.setLike(like: updatedPhoto.isLiked)
                UIBlockingProgressHUD.dismiss()
            case.failure(let error):
                UIBlockingProgressHUD.dismiss()
                print(photo.id, error.localizedDescription)
            }
        }
    }
}

private extension ImagesListViewController {
    func createViews() {
        view.backgroundColor = .ypBlack
    }
    
    func addSubviews() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    func addViewConstraints() {
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
}
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ImagesListCell.self),
            for: indexPath
        )
        guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        let photo = photos[indexPath.row]
        guard let urlString = photo.thumbImageURL, let url = URL(string: urlString) else {
            print("Invalid URL string: \(photo.thumbImageURL ?? "nil")")
            cell.imageCell.image = UIImage(named: "placeholder_image") 
            return
        }
        
        cell.imageCell.kf.indicatorType = .activity
        let placeholderImage = UIImage(named: "placeholder_image")
        cell.imageCell.kf.setImage(with: url, placeholder: placeholderImage)
        if let date = isoDateFormatter.date(from: photo.createdAt) {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = "date error"
        }
        
        cell.likeButton.setImage(UIImage(named: photo.isLiked ? "like_button_on" : "like_button_off"), for: .normal)
        cell.backgroundColor = .ypBlack
        cell.selectionStyle = .none
        
        cell.setLike(like: photos[indexPath.row].isLiked)
    }
}


extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleImageViewController = SingleImageViewController()
        let photo = photos[indexPath.row]
        if let photoUrlString = photo.largeImageURL, let photoUrl = URL(string: photoUrlString) {
            singleImageViewController.fullImageUrl = photoUrl
            singleImageViewController.modalPresentationStyle = .fullScreen
            present(singleImageViewController, animated: true)
        } else {
            print("Invalid URL string.")
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let image = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
