//
//  PayInfoTableViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/04/29.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class PayInfoTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var payInfos = [PayInfo]()
    var tenantInfo = TenantInfo.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: set TenantInfo on login
        tenantInfo.fesId = "FES_A"
        tenantInfo.tenantId = "TENANT_A"
        
        loadSamplePayInfos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payInfos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Actions
    
    @IBAction func unwindToTop(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ConfirmViewController, let payInfo = sourceViewController.payInfo {
            
            // Add a new meal.
            let newIndexPath = IndexPath(row: payInfos.count, section: 0)
            
            payInfos.append(payInfo)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
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
