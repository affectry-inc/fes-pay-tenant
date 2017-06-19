//
//  ShopInfo.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/06.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import Foundation

class ShopInfo: NSObject {
    
    // Singleton (Unique on app)
    static let sharedInstance = ShopInfo()
    
    //MARK: Properties
    
    var fesId: String = ""
    var shopId: String = ""

}
