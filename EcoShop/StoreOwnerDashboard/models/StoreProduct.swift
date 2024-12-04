//
//  StoreProduct.swift
//  EcoShop
//
//  Created by user244986 on 12/3/24.
//

import Foundation
import FirebaseFirestore

struct StoreProduct: Identifiable {
   let id: String
   let name: String
   let imageURL: String
   var stockQuantity: Int
   var description: String?
   var price: Double
   
   // Initializer
   init(id: String = UUID().uuidString,
        name: String,
        imageURL: String,
        stockQuantity: Int,
        price: Double,
        description: String? = nil) {
       self.id = id
       self.name = name
       self.imageURL = imageURL
       self.stockQuantity = stockQuantity
       self.description = description
       self.price = price
   }
   
   // Firestore document to StoreProduct
   init?(document: QueryDocumentSnapshot) {
       guard let name = document.data()["name"] as? String,
             let imageURL = document.data()["imageURL"] as? String,
             let stockQuantity = document.data()["stockQuantity"] as? Int else {
           return nil
       }
       
       self.id = document.documentID
       self.name = name
       self.imageURL = imageURL
       self.stockQuantity = stockQuantity
       self.description = document.data()["description"] as? String
       self.price = document.data()["price"] as! Double
   }
   
   // Static methods for Firestore operations
   static func fetchProducts() async throws -> [StoreProduct] {
       let db = Firestore.firestore()
       let snapshot = try await db.collection("products").getDocuments()
       
       return snapshot.documents.compactMap { document in
           return StoreProduct(document: document)
       }
   }
   
    static func fetchProducts(forOwnerId ownerId: String) async throws -> [StoreProduct] {
           let db = Firestore.firestore()
           let snapshot = try await db.collection("products")
               .whereField("storeOwnerId", isEqualTo: ownerId)
               .getDocuments()
           
           return snapshot.documents.compactMap { document in
               return StoreProduct(document: document)
           }
       }
    
   static func fetchProduct(withId id: String) async throws -> StoreProduct? {
       let db = Firestore.firestore()
       let document = try await db.collection("products").document(id).getDocument()
       
       guard document.exists else {
           return nil
       }
       
       return StoreProduct(document: document as! QueryDocumentSnapshot)
   }
   
   // Method to update stock quantity
   func updateStockQuantity(newQuantity: Int) async throws {
       let db = Firestore.firestore()
       try await db.collection("products").document(id).updateData([
           "stockQuantity": newQuantity
       ])
   }
   
   // Method to delete product
   func deleteProduct() async throws {
       let db = Firestore.firestore()
       try await db.collection("products").document(id).delete()
   }
   
   // Method to save/update product
   func saveProduct() async throws {
       let db = Firestore.firestore()
       let productData: [String: Any] = [
           "name": name,
           "imageURL": imageURL,
           "stockQuantity": stockQuantity,
           "description": description as Any,
           "price": price as Any
       ]
       
       try await db.collection("products").document(id).setData(productData)
   }
}
