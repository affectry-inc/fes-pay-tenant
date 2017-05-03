//
//  fespayTests.swift
//  fespayTests
//
//  Created by KakimotoShizuka on 2017/04/22.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import XCTest
@testable import fespay

class fespayTests: XCTestCase {
    
    //MARK: PayInfo Class Tests    
    
    // Confirm that the PayInfo initializer returns a PayInfo object when passed valid parameters.
    func testPayInfoInitializationSucceeds() {
        
        // One price
        let onePricePayInfo = PayInfo.init(price: 1, paid_at: Date(), payer: "")
        XCTAssertNotNil(onePricePayInfo)
        
    }
    
    // Confirm that the Meal initialier returns nil when passed a negative rating or an empty name.
    func testPayInfoInitializationFails() {
        
        // Zero price
        let zeroPricePayInfo = PayInfo.init(price: 0, paid_at: Date(), payer: "")
        XCTAssertNil(zeroPricePayInfo)
        
    }
}
