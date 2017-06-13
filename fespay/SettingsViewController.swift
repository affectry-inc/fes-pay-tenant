//
//  SettingsViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/12.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UINavigationBarDelegate {

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
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UINavigationBarDelegate setting
        navBar.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.eventBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.tenantIdBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.tenantNameBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
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
