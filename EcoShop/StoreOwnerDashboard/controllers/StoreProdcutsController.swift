//
//  StoreProdcutsController.swift
//  EcoShop
//
//  Created by user244986 on 12/3/24.
//

import UIKit

class StoreProdcutsController: UITableViewController {
    var storeProducts = [StoreProduct]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        Task {
            do {
                storeProducts = try await StoreProduct.fetchProducts()
                
                DispatchQueue.main.async{
                    for i in 2...(self.storeProducts.count + 2) {
                        print("\(self.storeProducts[i - 2].name)")
                        let newIndexPath = IndexPath(row: i, section: 0)
                        self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                    }
                }
            } catch {
                print("Error fetching products: \(error)")
            }
        }
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2 + storeProducts.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 || indexPath.row == 1 {
            let identifier = indexPath.row == 0 ? "ProductsHeading" : "SearchAndAdd"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
            return cell
        }
        
        let storeProduct = storeProducts[indexPath.row - 2]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Product", for: indexPath) as! StoreProductCell
        cell.productNameLabel.text = storeProduct.name
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
