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
        let tenantInfo = TenantInfo.sharedInstance
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let fbRef = Database.database().reference()
        let charge: [String: Any] = [
            "events": [tenantInfo.eventId: true],
            "tenants": [tenantInfo.tenantId: true],
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
        
        let payCharge: [String: Any] = [
            "amount": payInfo.price!,
            "tenantName": tenantInfo.tenantName,
            "paidAt": dateFormatter.string(from: payInfo.paidAt!)
        ]
        
        let receiptCharge: [String: Any] = [
            "amount": payInfo.price!,
            "bandId": payInfo.bandId!,
            "paidAt": dateFormatter.string(from: payInfo.paidAt!)
        ]
        
        let childUpdates = [
            "/charges/\(payInfo.key)": charge,
            "/pays/\(payInfo.bandId!)/charges/\(payInfo.key)": payCharge,
            "/receipts/\(tenantInfo.tenantId)/charges/\(payInfo.key)": receiptCharge
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
    
    class func signInAsTenant(tenantId: String, password: String, onSignIn: @escaping () -> (), onError: @escaping () -> ()) {
        Auth.auth().signIn(withEmail: "\(tenantId)@fespay.io", password: password, completion: { user, error in
            if let error = error {
                os_log("signInAsTenant Error: %@", log: .default, type: .error, error as CVarArg)
                onError()
                return
            }
            
            if let user = user {
                let tenantInfo = TenantInfo.sharedInstance
                
                let fbRef = Database.database().reference()
                fbRef.child("tenants").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    let tenant = snapshot.value as? [String: Any]
                    
                    tenantInfo.eventId = tenant?["eventId"] as! String
                    tenantInfo.eventName = tenant?["eventName"] as! String
                    tenantInfo.tenantId = tenant?["id"] as! String
                    tenantInfo.tenantName = tenant?["name"] as! String
                    
                    onSignIn()
                }) { (error) in
                    os_log("findTenant error: %@", log: .default, type: .error, error.localizedDescription)
                    onError()
                }
            }
        })
    }
    
    class func signOut(onSignOut: @escaping () -> ()) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let tenantInfo = TenantInfo.sharedInstance
        tenantInfo.clear()
        
        onSignOut()
    }
    
}
