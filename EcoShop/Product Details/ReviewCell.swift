//
//  ReviewCell.swift
//  EcoShop
//
//  Created by Ahmed Mohammed on 04/12/2024.
//

import UIKit

class ReviewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var reviewContentTextView: UITextView!
    @IBOutlet weak var reviewerNameLabel: UILabel!
    @IBOutlet weak var ratingStarButton1: UIButton!
    @IBOutlet weak var ratingStarButton2: UIButton!
    @IBOutlet weak var ratingStarButton3: UIButton!
    @IBOutlet weak var ratingStarButton4: UIButton!
    @IBOutlet weak var ratingStarButton5: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Configure text view
        reviewContentTextView.isEditable = false
        reviewContentTextView.isScrollEnabled = false
        
        // Configure stars
        [ratingStarButton1, ratingStarButton2, ratingStarButton3, ratingStarButton4, ratingStarButton5].forEach { star in
            star?.isUserInteractionEnabled = false
            star?.tintColor = .gray
        }
    }
    
    func configure(with review: Review) {
        reviewContentTextView.text = review.content
        reviewerNameLabel.text = "By: \(review.userName)"
        
        // Update stars based on rating
        let stars = [ratingStarButton1, ratingStarButton2, ratingStarButton3, ratingStarButton4, ratingStarButton5]
        stars.enumerated().forEach { index, star in
            star?.tintColor = index < review.rating ? .systemYellow : .gray
        }
    }
}
