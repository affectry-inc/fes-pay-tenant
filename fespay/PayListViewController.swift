//
//  PayListViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/08.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class PayListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let i18n = I18n(tableName: "PayListView")
    
    // MARK: - Properties
    
    @IBOutlet weak var summaryButton: UIButton!
    @IBOutlet weak var summaryTitleLabel: UILabel!
    @IBOutlet weak var summaryTotalLabel: UILabel!
    @IBOutlet weak var historyTable: UITableView!
    
    var payInfos = [PayInfo]()
    
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
        
        loadSamplePayInfos()
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
        
        cell.paidAtLabel.text = dateFormatter.string(from: payInfo.paidAt!)
        cell.payerLabel.text = "ID: " + payInfo.bandId!
        cell.amountLabel.text = "¥" + String(format: "%.0f", payInfo.amount!)
        
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToPayList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CompleteViewController, let payInfo = sourceViewController.payInfo {
            
            // Add a new payment
            let newIndexPath = IndexPath(row: payInfos.count, section: 0)
            
            payInfos.append(payInfo)
            historyTable.insertRows(at: [newIndexPath], with: .automatic)
        }
        
    }
    
    // MARK: - Private Methods
    
    private func loadSamplePayInfos() {
        let payInfo1 = PayInfo()
        payInfo1.amount = 2700
        payInfo1.bandId = "aa001"
        payInfo1.paidAt = Date()
        
        let payInfo2 = PayInfo()
        payInfo2.amount = 1500
        payInfo2.bandId = "aa002"
        payInfo2.paidAt = Date()
        
        let payInfo3 = PayInfo()
        payInfo3.amount = 3400
        payInfo3.bandId = "aa003"
        payInfo3.paidAt = Date()
        
        payInfos += [payInfo1, payInfo2, payInfo3]
        
    }

}
