//
//  PayDetailViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/12.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class PayDetailViewController: UIViewController {

    let i18n = I18n(tableName: "PayDetailView")
    
    var chargeKey: String?
    var chargeId: String?
    var bandId: String?
    var isRefunded: Bool?
    
    // MARK: - Properties
    @IBOutlet weak var personImageLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var buyerImageLabel: UILabel!
    @IBOutlet weak var buyerImageView: UIImageView!
    @IBOutlet weak var equalLabel: UILabel!
    @IBOutlet weak var confidenceTitleLabel: UILabel!
    @IBOutlet weak var confidenceValueLabel: UILabel!
    @IBOutlet weak var wristbandBorderLabel: UILabel!
    @IBOutlet weak var wristbandTitleLabel: UILabel!
    @IBOutlet weak var wristbandValueLabel: UILabel!
    @IBOutlet weak var amountBorderLabel: UILabel!
    @IBOutlet weak var amountTitleLabel: UILabel!
    @IBOutlet weak var amountValueLabel: UILabel!
    @IBOutlet weak var dateBorderLabel: UILabel!
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var dateValueLabel: UILabel!
    @IBOutlet weak var refundButton: UIButton!
    
    @IBAction func refundButtonTapped(_ sender: UIButton) {
        let actionSheet = i18n.actionSheet(titleKey: "caution", messageKey: "msgSureToRefund", action1Key: "execRefund") {
            StripeClient.refund(chargeId: self.chargeId!, onRefund: { refundedAt, refundId in
                FirebaseClient.refundCharge(key: self.chargeKey!, bandId: self.bandId!, refundedAt: refundedAt, refundId: refundId, onRefund: {
                    self.present(self.i18n.alert(titleKey: "titleRefundSuccess", messageKey: "msgRefundSuccess"), animated: true)
                    
                    self.refundButton.isEnabled = false
                    self.refundButton.alpha = 0.2
                }, onError: {
                    self.present(self.i18n.alert(titleKey: "titleRefundIncomplete", messageKey: "msgRefundIncomplete"), animated: true)
                })
            }, onError: {
                self.present(self.i18n.alert(titleKey: "titleRefundFailure", messageKey: "msgRefundFailure"), animated: true)
            })
        }
        
        present(actionSheet, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FirebaseClient.findCharge(key: chargeKey!, onLoad: { charge in
            
            self.chargeId = charge["chargeId"] as? String
            self.bandId = charge["bandId"] as? String
            self.isRefunded = charge["isRefunded"] != nil && charge["isRefunded"] as! Bool
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            let paidAtDate = formatter.date(from: charge["paidAt"] as! String)
            formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            
            let personImageData = try? Data(contentsOf: URL(string: charge["personPhotoUrl"] as! String)!, options: .mappedIfSafe)
            let buyerImageData = try? Data(contentsOf: URL(string: charge["buyerPhotoUrl"] as! String)!, options: .mappedIfSafe)
            
            self.personImageView.image = UIImage(data: personImageData!)
            self.buyerImageView.image = UIImage(data: buyerImageData!)
            self.confidenceValueLabel.text = "\(String(format: "%.1f", charge["confidence"] as! Double))%"
            self.wristbandValueLabel.text = self.bandId
            self.amountValueLabel.text = "¥" + String(format: "%.0f", charge["amount"] as! Double)
            self.dateValueLabel.text = formatter.string(from: paidAtDate!)
            if self.isRefunded! {
                self.refundButton.isEnabled = false
                self.refundButton.alpha = 0.2
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = i18n.localize(key: "details")
        self.personImageLabel.text = i18n.localize(key: "personImage")
        self.buyerImageLabel.text = i18n.localize(key: "buyerImage")
        self.confidenceTitleLabel.text = i18n.localize(key: "confidence")
        self.wristbandTitleLabel.text = i18n.localize(key: "wristbandId")
        self.amountTitleLabel.text = i18n.localize(key: "amount")
        self.dateTitleLabel.text = i18n.localize(key: "date")
        self.refundButton.setTitle(self.i18n.localize(key: "refund"), for: .normal)
        self.refundButton.setTitle(self.i18n.localize(key: "refunded"), for: .disabled)
        
        self.wristbandBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.amountBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.dateBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
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
