//
//  AnalyticsViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/09.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class AnalyticsViewController: UIViewController {

    let i18n = I18n(tableName: "AnalyticsView")
    let tenantInfo = TenantInfo.sharedInstance
    
    // MARK: - Properties
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var tenantNameLabel: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var totalBorderLabel: UILabel!
    @IBOutlet weak var countTitleLabel: UILabel!
    @IBOutlet weak var countValueLabel: UILabel!
    @IBOutlet weak var countBorderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = i18n.localize(key: "analytics")
        self.totalTitleLabel.text = i18n.localize(key: "total")
        self.countTitleLabel.text = i18n.localize(key: "count")
        
        self.totalBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.countBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        
        self.eventNameLabel.text = tenantInfo.eventName
        self.tenantNameLabel.text = "\(tenantInfo.tenantName)(\(tenantInfo.tenantId))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
