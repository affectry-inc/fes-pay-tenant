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
    
    var price: Double
    var paid_at: Date
    var payer: String
    
    //MARK: Initialization
    
    init?(price: Double, paid_at: Date, payer: String) {
        
        // Initialization should fail if the price is zero or negative.
        if price <= 0  {
            return nil
        }
        
        self.price = price
        self.paid_at = paid_at
        self.payer = payer
        
    }
    
}
