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
    
    func alert(titleKey: String, titleVals: Array<Any>? = nil, messageKey: String, messageVals: Array<Any>? = nil) -> UIAlertController {
        let title = (titleVals != nil) ? String(format: localize(key: titleKey), arguments: titleVals as! [CVarArg]) : localize(key: titleKey)
        let message = (messageVals != nil) ? String(format: localize(key: messageKey), arguments: messageVals as! [CVarArg]) : localize(key: messageKey)
        
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: { action -> Void in /* Do nothing */})
        alert.addAction(okAction)
        
        return alert
    }
    
    func actionSheet(titleKey: String, messageKey: String, action1Key: String, handler1: @escaping () -> ()) -> UIAlertController {
        let title = localize(key: titleKey)
        let message = localize(key: messageKey)
        
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: localize(key: action1Key), style: UIAlertActionStyle.destructive, handler: { (action: UIAlertAction!) in
            handler1()
        })
        alert.addAction(action1)
        
        let cancel = UIAlertAction(title: NSLocalizedString("cancel", tableName: "", comment: ""), style: .cancel, handler: { action in
            /* Do nothing. Just close. */
        })
        alert.addAction(cancel)
        
        return alert
    }
    
    class func localize(key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
