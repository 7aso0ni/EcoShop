//
//  ProductDetailTableViewController.swift
//  EcoShop
//
//  Created by user244986 on 12/6/24.
//

import UIKit
import FirebaseStorage

class StoreProductDetailTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var storeProduct: StoreProduct? = nil
    
    var imageURL: URL? = nil
    
    @IBOutlet var productIamgeView: UIImageView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var stockTextField: UITextField!
    @IBOutlet var plasticReducedTextField: UITextField!
    @IBOutlet var waterConsumedTextField: UITextField!
    @IBOutlet var co2SavedTextField: UITextField!
    @IBOutlet var priceTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var energySavedTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        
        productIamgeView.layer.cornerRadius = 5

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func decrementQuantity(_ sender: UIButton) {
        if let int = Int(stockTextField.text ?? "") {
            guard int <= 0 else {
                stockTextField.text = "\(int - 1)"
                return
            }
        }
    }
    
    @IBAction func incrementQuantity(_ sender: UIButton) {
        if let int = Int(stockTextField.text ?? "") {
            stockTextField.text = "\(int + 1)"
        }
    }
    
    @IBAction func uploadImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                
                // Firebase upload
                let storageRef = Storage.storage().reference()
                let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
                
                imageRef.putData(imageData) { metadata, error in
                    if let error = error {
                        print("Error uploading: \(error)")
                        return
                    }
                    
                    // Get download URL and set image
                    imageRef.downloadURL { url, error in
                        if let error = error {
                            print("Error uploading: \(error)")
                            return
                        }
                        
                        self.imageURL = url
                        
                        DispatchQueue.main.async {
                            self.productIamgeView.image = image
                            picker.dismiss(animated: true)
                        }
                    }
                }
            }
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let name = nameTextField.text, let price = Double(priceTextField.text ?? "0"), let stock = Int(stockTextField.text ?? "0"), let imageURL = self.imageURL, let description = descriptionTextView.text else {
            return
        }

        let co2Saved = Int(co2SavedTextField.text ?? "0") ?? 0
        let waterConserved = Int(waterConsumedTextField.text ?? "0") ?? 0
        let plasticReduced = Int(plasticReducedTextField.text ?? "0") ?? 0
        let energySaved = Int(energySavedTextField.text ?? "0") ?? 0
        
        storeProduct = StoreProduct(name: name, imageURL: imageURL.absoluteString, stockQuantity: stock, price: price, description: description, co2Saved: co2Saved, waterConserved: waterConserved, plasticReduced: plasticReduced, enerygySaved: energySaved)
        
        Task {
            do {
                try await storeProduct?.saveProduct()
            } catch {
                print("Error fetching products: \(error)")
            }
        }
    }


}
