//
//  PayListViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/08.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit
import os.log

class PayListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let i18n = I18n(tableName: "PayListView")
    let tenantInfo = TenantInfo.sharedInstance
    
    // MARK: - Properties
    
    @IBOutlet weak var summaryButton: UIButton!
    @IBOutlet weak var summaryTitleLabel: UILabel!
    @IBOutlet weak var summaryTotalLabel: UILabel!
    @IBOutlet weak var historyTable: UITableView!
    
    var payInfos = [PayInfo]()
    var totalAmount = Double(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UITableViewDelegate setting
        historyTable.delegate = self
        
        // UITableViewDataSource setting
        historyTable.dataSource = self
        
        // Navigation bar setting
        navigationItem.titleView = UIImageView(image: UIImage(named: "logoWordWhite"))

        // Summary button setting
        summaryButton.layer.borderWidth = 1;
        summaryButton.layer.borderColor = UIColor.lightGray.cgColor
        
        // History table setting
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: 0, width:  historyTable.frame.size.width, height: width)
        border.borderWidth = width
        historyTable.layer.addSublayer(border)
        
        loadOrders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        summaryTitleLabel.text = "\(i18n.localize(key: "total"))(\(i18n.localize(key: "today")))"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let refundedText = payInfo.isRefunded ? ("  " + i18n.localize(key: "refunded")) : ""
        
        cell.paidAtLabel.text = dateFormatter.string(from: payInfo.paidAt!)
        cell.payerLabel.text = "ID: " + payInfo.bandId!
        cell.amountLabel.text = "¥" + String(format: "%.0f", payInfo.amount!) + refundedText
        
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToPayList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CompleteViewController, let payInfo = sourceViewController.payInfo {
            
            // Add a new payment
            let newIndexPath = IndexPath(row: 0, section: 0)
            
            payInfos.insert(payInfo, at: 0)
            historyTable.insertRows(at: [newIndexPath], with: .automatic)
            
            self.totalAmount += payInfo.amount!
            self.summaryTotalLabel.text = String(format: "%.0f", totalAmount)
        } else if let sourceViewController = sender.source as? PayDetailViewController, let payInfo = sourceViewController.payInfo {
            if let selectedIndexPath = historyTable.indexPathForSelectedRow {
                payInfos[selectedIndexPath.row] = payInfo
                historyTable.reloadRows(at: [selectedIndexPath], with: .none)
            }
        }
        
    }
    
    // MARK: - Private Methods
    
    private func loadOrders() {
        FirebaseClient.loadReceiptSummaries(tenantId: tenantInfo.tenantId, onLoad: { summaries in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            let dateKey = dateFormatter.string(from: Date())
            
            if let summary = summaries?[dateKey] as? [String: Any] {
                self.totalAmount = summary["totalAmount"] as! Double
            }
            
            self.summaryTotalLabel.text = "¥ " + String(format: "%.0f", self.totalAmount)
        })
        
        FirebaseClient.loadOrders(tenantId: tenantInfo.tenantId, onLoad: { snapshots in
            for childSnapshot in snapshots {
                let charge = childSnapshot.value as! [String: Any]

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                formatter.timeZone = TimeZone(secondsFromGMT: 0)

                let payInfo = PayInfo()
                payInfo.key = childSnapshot.key
                payInfo.amount = charge["amount"] as? Double
                payInfo.bandId = charge["bandId"] as? String
                payInfo.paidAt = formatter.date(from: charge["paidAt"] as! String)
                payInfo.isRefunded = charge["isRefunded"] != nil && charge["isRefunded"] as! Bool
                
                self.payInfos.insert(payInfo, at: 0)
            }
            self.historyTable.reloadData()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "DetailsView":
            guard let detailsView = segue.destination as? PayDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedCell = sender as? PayInfoTableViewCell else {
                fatalError("Unexpected sender: \(sender!)")
            }
            
            guard let indexPath = historyTable.indexPath(for: selectedCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedPayInfo = payInfos[indexPath.row]
            
            detailsView.payInfo = selectedPayInfo
            
        default:
            // fatalError("Unexpected Segue Identifier: \(segue.identifier!)")
            break
        }
    }

}
