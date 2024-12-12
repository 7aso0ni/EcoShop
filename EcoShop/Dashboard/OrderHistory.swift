//
//  OrderHistory.swift
//  EcoShop
//
//  Created by Hussain Almakana on 12/12/2024.
//

import Foundation
import FirebaseFirestore

struct Metrics: Codable, AdditiveArithmetic {
    
    
    let name: String
    let unit: String
    let value: Int
    
    // Conform to AdditiveArithmetic
    static var zero: Metrics {
        return Metrics(name: "None", unit: "", value: 0)
    }
        
    static func + (lhs: Metrics, rhs: Metrics) -> Metrics {
        // Make sure you're adding metrics with the same name and unit
        assert(lhs.name == rhs.name && lhs.unit == rhs.unit, "Cannot add metrics with different names or units")
            
        return Metrics(name: lhs.name, unit: lhs.unit, value: lhs.value + rhs.value)
    }
    
    static func - (lhs: Metrics, rhs: Metrics) -> Metrics {
        assert(lhs.name == rhs.name && lhs.unit == rhs.unit, "Cannot subtract metrics with different names or units")
        return Metrics(name: lhs.name, unit: lhs.unit, value: lhs.value - rhs.value)
    }
}

struct OrderItem: Codable {
    let id: String
    let quantity: Int
}

struct Order: Codable {
    let id: String
    let dateOrdered: Date
    let products: [Product]
    let status: String
    let storeOwnerId: String
    let totalPrice: Float
    
//    A closure that the function calls when it's done fetching data (successfully or with an error).
//    it's marked as escaping because it will be called later after the fetching is done
    static func fetchUserMetrics(userId: String, completion: @escaping (Result<[Metrics], Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("orders").whereField("userId", isEqualTo: userId).whereField("status", isNotEqualTo: "Canceled").getDocuments { (orderSnapshot, error) in
            
            if let error = error {
                // return the error via the completion handler
                completion(.failure(error))
                return
            }
            
            var allMetrics: [Metrics] = []
            let group = DispatchGroup() // used to wait for all product fetches
            
            for document in orderSnapshot!.documents {
                let orderData = document.data()
                if let products = orderData["products"] as? [[String: Any]] {
                    for product in products {
                        if let productId = product["id"] as? String {
                            // start waiting for product data
                            group.enter()
                            
                            db.collection("products").document(productId).getDocument { (productSnapshot, error) in
                                if let error = error {
                                    completion(.failure(error))
                                } else if let productData = productSnapshot?.data() {
                                    if let productMetrics = productData["metrics"] as? [[String: Any]] {
                                        for metricData in productMetrics {
                                            
                                       
                                        if let name = metricData["name"] as? String,
                                            let unit = metricData["unit"] as? String,
                                            let value = metricData["value"] as? Int {
                                                                                        
                            // Add the metric to the allMetrics
                                            allMetrics.append(Metrics(name: name, unit: unit, value: value))
                                        }
                                                                                    }
                                    }
                                }
                            }
                            
                            group.leave() // finished fetching one product
                        }
                    }
                }
                
                //
                group.notify(queue: .main) {
                    let combineMetrics = combineMetrics(allMetrics)
                    
                    // return the combined metrics via the completion handler
                    completion(.success(combineMetrics))
                }
            }
        }
    }
}

func combineMetrics(_ metrics: [Metrics]) -> [Metrics] {
    var combinedMetrics: [Metrics] = []
    var metricMap: [String: Metrics] = [:]
    
    for metric in metrics {
        if let existingMetric = metricMap[metric.name] {
            let combinedValue = existingMetric.value + metric.value
            metricMap[metric.name] = Metrics(name: existingMetric.name, unit: existingMetric.unit, value: combinedValue)
        } else {
            metricMap[metric.name] = metric
        }
    }
    
    // convert the map back into an array
    combinedMetrics = Array(metricMap.values)
    return combinedMetrics
}
