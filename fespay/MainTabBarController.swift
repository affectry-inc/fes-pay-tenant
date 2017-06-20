//
//  MainTabBarController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/13.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBar.items?[0].title = I18n.localize(key: "list")
        self.tabBar.items?[1].title = I18n.localize(key: "new")
        self.tabBar.items?[2].title = I18n.localize(key: "settings")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.restorationIdentifier == "NewPayNavigation" {
            if let next = tabBarController.storyboard?.instantiateViewController(withIdentifier: "NewPayNavigation") {
                tabBarController.present(next, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.restorationIdentifier == "PayListNavigation" {
            let nav = tabBarController.viewControllers?[tabBarController.selectedIndex] as? UINavigationController
            nav?.popToRootViewController(animated: false)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
