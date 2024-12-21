//
//  Product.swift
//  EcoShop
//
//  Created by Ahmed Mohammed on 04/12/2024.
//

import Foundation
import FirebaseFirestore

struct Metric: Codable {
    let name: String
    let unit: String
    let value: Double
    
    var formattedString: String {
        return "\(name): \(String(format: "%.1f", value)) \(unit)"
    }
}

struct Product: Codable {
    let id: String
    let name: String
    let price: Double
    let description: String
    let imageURL: String
    let stockQuantity: Int
    let storeOwnerId: String
    let averageRating: String
    let rating: Int
    let metrics: [Metric]
    
    var environmentalImpactSummary: String {
        return metrics.map { $0.formattedString }.joined(separator: "\n")
    }
    
    static func fetchProduct(withId id: String) async throws -> Product? {
        let db = Firestore.firestore()
        let docRef = db.collection("products").document(id)
        let snapshot = try await docRef.getDocument()
        
        guard let data = snapshot.data() else { return nil }
        
        print("Fetched data: \(data)")
        
        return try? Product(
            id: snapshot.documentID,
            name: data["name"] as? String ?? "",
            price: data["price"] as? Double ?? 0.0,
            description: data["description"] as? String ?? "",
            imageURL: data["imageURL"] as? String ?? "",
            stockQuantity: data["stockQuantity"] as? Int ?? 0,
            storeOwnerId: data["storeOwnerId"] as? String ?? "",
            averageRating: data["averageRating"] as? String ?? "0.0",
            rating: data["rating"] as? Int ?? 0,
            metrics: (data["metrics"] as? [[String: Any]])?.compactMap { metricData in
                guard let name = metricData["name"] as? String,
                      let unit = metricData["unit"] as? String,
                      let value = metricData["value"] as? Double else { return nil }
                return Metric(name: name, unit: unit, value: value)
            } ?? []
        )
    }
}
