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
    
    class func findPerson(bandId: String, onFind: @escaping (String, String, String, String?, String?) -> ()) {
        let fbRef = Database.database().reference()
        fbRef.child("bands").child(bandId).observeSingleEvent(of: .value, with: { (snapshot) in
            let band = snapshot.value as? [String: Any]
            let persons = band?["persons"] as! [String: Bool]
            let personId = persons.first!.key
            let photoUrl = band?["photoUrl"] as! String
            let cardCustomerId = band?["cardCustomerId"] as? String
            let cardLastDigits = band?["cardLastDigits"] as? String
            let uid = band?["uid"] as! String
            os_log("personId: %@", log: .default, type: .debug, personId)
            os_log("photoUrl: %@", log: .default, type: .debug, photoUrl)
            
            onFind(personId, photoUrl, uid, cardCustomerId, cardLastDigits)
        }) { (error) in
            os_log("findPerson error: %@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    class func createChargeKey() -> String {
        let fbRef = Database.database().reference()
        return fbRef.child("charges").childByAutoId().key
    }
    
//    クーポン対応は中断 2017/08/28
//    class func couponCharge(bandId: String, amount: Double, onCharge: @escaping (Double, Double) -> (), onError: @escaping () -> ()) {
//        let fbRef = Database.database().reference()
//        fbRef.child("coupons").child(bandId).observeSingleEvent(of: .value, with: { (snapshot) in
//            if (!snapshot.exists()) {
//                onCharge(0, amount)
//            } else {
//                let coupon = snapshot.value as! [String: Any]
//                let couponAmount = coupon["amount"] as! Double
//                let couponAmountUsed = (coupon["amountUsed"] != nil) ? coupon["amountUsed"] as! Double : Double(0)
//                os_log("couponAmount: %d", log: .default, type: .debug, couponAmount)
//                os_log("couponAmountUsed: %d", log: .default, type: .debug, couponAmountUsed)
//                
//                let couponBalance = couponAmount - couponAmountUsed
//                var amountCoupon: Double, amountCard: Double
//                if (couponBalance <= 0) {
//                    amountCoupon = 0
//                    amountCard = amount
//                } else if (couponBalance <= amount) {
//                    amountCoupon = couponBalance
//                    amountCard = amount - couponBalance
//                } else { // if (couponBalance > amount)
//                    amountCoupon = amount
//                    amountCard = 0
//                }
//                
//                if (amountCoupon > 0) {
//                    fbRef.child("coupons/\(bandId)/amountUsed").setValue(couponAmountUsed + amountCoupon)
//                }
//                
//                onCharge(amountCoupon, amountCard)
//            }
//            
//        }) { (error) in
//            os_log("couponCharge error: %@", log: .default, type: .error, error.localizedDescription)
//        }
//    }
    
    class func createCharge(_ payInfo: PayInfo, onCreate: @escaping () -> (), onError: @escaping () -> ()) {
        let tenantInfo = TenantInfo.sharedInstance
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let fbRef = Database.database().reference()
        let charge: [String: Any] = [
            "events": [tenantInfo.eventId: true],
            "tenantId": tenantInfo.tenantId,
            "tenantUid": tenantInfo.tenantUid,
            "bandId": payInfo.bandId!,
            "bandUid": payInfo.bandUid!,
            "amount": payInfo.amount!,
            "amountCard": payInfo.amountCard!,
            // "amountCoupon": payInfo.amountCoupon!,
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
            "amount": payInfo.amount!,
            "amountCard": payInfo.amountCard!,
            // "amountCoupon": payInfo.amountCoupon!,
            "cardLastDigits": payInfo.cardLastDigits!,
            "tenantUid": tenantInfo.tenantUid,
            "tenantName": tenantInfo.tenantName,
            "paidAt": dateFormatter.string(from: payInfo.paidAt!)
        ]
        
        let receiptCharge: [String: Any] = [
            "amount": payInfo.amount!,
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
    
    class func loadReceiptSummaries(tenantId: String, onLoad: @escaping ([String: Double]) -> ()) {
        let refSum = Database.database().reference().child("receipts/\(tenantId)/summary")
        refSum.observeSingleEvent(of: .value, with: { snapshot in
            let summaries = snapshot.value as! [String: Double]
            
            onLoad(summaries)
        })
    }
    
    class func loadOrders(tenantId: String, onLoad: @escaping ([DataSnapshot]) -> ()) {
        let refCharges = Database.database().reference().child("receipts/\(tenantId)/charges")
        refCharges.queryOrdered(byChild: "paidAt").observeSingleEvent(of: .value, with: { snapshot in
            onLoad(snapshot.children.allObjects as! [DataSnapshot])
        })
    }
    
    class func signInAsTenant(tenantId: String, password: String, onSignIn: @escaping () -> (), onError: @escaping () -> ()) {
        Auth.auth().signIn(withEmail: "\(tenantId)@tenant.fespay.io", password: password, completion: { user, error in
            if let error = error {
                os_log("signInAsTenant Error: %@", log: .default, type: .error, error as CVarArg)
                onError()
                return
            }
            
            if let user = user {
                setTenantInfo(user: user, onSuccess: onSignIn, onError: onError)
            }
        })
    }
    
    class func setTenantInfo(user: User, onSuccess: @escaping () -> (), onError: @escaping () -> ()) {
        let tenantInfo = TenantInfo.sharedInstance
        
        let fbRef = Database.database().reference()
        let tenantId = user.email?.components(separatedBy: "@")[0]
        fbRef.child("tenants").child(tenantId!).observeSingleEvent(of: .value, with: { (snapshot) in
            let tenant = snapshot.value as? [String: Any]
            
            tenantInfo.eventId = tenant?["eventId"] as! String
            tenantInfo.eventName = tenant?["eventName"] as! String
            tenantInfo.tenantId = tenantId!
            tenantInfo.tenantName = tenant?["name"] as! String
            tenantInfo.tenantUid = user.uid
            tenantInfo.store()
            
            onSuccess()
        }) { (error) in
            os_log("findTenant error: %@", log: .default, type: .error, error.localizedDescription)
            onError()
        }
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
    
    class func findCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
    
}
