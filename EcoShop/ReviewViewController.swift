import UIKit
import FirebaseFirestore

class ReviewViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var productId: String?
    private var reviews: [Review] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        fetchReviews()
    }
    
    private func fetchReviews() {
        guard let productId = productId else { return }
        
        Task {
            do {
                reviews = try await Review.fetchReviews(for: productId)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Error fetching reviews: \(error)")
            }
        }
    }
}

extension ReviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        let review = reviews[indexPath.row]
        cell.configure(with: review)
        return cell
    }
}
