//
//  SingleImageViewController.swift
//  imageFeed
//
//  Created by Alex on /154/23.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }

    private lazy var scrollView: UIScrollView = {
            let scrollView = UIScrollView()
            return scrollView
        }()
        
        private lazy var imageView: UIImageView = {
            let imageView = UIImageView()
            return imageView
        }()
        
        private lazy var backButton: UIButton = {
            let button = UIButton(type: .custom)
            button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            button.setImage(UIImage(named: "nav_back_button_white"), for: .normal)
            return button
        }()
        
        private lazy var shareButton: UIButton = {
            let button = UIButton(type: .custom)
            button.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            button.setImage(UIImage(named: "share_button"), for: .normal)
            return button
        }()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
                addSubviews()
                addViewConstraints()
                createViews()
        
        imageView.image = image
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 3
        if let image = imageView.image {
                    rescaleAndCenterImageInScrollView(image: image)
                }
        }
    // MARK: - Action func
    @objc private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
   @objc private func didTapShareButton(_ sender: UIButton) {
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true)
    }
    
    
    
    
}
// MARK: - Extension class

private extension SingleImageViewController {
    func createViews() {
        view.backgroundColor = .ypBlack
        imageView.image = image
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    func addSubviews() {
        [scrollView, backButton, shareButton].forEach { item in
            item.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(item)
        }
        
        [imageView].forEach { item in
            item.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(item)
        }
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: false)
            
            let halfWidth = (scrollView.bounds.size.width - imageView.frame.width) / 2
            let halfHeight = (scrollView.bounds.size.height - imageView.frame.height) / 2
            
            scrollView.contentInset = .init(top: halfHeight, left: halfWidth, bottom: 0, right: 0)
        }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        
    }
}



// MARK: - Set Constraints

extension SingleImageViewController {
    func addViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            backButton.heightAnchor.constraint(equalToConstant: 24),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 9),
            
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
