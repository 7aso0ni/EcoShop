//
//  MainTabBarController.swift
//  EcoShop
//
//  Created by user244986 on 12/26/24.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(switchToOrders),
                                               name: NSNotification.Name("SwitchToOrdersTab"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func switchToOrders() {
        self.selectedIndex = 2 // Orders tab index
    }

}
