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
    private var product: Product?
    private var selectedQuantity: Int = 1
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
    
    private func fetchProductDetails() {
        // Use a specific product ID from your database
        let productId = "02a3c9b2-6c12-40d5-8d4c-218a8ddd5d27"  // Use one of your actual product IDs
        
        Task {
            do {
                if let product = try await Product.fetchProduct(withId: productId) {
                    self.product = product
                    updateUI(with: product)
                } else {
                    showAlert(title: "Error", message: "Failed to load product details")
                }
            } catch {
                print("Error fetching product: \(error)")
                showAlert(title: "Error", message: "Failed to load product details")
            }
        }
    }
    
    private func updateUI(with product: Product) {
        DispatchQueue.main.async {
            // Basic product info
            self.productNameLabel.text = product.name
            self.priceLabel.text = String(format: "%.2f BHD", product.price)
            self.descriptionTextView.text = product.description
            
            // Rating
            let rating = product.rating
            let starButtons = [self.star1, self.star2, self.star3, self.star4, self.star5]
            
            starButtons.enumerated().forEach { index, starButton in
                let filled = index < rating
                starButton?.tintColor = filled ? .systemYellow : .gray
            }
            
            // Metrics (Environmental Impact)
            let metricsText = product.metrics.map { metric in
                return "\(metric.name): \(metric.value)"
            }.joined(separator: "\n")
            self.environmentalImpactTextView.text = metricsText
            
            // Stock quantity for stepper
            self.quantityStepper.maximumValue = Double(product.stockQuantity)
            self.quantityStepper.value = 1
            self.quantityLabel.text = "1"
            
            // Load product image
            if let url = URL(string: product.imageURL) {
                self.loadImage(from: url)
            }
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
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
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
        if let reviewVC = segue.destination as? ReviewViewController {
            reviewVC.productId = product?.id
        }
    }
}
