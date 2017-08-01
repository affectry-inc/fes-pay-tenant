//
//  TenantInfo.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/06.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import Foundation

class TenantInfo: NSObject {
    
    // Singleton (Unique on app)
    static let sharedInstance = TenantInfo()
    
    //MARK: Properties
    
    var eventId: String = ""
    var eventName: String = ""
    var tenantId: String = ""
    var tenantName: String = ""
    
    func clear() {
        eventId = ""
        eventName = ""
        tenantId = ""
        tenantName = ""
    }

}
