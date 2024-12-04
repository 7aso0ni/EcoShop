import UIKit

class ReviewCell: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    // MARK: - Star Rating Outlets
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with review: Review) {
        contentLabel.text = review.content
        ratingLabel.text = "Rating: \(review.rating)/5"
        
        // Update stars
        let starButtons = [star1, star2, star3, star4, star5]
        starButtons.enumerated().forEach { index, starButton in
            let filled = index < review.rating
            starButton?.tintColor = filled ? .systemYellow : .gray
        }
    }
}
