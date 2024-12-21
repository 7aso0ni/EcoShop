import Foundation
import FirebaseFirestore

struct Review: Codable {
    let id: String
    let content: String
    let productId: String
    let rating: Int
    let username: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case productId
        case rating
        case username
        case timestamp
    }
    
    // MARK: - Firebase Operations
    static func submitReview(content: String, productId: String, rating: Int, username: String) async throws -> Review {
        let db = Firestore.firestore()
        let reviewsRef = db.collection("reviews")
        
        // Create review document
        let newReview = Review(
            id: UUID().uuidString,
            content: content,
            productId: productId,
            rating: rating,
            username: username,
            timestamp: Date()
        )
        
        // Convert to dictionary
        let reviewData: [String: Any] = [
            "id": newReview.id,
            "content": newReview.content,
            "productId": newReview.productId,
            "rating": newReview.rating,
            "username": newReview.username,
            "timestamp": Timestamp(date: newReview.timestamp)
        ]
        
        // Save to Firebase
        try await reviewsRef.document(newReview.id).setData(reviewData)
        
        return newReview
    }
    
    static func fetchReviews(for productId: String) async throws -> [Review] {
        let db = Firestore.firestore()
        let reviewsRef = db.collection("reviews")
        
        // Query reviews for this product
        let snapshot = try await reviewsRef
            .whereField("productId", isEqualTo: productId)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        // Convert documents to Review objects
        return try snapshot.documents.map { document in
            let data = document.data()
            
            guard let id = data["id"] as? String,
                  let content = data["content"] as? String,
                  let productId = data["productId"] as? String,
                  let rating = data["rating"] as? Int,
                  let username = data["username"] as? String,
                  let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid review data"])
            }
            
            return Review(
                id: id,
                content: content,
                productId: productId,
                rating: rating,
                username: username,
                timestamp: timestamp
            )
        }
    }
}
