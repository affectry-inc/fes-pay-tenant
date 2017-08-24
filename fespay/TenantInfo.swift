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
    var tenantUid: String = ""
    
    func clear() {
        eventId = ""
        eventName = ""
        tenantId = ""
        tenantName = ""
        tenantUid = ""
    }
    
    func store() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(eventId, forKey: "eventId")
        userDefaults.set(eventName, forKey: "eventName")
        userDefaults.set(tenantId, forKey: "tenantId")
        userDefaults.set(tenantName, forKey: "tenantName")
        userDefaults.set(tenantUid, forKey: "tenantUid")
    }

    func restore() -> Bool {
        let userDefaults = UserDefaults.standard
        if (userDefaults.string(forKey: "tenantId") != nil) {
            tenantId = userDefaults.string(forKey: "tenantId")!
            eventId = userDefaults.string(forKey: "eventId")!
            eventName = userDefaults.string(forKey: "eventName")!
            tenantName = userDefaults.string(forKey: "tenantName")!
            tenantUid = userDefaults.string(forKey: "tenantUid")!
            return true
        } else {
            return false
        }
    }
}
