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
    var price: Double?
    var personId: String?
    var personPhotoUrl: String?
    var personImage: UIImage?
    var buyerPhotoUrl: String?
    var buyerImage: UIImage?
    var paidAt: Date?
    var confidence: Double?
    
    //MARK: Initialization
    
    override init() {
        self.key = FirebaseClient.createPayKey()
    }
    
    func verified() -> Bool {
        return confidence != nil && confidence! > 50.0
    }
    
}
