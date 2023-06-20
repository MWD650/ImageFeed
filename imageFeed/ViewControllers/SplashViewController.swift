//  SplashViewController.swift
//  imageFeed
//
//  Created by Alex on /35/23.
//
import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    //MARK: - Properties
    private var username: String?
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()

    private lazy var logoImage: UIImageView = {
        let element = UIImageView()
        element.image = UIImage(named: "LaunchScreen")
        return element
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplashView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if oauth2TokenStorage.token != nil {
            guard let token = oauth2TokenStorage.token else { return }
            fetchProfile(token: token)
            fetchImageProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }
    
    //MARK: - Methods
    private func presentAuthViewController() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        let navigationAuthViewController = UINavigationController(rootViewController: authViewController)
        navigationAuthViewController.modalPresentationStyle = .fullScreen
        present(navigationAuthViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { return }
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func fetchProfile(token: String) {
        self.profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.username = profile.username
                self.fetchImageProfile(token: token)
                self.switchToTabBarController()
            case .failure(let error):
                self.showAlert(with: error)
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    private func fetchImageProfile(token: String) {
        if let username = username {
            profileImageService.fetchProfileImageURL(token: token, username: username) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case.success(let avatarURL):
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
                case.failure(let error):
                    self.showAlert(with: error)
                }
            }
        }
    }
    
    private func showAlert(with error: Error) {
        let alert = UIAlertController(title: "Что-то пошло не так(", message: "Ошибка: \(error.localizedDescription)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
    private func setupSplashView() {
        view.backgroundColor = .ypBlack
        view.addSubview(logoImage)
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

//MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchAuthToken(code) { [weak self] result in
                guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.oauth2TokenStorage.token = response.accessToken
                if let token = self.oauth2TokenStorage.token {
                    self.fetchProfile(token: token)
                }
            case .failure(let error):
                self.showAlert(with: error)
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
}
