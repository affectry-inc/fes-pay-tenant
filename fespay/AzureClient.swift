//
//  AzureClient.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/07.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import Foundation
import os.log

class AzureClient: NSObject {
    
    private static let END_POINT = "https://southeastasia.api.cognitive.microsoft.com/face/v1.0"
    private static let SUBSCRIPTION_KEY = "81d01ff9b1ec45c1abf3147b0444100f"
    
    class func detectFace(photoUrl: String, onDetect: @escaping (String, [[String:Any]]) -> ()) {
        var request = URLRequest(url: URL(string: END_POINT + "/detect")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(SUBSCRIPTION_KEY, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.httpBody = "{\"url\":\"\(photoUrl)\"}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            
            if error != nil {
                os_log("detectFace Error: %@", log: .default, type: .error, error! as CVarArg)
                return
            }
            
            let data = try! JSONSerialization.jsonObject(with: data!, options: []) as! [[String:Any]]
            
            onDetect(photoUrl, data)
        }
        task.resume()
    }
    
    class func verify(faceId: String, personGroupId: String, personId: String, onVerify: @escaping ([String:Any]) -> ()) {
        var request = URLRequest(url: URL(string: END_POINT + "/verify")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(SUBSCRIPTION_KEY, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.httpBody = "{\"faceId\":\"\(faceId)\",\"personGroupId\":\"\(personGroupId)\",\"personId\":\"\(personId)\"}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            
            if error != nil {
                os_log("verify Error: %@", log: .default, type: .error, error! as CVarArg)
                return
            }
            
            let veriRes = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            os_log("veriRes: %@", log: .default, type: .debug, veriRes)
            
            onVerify(veriRes)
        }
        task.resume()
    }
    
}
