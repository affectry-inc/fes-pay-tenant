//
//  FaceConfirmationViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/05/29.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class FaceConfirmViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    
    var payInfo: PayInfo?
    
    @IBOutlet weak var registeredImage: UIImageView!
    @IBOutlet weak var capturedImage: UIImageView!
    @IBOutlet weak var equalLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var summaryTable: UITableView!
    
    // MARK: - Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegate設定
        summaryTable.delegate = self
        
        // DataSource設定
        summaryTable.dataSource = self

        capturedImage.image = self.payInfo?.buyerImage
        registeredImage.image = self.payInfo?.personImage
        confidenceLabel.text = "\(String(format: "%.1f", (self.payInfo?.confidence)!))%"
        equalLabel.text = (self.payInfo?.verified())! ? "=" : "≠"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func execPayButtonTapped(_ sender: UIButton) {
        if (execPayment()) {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "CompleteView") as! CompleteViewController
            
            next.payInfo = self.payInfo
            
            self.present(next, animated: true, completion: nil)
        } else {
            // TODO: 失敗した時の処理
        }
        
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを作る
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        if (indexPath.row == 0) {
            cell.textLabel?.text = "ID"
            cell.detailTextLabel?.text = self.payInfo?.bandId
        }
        else if (indexPath.row == 1) {
            cell.textLabel?.text = "金額"
            cell.detailTextLabel?.text = "¥" + String(format: "%.0f", (self.payInfo?.price)!)
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
    
    //MARK: - Actions
    
    func execPayment() -> Bool {
        // TODO: Firebaseに保存&決済実行
        self.payInfo?.paidAt = Date()
        
        return true
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
