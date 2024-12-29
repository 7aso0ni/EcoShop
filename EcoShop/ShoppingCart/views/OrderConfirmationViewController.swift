//
//  OrderConfirmationViewController.swift
//  EcoShop
//
//  Created by user244986 on 12/26/24.
//

import UIKit

class OrderConfirmationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }
    

    @IBAction func trackOrderBtnTapped(_ sender: UIButton) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window,
           let tabBarController = window.rootViewController as? UITabBarController {
            
            // Reset all navigation stacks first
            tabBarController.viewControllers?.forEach { viewController in
                if let navController = viewController as? UINavigationController {
                    navController.popToRootViewController(animated: false)
                }
            }
            
            // Set the home tab first (assuming home is index 0)
            tabBarController.selectedIndex = 0
            
            // Dismiss all modally presented views
            window.rootViewController?.dismiss(animated: false) {
                // Then switch to orders tab
                tabBarController.selectedIndex = 4
            }
        }

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
