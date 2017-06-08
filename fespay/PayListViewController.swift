//
//  PayListViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/08.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class PayListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate, UITabBarDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var historyTable: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tabBar: UITabBar!
    
    var payInfos = [PayInfo]()
    var tenantInfo = TenantInfo.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: set TenantInfo on login
        tenantInfo.fesId = "FES_A"
        tenantInfo.tenantId = "TENANT_A"
        
        // UITableViewDelegate setting
        historyTable.delegate = self
        
        // UITableViewDataSource setting
        historyTable.dataSource = self
        
        // UINavigationBarDelegate setting
        navBar.delegate = self
        
        tabBar.tintColor = primary1Color
        tabBar.selectedItem = tabBar.items?[0]
        tabBar.delegate = self
        
        loadSamplePayInfos()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UINavigationBarDelegate
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PayInfoTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PayInfoTableViewCell else {
            fatalError("The dequeued cell is not an instance of PayInfoTableViewCell.")
        }
        
        // Fetches the appropriate payInfo for the data source layout.
        let payInfo = payInfos[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        cell.paidAtLabel.text = dateFormatter.string(from: payInfo.paidAt!)
        cell.payerLabel.text = "ID: " + payInfo.bandId!
        cell.priceLabel.text = "¥" + String(format: "%.0f", payInfo.price!)
        
        return cell
    }
    
    // MARK: - TabBar delegate
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag{
        case 0:
            print("0")
        case 1:
            let next = self.storyboard?.instantiateViewController(withIdentifier: "NewPayNavigation") as! UINavigationController
            
            self.present(next, animated: true, completion: nil)
        case 2:
            print("2")
        default :
            return
        }
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToPayList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ConfirmViewController, let payInfo = sourceViewController.payInfo {
            
            // Add a new meal.
            let newIndexPath = IndexPath(row: payInfos.count, section: 0)
            
            payInfos.append(payInfo)
            historyTable.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSamplePayInfos() {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let payInfo1 = PayInfo()
        payInfo1.price = 2700
        payInfo1.bandId = "aa001"
        payInfo1.paidAt = Date()
        
        let payInfo2 = PayInfo()
        payInfo2.price = 1500
        payInfo2.bandId = "aa002"
        payInfo2.paidAt = Date()
        
        let payInfo3 = PayInfo()
        payInfo3.price = 3400
        payInfo3.bandId = "aa003"
        payInfo3.paidAt = Date()
        
        payInfos += [payInfo1, payInfo2, payInfo3]
        
    }

}
