//
//  StoreProductCell.swift
//  EcoShop
//
//  Created by user244986 on 12/2/24.
//

import UIKit

class StoreProductCell: UITableViewCell {

    @IBOutlet var productCardView: UIView!
    
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var productNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        productCardView.layer.cornerRadius = 10
    }

    @IBAction func editButton(_ sender: UIButton) {
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
