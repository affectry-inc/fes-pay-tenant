//
//  PayInfo.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/04/29.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class PayInfo: NSObject {
    
    //MARK: Properties
    
    var key: String
    var bandId: String?
    var bandUid: String?
    var amount: Double?
    var amountCoupon: Double?
    var amountCard: Double?
    var personId: String?
    var personPhotoUrl: String?
    var personImage: UIImage?
    var buyerPhotoUrl: String?
    var buyerImage: UIImage?
    var confidence: Double?
    var cardLastDigits: String?
    var cardCustomerId: String?
    var paidAt: Date?
    var chargeId: String?
    var transactionId: String?
    var isRefunded: Bool = false
    var refundedAt: Date?
    
    //MARK: Initialization
    
    override init() {
        self.key = FirebaseClient.createChargeKey()
    }
    
    func verified() -> Bool {
        return confidence != nil && confidence! > 50.0
    }
    
    func dispConfidence() -> String {
        if let val = confidence {
            return String(format: "%.1f", val)
        } else {
            return "--.-"
        }
    }
}
