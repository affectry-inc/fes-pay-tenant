//
//  I18n.swift
//  fespay
//
//  Created by Shizuka Kakimoto on 2017/06/20.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import Foundation

class I18n: NSObject {
    
    var tableName: String
    
    //MARK: Initialization
    
    init(tableName: String) {
        self.tableName = tableName
    }
    
    func localize(key: String) -> String {
        return NSLocalizedString(key, tableName: self.tableName, comment: "")
    }
}
