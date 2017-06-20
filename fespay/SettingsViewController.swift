//
//  SettingsViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/12.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UINavigationBarDelegate {

    let i18n = I18n(tableName: "SettingsView")
    
    // MARK: - Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var eventBorderLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventValueLabel: UILabel!
    @IBOutlet weak var shopIdBorderLabel: UILabel!
    @IBOutlet weak var shopIdTitleLabel: UILabel!
    @IBOutlet weak var shopIdValueLabel: UILabel!
    @IBOutlet weak var shopNameBorderLabel: UILabel!
    @IBOutlet weak var shopNameTitleLabel: UILabel!
    @IBOutlet weak var shopNameValueLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UINavigationBarDelegate setting
        navBar.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navBar.topItem?.title = i18n.localize(key: "settings")
        self.eventTitleLabel.text = i18n.localize(key: "event")
        self.shopIdTitleLabel.text = i18n.localize(key: "shopId")
        self.shopNameTitleLabel.text = i18n.localize(key: "shopName")
        self.logoutButton.setTitle(i18n.localize(key: "logout"), for: .normal)
        
        self.eventBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.shopIdBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.shopNameBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UINavigationBarDelegate
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
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
