//
//  FaceConfirmationViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/05/29.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class FaceConfirmViewController: UIViewController {

    let i18n = I18n(tableName: "FaceConfirmView")
    
    // MARK: - Properties
    
    var payInfo: PayInfo?
    
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
    @IBOutlet weak var execPayButton: UIButton!
    
    // MARK: - Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personImageView.image = self.payInfo?.personImage
        buyerImageView.image = self.payInfo?.buyerImage
        equalLabel.text = (self.payInfo?.verified())! ? "=" : "≠"
        confidenceValueLabel.text = "\(String(format: "%.1f", (self.payInfo?.confidence)!))%"
        wristbandValueLabel.text = self.payInfo?.bandId
        amountValueLabel.text = "¥" + String(format: "%.0f", (self.payInfo?.amount)!)
        
        if (self.payInfo?.verified())! {
            confidenceTitleLabel.textColor = .blue
            confidenceValueLabel.textColor = .blue
            execPayButton.isEnabled = true
        } else {
            confidenceTitleLabel.textColor = .red
            confidenceValueLabel.textColor = .red
            execPayButton.isEnabled = false
            execPayButton.backgroundColor = .lightGray
        }

        LoadingProxy.set(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = i18n.localize(key: "confirm")
        self.personImageLabel.text = i18n.localize(key: "personImage")
        self.buyerImageLabel.text = i18n.localize(key: "buyerImage")
        self.confidenceTitleLabel.text = i18n.localize(key: "confidence")
        self.wristbandTitleLabel.text = i18n.localize(key: "wristbandId")
        self.amountTitleLabel.text = i18n.localize(key: "amount")
        self.execPayButton.setTitle(i18n.localize(key: "execute"), for: .normal)
        self.execPayButton.setTitle(i18n.localize(key: "notexecutable"), for: .disabled)
        
        self.wristbandBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.amountBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func execPayButtonTapped(_ sender: UIButton) {
        self.payInfo?.amountCoupon = Double(0)
        self.payInfo?.amountCard = self.payInfo?.amount
        
        if let cardCustomerId = self.payInfo?.cardCustomerId {
            // カード登録あり
            LoadingProxy.on()
            StripeClient.charge(customerId: cardCustomerId, amount: (self.payInfo?.amount)!, onCharge: { paidAt, chargeId, transactionId in
                self.payInfo?.paidAt = paidAt
                self.payInfo?.chargeId = chargeId
                self.payInfo?.transactionId = transactionId
                
                FirebaseClient.createCharge(self.payInfo!, onCreate: {
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "CompleteView") as! CompleteViewController
                    
                    next.payInfo = self.payInfo
                    
                    self.present(next, animated: true, completion: nil)
                    LoadingProxy.off()
                }, onError: {
                    // TODO: 失敗した時の処理
                    LoadingProxy.off()
                })
            }, onError: {
                // TODO: 失敗した時の処理
                LoadingProxy.off()
            })
        } else {
            // カード登録なし
            self.present(self.i18n.alert(titleKey: "cardNotRegistered", messageKey: "informRegisterCard"), animated: true)
        }
    }
    
    //MARK: - Actions
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
