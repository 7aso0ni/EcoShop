//
//  AhmedViewController.swift
//  EcoShop
//
//  Created by BP-36-201-06 on 02/12/2024.
//

import UIKit
import FirebaseFirestore

class AhmedViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var environmentalImpactTextView: UITextView!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    
    // MARK: - Properties
    var productId: String?
    private var product: Product?
    private var selectedQuantity: Int = 1
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Set a default product ID for testing if none is provided
        if productId == nil {
            productId = "02a3c9b2-6c12-40d5-8d4c-218a8ddd5d27"
        }
        
        fetchProductDetails()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        // Initial UI setup
        quantityStepper.value = Double(selectedQuantity)
        quantityLabel.text = "\(selectedQuantity)"
        
        // Configure text views
        descriptionTextView.isEditable = false
        environmentalImpactTextView.isEditable = false
        
        // Add stepper value changed action
        quantityStepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
    }
    
    private func setupStarRatingView() {
        // Create a horizontal stack view for stars
        let starStackView = UIStackView()
        starStackView.axis = .horizontal
        starStackView.distribution = .fillEqually
        starStackView.spacing = 8
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add existing star buttons to the stack view
        [star1, star2, star3, star4, star5].forEach { button in
            if let button = button {
                starStackView.addArrangedSubview(button)
                
                // Configure each star button
                button.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    button.widthAnchor.constraint(equalToConstant: 40),
                    button.heightAnchor.constraint(equalToConstant: 40)
                ])
            }
        }
        
        // Add stack view to the view hierarchy (assuming it should be below the product name)
        if let firstStar = star1 {
            view.addSubview(starStackView)
            
            // Position the stack view
            NSLayoutConstraint.activate([
                starStackView.topAnchor.constraint(equalTo: firstStar.topAnchor),
                starStackView.leadingAnchor.constraint(equalTo: firstStar.leadingAnchor),
                starStackView.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    }
    
    private func fetchProductDetails() {
        guard let id = productId else {
            print("❌ No product ID available")
            return
        }
        
        print("🔍 Fetching product with ID: \(id)")
        
        Task {
            do {
                if let fetchedProduct = try await Product.fetchProduct(withId: id) {
                    print("✅ Successfully fetched product: \(fetchedProduct.name)")
                    self.product = fetchedProduct
                    DispatchQueue.main.async {
                        self.updateUI(with: fetchedProduct)
                    }
                } else {
                    print("❌ No product found with ID: \(id)")
                    DispatchQueue.main.async {
                        self.showAlert(title: "Error", message: "Product not found")
                    }
                }
            } catch {
                print("❌ Error fetching product: \(error)")
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to load product details. Please try again.")
                }
            }
        }
    }
    
    private func updateUI(with product: Product) {
        productNameLabel.text = product.name
        priceLabel.text = String(format: "%.2f", product.price)
        descriptionTextView.text = product.description
        environmentalImpactTextView.text = product.environmentalImpactSummary
        
        // Update quantity stepper max value
        quantityStepper.maximumValue = Double(product.stockQuantity)
        
        // Update rating stars
        updateRatingStars(rating: product.rating)
        
        // Load image if URL is valid
        if let url = URL(string: product.imageURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                if let error = error {
                    print("Error loading image: \(error)")
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.productImageView.image = image
                    }
                }
            }.resume()
        }
    }
    
    private func updateRatingStars(rating: Int) {
        let starButtons = [star1, star2, star3, star4, star5]
        starButtons.enumerated().forEach { index, button in
            guard let button = button else { return }
            
            // Create star images
            let filledStar = UIImage(systemName: "star.fill")
            let emptyStar = UIImage(systemName: "star")
            
            // Set image and color based on rating
            button.setImage(index < rating ? filledStar : emptyStar, for: .normal)
            button.tintColor = index < rating ? .systemYellow : .gray
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Error loading image: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.productImageView.image = image
                }
            }
        }.resume()
    }
    
    private func showAlert(title: String, message: String, preferredStyle: UIAlertController.Style = .alert, actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default)]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func stepperValueChanged() {
        selectedQuantity = Int(quantityStepper.value)
        quantityLabel.text = "\(selectedQuantity)"
    }
    
    @IBAction func addToCartTapped(_ sender: Any) {
        guard let product = product else { return }
        // TODO: Implement cart functionality
        showAlert(title: "Success", message: "\(selectedQuantity) x \(product.name) added to cart!")
    }
    
    @IBAction func viewRatingsTapped(_ sender: Any) {
        // Handled by storyboard segue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("🔄 AhmedViewController - Preparing for segue")
        if let reviewVC = segue.destination as? ReviewViewController {
            print("✅ AhmedViewController - Found ReviewViewController")
            reviewVC.productId = product?.id
            print("📦 AhmedViewController - Set productId: \(String(describing: product?.id))")
        } else {
            print("❌ AhmedViewController - Failed to cast to ReviewViewController")
        }
    }
}
