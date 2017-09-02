//
//  StripeClient.swift
//  fespay
//
//  Created by Shizuka Kakimoto on 2017/07/31.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import Foundation
import os.log

class StripeClient: NSObject {
    
    private static let SKEY = env["STRIPE_SKEY"]!
    
    class func charge(customerId: String, amount: Double, onCharge: @escaping (Date, String, String) -> (), onError: @escaping () -> ()) {
        
        let tenantInfo = TenantInfo.sharedInstance
        
        var request = URLRequest(url: URL(string: "https://api.stripe.com/v1/charges")!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(SKEY)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "amount=\(Int(amount))&currency=jpy&customer=\(customerId)&description=\(tenantInfo.tenantId)".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            
            if error != nil {
                os_log("Card charge error: %@", log: .default, type: .error, error! as CVarArg)
                onError()
                return
            }
            
            let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]

            if jsonData["error"] != nil {
                os_log("Card charge error: %@", log: .default, type: .error, jsonData["error"] as! CVarArg)
                onError()
                return
            }

            let chargeId = jsonData["id"] as! String
            let transactionId = jsonData["balance_transaction"] as! String
            let dblPaidAt = jsonData["created"] as! Double
            let paidAt = NSDate(timeIntervalSince1970: dblPaidAt) as Date
            
            onCharge(paidAt, chargeId, transactionId)
        }
        task.resume()
        
    }
    
    class func refund(chargeId: String, onRefund: @escaping (Date, String) -> (), onError: @escaping () -> ()) {
        
        var request = URLRequest(url: URL(string: "https://api.stripe.com/v1/refunds")!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(SKEY)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "charge=\(chargeId)".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            
            if error != nil {
                os_log("Card refund error: %@", log: .default, type: .error, error! as CVarArg)
                onError()
                return
            }
            
            let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            
            if jsonData["error"] != nil {
                os_log("Card refund error: %@", log: .default, type: .error, jsonData["error"] as! CVarArg)
                onError()
                return
            }
            
            let refundId = jsonData["id"] as! String
            let dblRefundedAt = jsonData["created"] as! Double
            let refundedAt = NSDate(timeIntervalSince1970: dblRefundedAt) as Date
            
            onRefund(refundedAt, refundId)
        }
        task.resume()
        
    }
}
