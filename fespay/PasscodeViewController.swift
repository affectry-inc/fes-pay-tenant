//
//  PasscodeViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/05/04.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit
import os.log

class PasscodeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    
    @IBOutlet weak var passcodeTextField: UITextField!
    @IBOutlet weak var settleButton: UIButton!
    @IBOutlet weak var summaryTable: UITableView!
    
    // var payInfo: PayInfo?
    var price: Double?
    var payer: String?
    
    // MARK: - Events
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        updateSettleButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        passcodeTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate設定
        summaryTable.delegate = self
        
        // DataSource設定
        summaryTable.dataSource = self

        updateSettleButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを作る
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        if (indexPath.row == 0) {
            cell.textLabel?.text = "ID"
            cell.detailTextLabel?.text = self.payer
        }
        else if (indexPath.row == 1) {
            cell.textLabel?.text = "金額"
            cell.detailTextLabel?.text = "¥" + String(format: "%.0f", self.price!)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // セルの数を設定
        return 2
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // セルの高さを設定
        return 50
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ConfirmView" {
            guard
                let navCon = segue.destination as? UINavigationController,
                let confirmView = navCon.topViewController as? ConfirmViewController
            else {
                os_log("The destination is not a ConfirmView", log: OSLog.default, type: .debug)
                return
            }
            
            let payInfo = PayInfo(key: self.payer!, payer: self.payer!)
            payInfo?.price = self.price!
            payInfo?.paid_at = Date()
            confirmView.payInfo = payInfo
        }
    }
    
    // MARK: - Private Methods
    
    private func updateSettleButtonState() {
        // Disable the Pay button if the text field is empty.
        let text = passcodeTextField.text ?? ""
        settleButton.isEnabled = text.characters.count == 4
    }

}
