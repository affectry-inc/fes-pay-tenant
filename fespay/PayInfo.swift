//
//  PayInfo.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/04/29.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class PayInfo {
    
    //MARK: Properties
    
    var key: String
    var payer: String
    var price: Double
    var paid_at: Date
    
    //MARK: Initialization
    
    init?(key: String, payer: String) {
        
        // Initialization should fail if the key is nil.
        if key == ""  {
            return nil
        }
        
        self.key = key
        self.payer = payer
        self.price = 0
        self.paid_at = Date()
        
    }
    
}
