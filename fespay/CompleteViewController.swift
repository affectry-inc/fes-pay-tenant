//
//  CompleteViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/05/29.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class CompleteViewController: UIViewController, UINavigationBarDelegate {

    let i18n = I18n(tableName: "CompleteView")
    
    // MARK: - Properties
    
    var payInfo: PayInfo?
    
    @IBOutlet weak var navBar: UINavigationBar!
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
    @IBOutlet weak var backToTopButton: UIButton!
    
    // MARK: - Events
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UINavigationBarDelegate setting
        navBar.delegate = self
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        personImageView.image = self.payInfo?.personImage
        buyerImageView.image = self.payInfo?.buyerImage
        equalLabel.text = (self.payInfo?.verified())! ? "=" : "≠"
        confidenceValueLabel.text = "\(String(format: "%.1f", (self.payInfo?.confidence)!))%"
        wristbandValueLabel.text = self.payInfo?.bandId
        amountValueLabel.text = "¥" + String(format: "%.0f", (self.payInfo?.price)!)
        dateValueLabel.text = dateFormatter.string(from: (self.payInfo?.paidAt)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navBar.topItem?.title = i18n.localize(key: "complete")
        self.personImageLabel.text = i18n.localize(key: "personImage")
        self.buyerImageLabel.text = i18n.localize(key: "buyerImage")
        self.confidenceTitleLabel.text = i18n.localize(key: "confidence")
        self.wristbandTitleLabel.text = i18n.localize(key: "wristbandId")
        self.amountTitleLabel.text = i18n.localize(key: "amount")
        self.dateTitleLabel.text = i18n.localize(key: "date")
        self.backToTopButton.setTitle(i18n.localize(key: "backToTop"), for: .normal)
        
        self.wristbandBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.amountBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        self.dateBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UINavigationBarDelegate
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
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
