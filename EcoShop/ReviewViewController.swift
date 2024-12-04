import UIKit
import FirebaseFirestore

class ReviewViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var newReviewTextView: UITextView!
    @IBOutlet weak var submitReviewButton: UIButton!
    @IBOutlet weak var ratingStarButton1: UIButton!
    @IBOutlet weak var ratingStarButton2: UIButton!
    @IBOutlet weak var ratingStarButton3: UIButton!
    @IBOutlet weak var ratingStarButton4: UIButton!
    @IBOutlet weak var ratingStarButton5: UIButton!
    
    // MARK: - Properties
    var productId: String?
    private var reviews: [Review] = []
    private var selectedRating: Int = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("⚠️ ReviewViewController loaded")
        
        setupUI()
        fetchReviews()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // TableView setup
        reviewTableView.dataSource = self
        reviewTableView.delegate = self
        reviewTableView.rowHeight = 150
        
        // Register cell nib
        let nib = UINib(nibName: "ReviewCell", bundle: nil)
        reviewTableView.register(nib, forCellReuseIdentifier: "ReviewCell")
        
        // Review input setup
        newReviewTextView.layer.borderWidth = 1
        newReviewTextView.layer.borderColor = UIColor.lightGray.cgColor
        newReviewTextView.layer.cornerRadius = 5
        
        // Star rating setup
        [ratingStarButton1, ratingStarButton2, ratingStarButton3, ratingStarButton4, ratingStarButton5].enumerated().forEach { index, button in
            button?.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            button?.tag = index + 1
        }
    }
    
    // MARK: - Actions
    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStars()
    }
    
    private func updateStars() {
        [ratingStarButton1, ratingStarButton2, ratingStarButton3, ratingStarButton4, ratingStarButton5].enumerated().forEach { index, button in
            button?.tintColor = index < selectedRating ? .systemYellow : .gray
        }
    }
    
    @IBAction func submitReviewTapped(_ sender: Any) {
        guard let productId = productId,
              let content = newReviewTextView.text,
              !content.isEmpty,
              selectedRating > 0 else {
            showAlert(title: "Error", message: "Please enter a review and select a rating")
            return
        }
        
        submitReview(content: content, rating: selectedRating, productId: productId)
    }
    
    // MARK: - Firebase Operations
    private func submitReview(content: String, rating: Int, productId: String) {
        Task {
            do {
                let db = Firestore.firestore()
                let reviewData: [String: Any] = [
                    "content": content,
                    "productId": productId,
                    "rating": rating,
                    "userName": "Ahmed"
                ]
                
                try await db.collection("reviews").addDocument(data: reviewData)
                
                // Clear form and refresh
                DispatchQueue.main.async {
                    self.newReviewTextView.text = ""
                    self.selectedRating = 0
                    self.updateStars()
                    self.fetchReviews()
                }
                
                showAlert(title: "Success", message: "Review submitted successfully!")
            } catch {
                showAlert(title: "Error", message: "Failed to submit review")
            }
        }
    }
    
    private func fetchReviews() {
        guard let productId = productId else {
            print("❌ No productId found")
            return
        }
        print("🔍 Fetching reviews for productId: \(productId)")
        
        Task {
            do {
                reviews = try await Review.fetchReviews(for: productId)
                print("✅ Found \(reviews.count) reviews")
                print("📝 Reviews: \(reviews)")
                DispatchQueue.main.async {
                    self.reviewTableView.reloadData()
                }
            } catch {
                print("❌ Error fetching reviews: \(error)")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension ReviewViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("📊 Number of reviews: \(reviews.count)")
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("🔄 Attempting to dequeue cell for row \(indexPath.row)")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewCell else {
            print("❌ Failed to dequeue ReviewCell - falling back to basic cell")
            let basicCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            basicCell.textLabel?.text = reviews[indexPath.row].content
            return basicCell
        }
        
        print("✅ Successfully dequeued ReviewCell")
        let review = reviews[indexPath.row]
        cell.configure(with: review)
        return cell
    }
}
