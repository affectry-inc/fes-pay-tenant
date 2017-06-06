//
//  TenantInfo.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/06.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import Foundation

class TenantInfo {
    
    //MARK: Properties
    
    var fesId: String
    var tenantId: String
    
    //MARK: Initialization
    
    init?(fesId: String, tenantId: String) {
        
        // Initialization should fail if the key is nil.
        if fesId == "" || tenantId == "" {
            return nil
        }
        
        self.fesId = fesId
        self.tenantId = tenantId
        
    }

}
