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

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        cell.paidAtLabel.text = dateFormatter.string(from: payInfo.paid_at)
        cell.payerLabel.text = "ID: " + payInfo.payer
        cell.priceLabel.text = "¥" + String(format: "%.0f", payInfo.price)
        
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
        
        guard let payInfo1 = PayInfo(price: 100.11, paid_at: Date(), payer: "A0001") else {
            fatalError("Unable to instantiate payInfo1")
        }
        
        guard let payInfo2 = PayInfo(price: 200.22, paid_at: Date(), payer: "A0002") else {
            fatalError("Unable to instantiate payInfo2")
        }

        guard let payInfo3 = PayInfo(price: 300.33, paid_at: Date(), payer: "A0003") else {
            fatalError("Unable to instantiate payInfo3")
        }
        
        payInfos += [payInfo1, payInfo2, payInfo3]

    }

}
