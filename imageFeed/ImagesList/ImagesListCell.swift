//
//  ImagesListCell.swift
//  imageFeed
//
//  Created by Alex on /263/23.
//
import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    weak var delegate: ImagesListCellDelegate?
    
    private let gradientContainerView = UIView()
    static let reuseIdentifier = "ImagesListCell"
    private let gradientLayer = CAGradientLayer()
    
    lazy var imageCell: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "likeButton"
        return button
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    @objc private func likeButtonClicked(_ sender: Any) {
        delegate?.ImagesListCellDidTapLike(self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureGradientLayer()
        
        setupViews()
        addViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageCell.kf.cancelDownloadTask() // Отменяем текущую задачу загрузки
        imageCell.image = nil // Устанавливаем изображение в nil
    }
    
    func setLike(like: Bool) {
        if like {
            likeButton.setImage(UIImage(named: "like_button_on"), for: .normal)
        } else {
            likeButton.setImage(UIImage(named: "like_button_off"), for: .normal)
        }
    }
    
    private func setupViews() {
        contentView.addSubview(imageCell)
        contentView.addSubview(likeButton)
        contentView.addSubview(dateLabel)
        
        gradientContainerView.frame = imageCell.bounds
        gradientContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageCell.addSubview(gradientContainerView)
        
        likeButton.addTarget(self, action: #selector(likeButtonClicked(_:)), for: .touchUpInside)
    }
    
    private func configureGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientContainerView.layer.addSublayer(gradientLayer)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(x: 0, y: dateLabel.frame.origin.y, width: bounds.width, height: bounds.height - dateLabel.frame.origin.y)
    }
}

extension ImagesListCell {
    func addViewConstraints() {
        NSLayoutConstraint.activate([
            imageCell.trailingAnchor.constraint(greaterThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            imageCell.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            imageCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageCell.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            
            gradientContainerView.heightAnchor.constraint(equalToConstant: 30),
            gradientContainerView.bottomAnchor.constraint(equalTo: imageCell.bottomAnchor),
            gradientContainerView.trailingAnchor.constraint(equalTo: imageCell.trailingAnchor),
            gradientContainerView.leadingAnchor.constraint(equalTo: imageCell.leadingAnchor),
            
            likeButton.widthAnchor.constraint(equalToConstant: 42),
            likeButton.heightAnchor.constraint(equalToConstant: 42),
            likeButton.trailingAnchor.constraint(equalTo: imageCell.trailingAnchor),
            likeButton.topAnchor.constraint(equalTo: imageCell.topAnchor),
            
            dateLabel.trailingAnchor.constraint(greaterThanOrEqualTo: imageCell.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: imageCell.bottomAnchor, constant: -8),
            dateLabel.leadingAnchor.constraint(equalTo: imageCell.leadingAnchor, constant: 8)
        ])
    }
}
