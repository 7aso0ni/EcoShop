//
//  ProductViewController.swift
//  EcoShop
//
//  Created by Sayed Shubbar Qasim on 23/12/2024.
//

import UIKit
import FirebaseFirestore

class ProductViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var products: [Product] = [] // Full list of products
    private var filteredProducts: [Product] = [] // Filtered list for search results
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        searchBar.delegate = self
        
        // Fetch products
        Task {
            await fetchProducts()
        }
    }
    
    // Fetch products from Firestore
    private func fetchProducts() async {
        do {
            let db = Firestore.firestore()
            let snapshot = try await db.collection("products").getDocuments()
            self.products = snapshot.documents.compactMap { doc in
                try? Product(
                    id: doc.documentID,
                    name: doc["name"] as? String ?? "",
                    price: doc["price"] as? Double ?? 0.0,
                    description: doc["description"] as? String ?? "",
                    imageURL: doc["imageURL"] as? String ?? "",
                    stockQuantity: doc["stockQuantity"] as? Int ?? 0,
                    storeOwnerId: doc["storeOwnerId"] as? String ?? "",
                    averageRating: doc["averageRating"] as? String ?? "0.0",
                    rating: doc["rating"] as? Int ?? 0,
                    metrics: (doc["metrics"] as? [[String: Any]])?.compactMap { metricData in
                        guard let name = metricData["name"] as? String,
                              let unit = metricData["unit"] as? String,
                              let value = metricData["value"] as? Double else { return nil }
                        return Metric(name: name, unit: unit, value: value)
                    } ?? []
                )
            }
            self.filteredProducts = self.products // Initialize filteredProducts with all products
            DispatchQueue.main.async {
                self.table.reloadData()
            }
        } catch {
            print("Error fetching products: \(error.localizedDescription)")
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = filteredProducts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! CustomTableViewCell
        
        cell.productName.text = product.name
        cell.productDesc.text = product.description
        cell.productPrice.text = String(format: "%.2f BD", product.price)
        
        if let url = URL(string: product.imageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.productImageView.image = image
                    }
                }
            }.resume()
        } else {
            cell.productImageView.image = UIImage(named: "placeholder")
        }
        
        cell.viewButton.tag = indexPath.row
        cell.viewButton.addTarget(self, action: #selector(viewButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredProducts = products
        } else {
            filteredProducts = products.filter { product in
                product.name.lowercased().contains(searchText.lowercased()) ||
                product.description.lowercased().contains(searchText.lowercased())
            }
        }
        table.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @objc private func viewButtonTapped(_ sender: UIButton) {
        let selectedProduct = filteredProducts[sender.tag]
        
        let storyboard = UIStoryboard(name: "Ahmed", bundle: nil)
        if let friendVC = storyboard.instantiateViewController(withIdentifier: "AhmedViewController") as? AhmedViewController {
            friendVC.productId = selectedProduct.id
            self.navigationController?.pushViewController(friendVC, animated: true)
        }
    }
}
