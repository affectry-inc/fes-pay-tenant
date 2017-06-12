//
//  AnalyticsViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/09.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class AnalyticsViewController: UIViewController, UITabBarDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var fesNameLabel: UILabel!
    @IBOutlet weak var tenantNameLabel: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var totalBorderLabel: UILabel!
    @IBOutlet weak var countTitleLabel: UILabel!
    @IBOutlet weak var countValueLabel: UILabel!
    @IBOutlet weak var countBorderLabel: UILabel!
    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Tab bar setting
        tabBar.tintColor = primary1Color
        tabBar.selectedItem = tabBar.items?[0]
        tabBar.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.totalBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.countBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TabBar delegate
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag{
        case 0:
            self.performSegue(withIdentifier: "unwindFromAnalytics", sender: self)
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
