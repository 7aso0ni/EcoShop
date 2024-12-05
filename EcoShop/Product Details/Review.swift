//
//  Review.swift
//  EcoShop
//
//  Created by Ahmed Mohammed on 04/12/2024.
//

import Foundation
import FirebaseFirestore

struct Review: Codable {
    let id: String
    let content: String
    let productId: String
    let rating: Int
    let userName: String
    
    static func fetchReviews(for productId: String) async throws -> [Review] {
        print("🔍 Review - Fetching reviews for productId: \(productId)")
        let db = Firestore.firestore()
        let snapshot = try await db.collection("reviews")
            .whereField("productId", isEqualTo: productId)
            .getDocuments()
        
        let reviews = snapshot.documents.compactMap { document in
            try? Review(
                id: document.documentID,
                content: document["content"] as? String ?? "",
                productId: document["productId"] as? String ?? "",
                rating: document["rating"] as? Int ?? 0,
                userName: document["userName"] as? String ?? "Anonymous"
            )
        }
        print("✅ Review - Found \(reviews.count) reviews")
        return reviews
    }
} 
