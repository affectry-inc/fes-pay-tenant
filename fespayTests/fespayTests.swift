//
//  fespayTests.swift
//  fespayTests
//
//  Created by KakimotoShizuka on 2017/04/22.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import XCTest
@testable import FesPay

class fespayTests: XCTestCase {
    
    //MARK: PayInfo Class Tests    
    
    // Confirm that the PayInfo initializer returns a PayInfo object when passed valid parameters.
    func testPayInfoInitializationSucceeds() {
        
        // One amount
        let oneAmountPayInfo = PayInfo.init()
        XCTAssertNotNil(oneAmountPayInfo)
        
    }
    
    // Confirm that the Meal initialier returns nil when passed a negative rating or an empty name.
    func testPayInfoInitializationFails() {
        
        // Zero amount
        let zeroAmountPayInfo = PayInfo.init()
        XCTAssertNil(zeroAmountPayInfo)
        
    }
}
