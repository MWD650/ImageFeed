//
//  ProfileViewController.swift
//  imageFeed
//
//  Created by Alex on /124/23.
//

import UIKit
import Kingfisher
import WebKit

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    
    func updateAvatar()
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    var presenter: ProfilePresenterProtocol?
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Profile_image") ?? UIImage()
        imageView.layer.cornerRadius = 61
        return imageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        applyStyleLabel(label, text: "Hello, world!")
        return label
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        applyStyleLabel(label, text: "@ekaterina_nov", textColor: .gray)
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        applyStyleLabel(label, text: "Екатерина Новикова", font: UIFont.systemFont(ofSize: 23, weight: .bold))
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        button.tintColor = .ypRed
        button.accessibilityIdentifier = "logoutButton"
        return button
    }()
    
    private let profileService = ProfileService.shared
//    private var profileImageServiceObserver: NSObjectProtocol?
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        addConstraints()
        updateProfileDetails(with: profileService.profile)
        
        presenter?.viewDidLoad()

        updateAvatar()
    }
    
    // MARK: - Action
    
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(
            title: "Logout",
            message: "Вы уверены что you want to logout?",
            preferredStyle: .alert
        )
        
        let logoutAction = UIAlertAction(
            title: "Да",
            style: .destructive
        ) { [weak self] _ in
            
            OAuth2TokenStorage().token = nil
            // Очищаем все куки из хранилища.
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            // Запрашиваем все данные из локального хранилища.
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                // Массив полученных записей удаляем из хранилища.
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                }
            }
            
            ImagesListService.shared.clearData()
            
            let authVC = SplashViewController()
            let navigationController = UINavigationController(rootViewController: authVC)
            navigationController.modalPresentationStyle = .fullScreen
            self?.present(navigationController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(
            title: "Нет",
            style: .cancel,
            handler: nil
        )
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Private func
    
    private func updateProfileDetails(with profile: Profile?) {
        guard let profile = profile else { return }
        self.nameLabel.text = profile.name
        self.nicknameLabel.text = profile.loginName
        self.descriptionLabel.text = profile.bio
    }
    
    func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        avatarImageView.kf.setImage(with: url)
        
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        avatarImageView.kf.setImage(
            with: url,
            options: [.processor(processor)]
        )
    }
    
    private func setupLayout() {
        [avatarImageView, nameLabel, nicknameLabel, descriptionLabel, logoutButton].forEach { item in
            item.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(item)
        }
    }
    
    // MARK: - Supporting methods
    private func applyStyleLabel(
        _ label: UILabel,
        text: String = "",
        font: UIFont? = UIFont.systemFont(ofSize: 13),
        textColor: UIColor = .ypWhite
    ){
        label.text = text
        label.font = font
        label.textColor = textColor
    }
}

// MARK: - Set Constraints

extension ProfileViewController {
    func addConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nicknameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nicknameLabel.leadingAnchor),
            
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
