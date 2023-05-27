//
//  SplashViewController.swift
//  imageFeed
//
//  Created by Alex on /35/23.
//
import UIKit
import ProgressHUD


final class SplashViewController: UIViewController {
    
   // private var isFirst = true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSplashView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Токен перед загрузкой:",OAuth2TokenStorage().token)
        print("Токен перед загрузкой значение которое пров:",oauth2TokenStorage.token)
        if OAuth2TokenStorage().token != nil {
            guard let token = oauth2TokenStorage.token else { return }
            fetchProfile(token: token)
            fetchImageProfile(token: token)
            
        } else {
            presentAuthViewController()
        }
        
    }
    
    
    private func presentAuthViewController() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        
        let navigationAuthViewController = UINavigationController(rootViewController: authViewController)
        navigationAuthViewController.modalPresentationStyle = .fullScreen
        present(navigationAuthViewController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        let tabBarController = TabBarController()
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration ") }
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
    }
    
    private func getViewController(withIdentifier id: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: id)
        return viewController
    }
    
    private func fetchProfile(token: String) {
        self.profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.username = profile.username
                UIBlockingProgressHUD.dismiss()
                self.fetchImageProfile(token: token)
                self.switchToTabBarController()
            case .failure(let error):
                self.showAlert(with: error)
                UIBlockingProgressHUD.dismiss()
            }
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
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
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

//extension SplashViewController: AuthViewControllerDelegate {
//    func authViewController(
//        _ vc: AuthViewController,
//        didAuthenticateWithCode code: String
//    ) { UIBlockingProgressHUD.show()
//        dismiss(animated: true) { [weak self] in
//            guard let self = self else { return }
//            self.oauth2Service.fetchAuthToken(code: code) { [weak self] result in
//
//                guard let self = self else { return }
//                switch result {
//                case.success(let response):
//
//                    self.oauth2TokenStorage.token = response.accessToken
//                    self.switchToTabBarController()
//                    UIBlockingProgressHUD.dismiss()
//                case.failure(let error):
//                    self.showAlert(with: error)
//                    UIBlockingProgressHUD.dismiss()
//                }
//            }
//        }
//    }
//}
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(
        _ vc: AuthViewController,
        didAuthenticateWithCode code: String
    ) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchAuthToken(code) { result in
            
            switch result {
            case .success(let response):
                self.oauth2TokenStorage.token = response.accessToken
                self.fetchProfile(token: self.oauth2TokenStorage.token!)
                self.switchToTabBarController()
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                self.showAlert(with: error)
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}
