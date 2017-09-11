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
    
    var payInfo: PayInfo?
    var isNewRefunded = false
    
    // MARK: - Properties
    @IBOutlet weak var backButton: UIBarButtonItem!
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
        let actionSheet = i18n.actionSheet(titleKey: "caution", messageKey: "msgSureToRefund", action1Key: "execRefund", handler1: {
            LoadingProxy.on()
            StripeClient.refund(chargeId: (self.payInfo?.chargeId)!, onRefund: { refundedAt, refundId in
                FirebaseClient.refundCharge(payInfo: self.payInfo!, refundedAt: refundedAt, refundId: refundId, onRefund: {
                    self.payInfo?.isRefunded = true
                    self.payInfo?.refundedAt = refundedAt
                    self.isNewRefunded = true
                    
                    LoadingProxy.off()
                    
                    self.present(self.i18n.alert(titleKey: "titleRefundSuccess", messageKey: "msgRefundSuccess"), animated: true)
                    
                    self.refundButton.isEnabled = false
                    self.refundButton.alpha = 0.2
                }, onError: {
                    LoadingProxy.off()
                    
                    self.present(self.i18n.alert(titleKey: "titleRefundIncomplete", messageKey: "msgRefundIncomplete"), animated: true)
                })
            }, onError: {
                LoadingProxy.off()
                self.present(self.i18n.alert(titleKey: "titleRefundFailure", messageKey: "msgRefundFailure"), animated: true)
            })
        })
        
        present(actionSheet, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadingProxy.set(self)
        
        LoadingProxy.on()
        FirebaseClient.findCharge(key: payInfo!.key, onLoad: { charge in
            
            self.payInfo?.chargeId = charge["chargeId"] as? String
            self.payInfo?.personPhotoUrl = charge["personPhotoUrl"] as? String
            self.payInfo?.buyerPhotoUrl = charge["buyerPhotoUrl"] as? String
            self.payInfo?.personImage = UIImage(data: try! Data(contentsOf: URL(string: (self.payInfo?.personPhotoUrl)!)!, options: .mappedIfSafe))
            self.payInfo?.buyerImage = UIImage(data: try! Data(contentsOf: URL(string: (self.payInfo?.buyerPhotoUrl)!)!, options: .mappedIfSafe))
            self.payInfo?.confidence = charge["confidence"] as? Double
            
            self.personImageView.image = self.payInfo?.personImage
            self.buyerImageView.image = self.payInfo?.buyerImage
            self.confidenceValueLabel.text = self.payInfo?.dispConfidence()
            self.wristbandValueLabel.text = self.payInfo?.bandId
            self.amountValueLabel.text = self.payInfo?.amount?.toJPY()
            self.dateValueLabel.text = self.payInfo?.paidAt?.toTokyoTime()
            if (self.payInfo?.isRefunded)! {
                self.refundButton.isEnabled = false
                self.refundButton.alpha = 0.2
            }
            
            LoadingProxy.off()
        })
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = i18n.localize(key: "details")
        self.backButton.title = i18n.localize(key: "back")
        self.personImageLabel.text = i18n.localize(key: "personImage")
        self.buyerImageLabel.text = i18n.localize(key: "buyerImage")
        self.confidenceTitleLabel.text = i18n.localize(key: "confidence")
        self.wristbandTitleLabel.text = i18n.localize(key: "wristbandId")
        self.amountTitleLabel.text = i18n.localize(key: "amount")
        self.dateTitleLabel.text = i18n.localize(key: "date")
        self.refundButton.setTitle(self.i18n.localize(key: "refund"), for: .normal)
        self.refundButton.setTitle(self.i18n.localize(key: "refunded"), for: .disabled)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
