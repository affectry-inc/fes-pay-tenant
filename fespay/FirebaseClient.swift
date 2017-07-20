//
//  FirebaseClient.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/07.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import Foundation
import os.log
import Firebase

class FirebaseClient: NSObject {
    
    class func findPerson(bandId: String, onFind: @escaping (String, String) -> ()) {
        let fbRef = Database.database().reference()
        fbRef.child("bands").child(bandId).observeSingleEvent(of: .value, with: { (snapshot) in
            let person = snapshot.value as? [String: Any]
            let persons = person?["persons"] as! [String: Bool]
            let personId = persons.first!.key
            let photoUrl = person?["photoUrl"] as! String
            os_log("personId: %@", log: .default, type: .debug, personId)
            os_log("photoUrl: %@", log: .default, type: .debug, photoUrl)
            
            onFind(personId, photoUrl)
        }) { (error) in
            os_log("findPerson error: %@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    class func findCardCustomer(bandId: String, onFind: @escaping (String, String) -> ()) {
        let fbRef = Database.database().reference()
        fbRef.child("bands").child(bandId).observeSingleEvent(of: .value, with: { (snapshot) in
            let band = snapshot.value as? [String: Any]
            let cardCustomerId = band?["cardCustomerId"] as! String
            let cardLastDigits = band?["cardLastDigits"] as! String
            os_log("cardCustomerId: %@", log: .default, type: .debug, cardCustomerId)
            os_log("cardLastDigits: %@", log: .default, type: .debug, cardLastDigits)
            
            onFind(cardCustomerId, cardLastDigits)
        }) { (error) in
            os_log("findCardCustomer error: %@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    class func createChargeKey() -> String {
        let fbRef = Database.database().reference()
        return fbRef.child("charges").childByAutoId().key
    }
    
    class func createCharge(_ payInfo: PayInfo, onCreate: @escaping () -> (), onError: @escaping () -> ()) {
        let tenantInfo = ShopInfo.sharedInstance
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let fbRef = Database.database().reference()
        let charge: [String: Any] = [
            "feses": [tenantInfo.fesId: true],
            "shops": [tenantInfo.shopId: true],
            "bands": [payInfo.bandId!: true],
            "amount": payInfo.price!,
            "persons": [payInfo.personId!: true],
            "personPhotoUrl": payInfo.personPhotoUrl!,
            "buyerPhotoUrl": payInfo.buyerPhotoUrl!,
            "confidence": payInfo.confidence!,
            "cardLastDigits": payInfo.cardLastDigits!,
            "paidAt": dateFormatter.string(from: payInfo.paidAt!),
            "chargeId": payInfo.chargeId!,
            "transactionId": payInfo.transactionId!
        ]
        let childUpdates = [
            "/charges/\(payInfo.key)": charge,
            "/pays/\(payInfo.bandId!)/\(payInfo.key)": charge
        ]
        fbRef.updateChildValues(childUpdates, withCompletionBlock: { error, _ in
            if error != nil {
                os_log("createCharge Error: %@", log: .default, type: .error, error! as CVarArg)
                onError()
                return
            }
            
            onCreate()
        })
    }
    
}
