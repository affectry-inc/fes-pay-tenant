//
//  SettingsViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/12.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UINavigationBarDelegate, UITabBarDelegate {

    // MARK: - Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var eventBorderLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventValueLabel: UILabel!
    @IBOutlet weak var tenantIdBorderLabel: UILabel!
    @IBOutlet weak var tenantIdTitleLabel: UILabel!
    @IBOutlet weak var tenantIdValueLabel: UILabel!
    @IBOutlet weak var tenantNameBorderLabel: UILabel!
    @IBOutlet weak var tenantNameTitleLabel: UILabel!
    @IBOutlet weak var tenantNameValueLabel: UILabel!
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UINavigationBarDelegate setting
        navBar.delegate = self
        
        // Tab bar setting
        tabBar.tintColor = primary1Color
        tabBar.selectedItem = tabBar.items?[2]
        tabBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UINavigationBarDelegate
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    // MARK: - TabBar delegate
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag{
        case 0:
            self.performSegue(withIdentifier: "unwindFromSettings", sender: self)
        case 1:
            let next = self.storyboard?.instantiateViewController(withIdentifier: "NewPayNavigation") as! UINavigationController
            
            self.present(next, animated: true, completion: nil)
        case 2:
            print("2")
        default :
            return
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
