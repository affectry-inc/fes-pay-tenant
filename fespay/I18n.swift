//
//  I18n.swift
//  fespay
//
//  Created by Shizuka Kakimoto on 2017/06/20.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import Foundation
import UIKit

class I18n: NSObject {
    
    var tableName: String
    
    //MARK: Initialization
    
    init(tableName: String) {
        self.tableName = tableName
    }
    
    func localize(key: String) -> String {
        return NSLocalizedString(key, tableName: self.tableName, comment: "")
    }
    
    func alert(titleKey: String, messageKey: String) -> UIAlertController {
        let title = localize(key: titleKey)
        let message = localize(key: messageKey)
        
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: { action -> Void in /* Do nothing */})
        alert.addAction(okAction)
        
        return alert
    }
    
    class func localize(key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
