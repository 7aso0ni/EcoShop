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
    
    static func fetchReviews(for productId: String) async throws -> [Review] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("reviews")
            .whereField("productId", isEqualTo: productId)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? Review(
                id: document.documentID,
                content: document["content"] as? String ?? "",
                productId: document["productId"] as? String ?? "",
                rating: document["rating"] as? Int ?? 0
            )
        }
    }
} 
