//
//  ImagesListCell.swift
//  imageFeed
//
//  Created by Alex on /263/23.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    private let gradientContainerView = UIView()
    static let reuseIdentifier = "ImagesListCell"
    private let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureGradientLayer()
        
        gradientContainerView.frame = imageCell.bounds
        gradientContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageCell.addSubview(gradientContainerView)
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
