//
//  OmiseClient.swift
//  fespay
//
//  Created by Shizuka Kakimoto on 2017/07/20.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import Foundation
import os.log

class OmiseClient: NSObject {
    
    private static let SKEY = env["OMISE_SKEY"] as! String
    private static let VERSION = env["OMISE_VERSION"] as! String
    
    class func charge(customerId: String, amount: Double, onCharge: @escaping (Date, String, String) -> (), onError: @escaping () -> ()) {
        
        let tenantInfo = TenantInfo.sharedInstance
        let skey = (SKEY + ":X").data(using: .utf8, allowLossyConversion: false)
        
        guard let encodedKey = skey?.base64EncodedString(options: .lineLength64Characters) else {
            os_log("Omise API key error", log: .default, type: .error)
            return
        }
        
        var request = URLRequest(url: URL(string: "https://api.omise.co/charges")!)
        request.httpMethod = "POST"
        request.addValue("Basic \(encodedKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(VERSION, forHTTPHeaderField: "Omise-Version")
        request.httpBody = "{\"amount\":\"\(Int(amount))\",\"currency\":\"jpy\",\"customer\":\"\(customerId)\",\"description\":\"\(tenantInfo.tenantId)\"}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            
            if error != nil {
                os_log("Card charge error: %@", log: .default, type: .error, error! as CVarArg)
                onError()
                return
            }
            
            let jsonData = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            let chargeId = jsonData["id"] as! String
            let transactionId = jsonData["transaction"] as! String
            let strPaidAt = jsonData["created"] as! String
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            let paidAt = formatter.date(from: strPaidAt)!
            
            onCharge(paidAt, chargeId, transactionId)
        }
        task.resume()

    }
    
}
