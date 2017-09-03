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
    let tenantInfo = TenantInfo.sharedInstance
    
    // MARK: - Properties
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var eventBorderLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventValueLabel: UILabel!
    @IBOutlet weak var tenantIdBorderLabel: UILabel!
    @IBOutlet weak var tenantIdTitleLabel: UILabel!
    @IBOutlet weak var tenantIdValueLabel: UILabel!
    @IBOutlet weak var tenantNameBorderLabel: UILabel!
    @IBOutlet weak var tenantNameTitleLabel: UILabel!
    @IBOutlet weak var tenantNameValueLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        let actionSheet = i18n.actionSheet(titleKey: "", messageKey: "msgSureToLogout", action1Key: "logout", handler1: {
            FirebaseClient.signOut(onSignOut: {
                self.performSegue(withIdentifier: "unwindToLoginView", sender: self)
            })
        })
        
        present(actionSheet, animated: true)
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
        self.tenantIdTitleLabel.text = i18n.localize(key: "tenantId")
        self.tenantNameTitleLabel.text = i18n.localize(key: "tenantName")
        self.logoutButton.setTitle(i18n.localize(key: "logout"), for: .normal)
        
        self.eventBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.tenantIdBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.tenantNameBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        
        self.eventValueLabel.text = tenantInfo.eventName
        self.tenantIdValueLabel.text = tenantInfo.tenantId
        self.tenantNameValueLabel.text = tenantInfo.tenantName
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
