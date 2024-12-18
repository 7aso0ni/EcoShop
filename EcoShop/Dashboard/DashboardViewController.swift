//
//  DashboardViewController.swift
//  EcoShop
//
//  Created by Hussain Almakana on 08/12/2024.
//

import UIKit

class DashboardViewController: UITableViewController {
    
    var isLoading = true;
    var userMetrics: [Metrics] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchAndPrint(startDate: nil)
    }
    
    func fetchAndPrint(startDate: Date?) {
        let userId = "9264ab1a-5d43-403b-a23f-bf4d6b332fff"
        
        Order.fetchUserMetrics(userId: userId, startDate: startDate) { result in
            switch result {
            case .success(let metrics):
                print("Fetched Metrics:")
                for metric in metrics {
                    print("Name: \(metric.name), Value: \(metric.value), Unit: \(metric.unit)")
                }
                
            case .failure(let error):
                print("Error fetching metrics: \(error.localizedDescription)")
            }
            }
            
        }

    
    @IBAction func dateRangeChanged(_ sender: UISegmentedControl) {
        let calendar = Calendar.current
            let now = Date()
            var startDate: Date? = nil

            // Determine the date range based on the selected segment
            switch sender.selectedSegmentIndex {
            case 0: // All Time
                startDate = nil
            case 1: // Yearly
                startDate = calendar.date(byAdding: .year, value: -1, to: now)
            case 2: // Monthly
                startDate = calendar.date(byAdding: .month, value: -1, to: now)
            case 3: // Daily
                startDate = calendar.date(byAdding: .day, value: -1, to: now)
            default:
                startDate = nil
            }

            // Fetch metrics with the specified startDate
            fetchAndPrint(startDate: startDate)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

