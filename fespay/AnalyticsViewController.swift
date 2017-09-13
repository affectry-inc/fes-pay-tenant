//
//  AnalyticsViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/09.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class AnalyticsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let i18n = I18n(tableName: "AnalyticsView")
    let tenantInfo = TenantInfo.sharedInstance
    var summaryList: [String: [String: Double]] = [:]
    var dateList: [String] = []
    
    // MARK: - Properties
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var tenantNameLabel: UILabel!
    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var totalTitleLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var totalBorderLabel: UILabel!
    @IBOutlet weak var countTitleLabel: UILabel!
    @IBOutlet weak var countValueLabel: UILabel!
    @IBOutlet weak var countBorderLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.delegate = self
        datePicker.dataSource = self
        
        FirebaseClient.loadReceiptSummaries(tenantId: tenantInfo.tenantId, onLoad: { summaries in
            if (summaries != nil) {
                var list: [String] = []
                for summary in summaries! {
                    let date = summary.key.replacingOccurrences(of: "-", with: "/")
                    self.summaryList[date] = summary.value as? [String: Double]
                    list.append(date)
                }
                
                self.dateList = list.sorted()
                self.datePicker.reloadAllComponents()
                self.datePicker.selectRow(self.dateList.count-1, inComponent: 0, animated: true)
                self.dispSummary(row: self.dateList.count-1)
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = i18n.localize(key: "analytics")
        self.totalTitleLabel.text = i18n.localize(key: "total")
        self.countTitleLabel.text = i18n.localize(key: "count")
        
        self.eventNameLabel.text = tenantInfo.eventName
        self.tenantNameLabel.text = "\(tenantInfo.tenantName)(\(tenantInfo.tenantId))"
    }

    override func viewDidAppear(_ animated: Bool) {
        self.totalBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.countBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dispSummary(row: Int) {
        if (summaryList.count > 0) {
            let summary = summaryList[dateList[row]]!
            totalValueLabel.text =  summary["totalAmount"]?.toJPY()
            countValueLabel.text = String(format: "%.0f", summary["totalCount"]!)
        }
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dateList.count
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dateList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dispSummary(row: row)
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
