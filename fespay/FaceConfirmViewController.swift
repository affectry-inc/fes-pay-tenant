//
//  FaceConfirmationViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/05/29.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class FaceConfirmViewController: UIViewController {

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
    
    // MARK: - Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        personImageView.image = self.payInfo?.personImage
        buyerImageView.image = self.payInfo?.buyerImage
        equalLabel.text = (self.payInfo?.verified())! ? "=" : "≠"
        confidenceValueLabel.text = "\(String(format: "%.1f", (self.payInfo?.confidence)!))%"
        wristbandValueLabel.text = self.payInfo?.bandId
        amountValueLabel.text = "¥" + String(format: "%.0f", (self.payInfo?.price)!)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.wristbandBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.amountBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
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
