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
    
    class func isActiveBand(bandId: String, onActive: @escaping () -> (), onNotActive: @escaping () -> (), onError: @escaping () -> ()) {
        let fbRef = Database.database().reference()
        fbRef.child("bands").child(bandId).observeSingleEvent(of: .value, with: { snapshot in
            if let band = snapshot.value as? [String: Any], let isActive = band["isActive"] as? Bool {
                isActive && band["cardCustomerId"] != nil ? onActive() : onNotActive()
            } else {
                onNotActive()
            }
        }) { (error) in
            os_log("isActiveBand error: %@", log: .default, type: .error, error.localizedDescription)
            onError()
        }
    }
    
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
            
            summarizePay(bandId: payInfo.bandId!, amount: payInfo.amount!)
            summarizeReceipt(tenantId: tenantInfo.tenantId, date: payInfo.paidAt!, amount: payInfo.amount!)
            
            onCreate()
        })
    }
    
    class func summarizePay(bandId: String, amount: Double) {
        let fbRef = Database.database().reference()
        fbRef.child("pays/\(bandId)/summary").observeSingleEvent(of: .value, with: { (snapshot) in
            let summary = snapshot.value as? [String: Any]
            let oldTotalAmount = summary?["totalAmount"] != nil ? summary?["totalAmount"] as! Double : Double(0)
            
            fbRef.child("pays/\(bandId)/summary/totalAmount").setValue(oldTotalAmount + amount)
        }) { (error) in
            os_log("summaryPay error: %@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    class func summarizeReceipt(tenantId: String, date: Date, amount: Double) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let dateKey = dateFormatter.string(from: date)
        
        let fbRef = Database.database().reference()
        fbRef.child("receipts/\(tenantId)/summaries/\(dateKey)").observeSingleEvent(of: .value, with: { (snapshot) in
            var oldTotalAmount = Double(0)
            var oldTotalCount = Double(0)
            
            if let summary = snapshot.value as? [String: Any] {
                oldTotalAmount = summary["totalAmount"] as! Double
                oldTotalCount = summary["totalCount"] as! Double
            }
            
            let updates = [
                "totalAmount": oldTotalAmount + amount,
                "totalCount": amount < 0 ? oldTotalCount - 1 : oldTotalCount + 1,
            ]
            
            fbRef.child("receipts/\(tenantId)/summaries/\(dateKey)").updateChildValues(updates, withCompletionBlock: { error, _ in
                if error != nil {
                    os_log("summaryReceipt Error: %@", log: .default, type: .error, error! as CVarArg)
                }
            })
        }) { (error) in
            os_log("summaryReceipt error: %@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    class func refundCharge(payInfo: PayInfo, refundedAt: Date, refundId: String, onRefund: @escaping () -> (), onError: @escaping () -> ()) {
        let tenantInfo = TenantInfo.sharedInstance
        
        let key = payInfo.key
        let bandId = payInfo.bandId!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let fbRef = Database.database().reference()
        let childUpdates: [String: Any] = [
            "/charges/\(key)/isRefunded": true,
            "/charges/\(key)/refundedAt": dateFormatter.string(from: refundedAt),
            "/charges/\(key)/refundId": refundId,
            "/pays/\(bandId)/charges/\(key)/isRefunded": true,
            "/pays/\(bandId)/charges/\(key)/refundedAt": dateFormatter.string(from: refundedAt),
            "/pays/\(bandId)/charges/\(key)/refundId": refundId,
            "/receipts/\(tenantInfo.tenantId)/charges/\(key)/isRefunded": true,
            "/receipts/\(tenantInfo.tenantId)/charges/\(key)/refundedAt": dateFormatter.string(from: refundedAt),
            "/receipts/\(tenantInfo.tenantId)/charges/\(key)/refundId": refundId,
        ]
        
        fbRef.updateChildValues(childUpdates, withCompletionBlock: { error, _ in
            if error != nil {
                os_log("refundCharge Error: %@", log: .default, type: .error, error! as CVarArg)
                onError()
                return
            }
            
            summarizePay(bandId: payInfo.bandId!, amount: -1 * payInfo.amount!)
            summarizeReceipt(tenantId: tenantInfo.tenantId, date: payInfo.paidAt!, amount: -1 * payInfo.amount!)
            
            onRefund()
        })
    }
    
    class func loadReceiptSummaries(tenantId: String, onLoad: @escaping ([String: Any]?) -> ()) {
        let refSum = Database.database().reference().child("receipts/\(tenantId)/summaries")
        refSum.observeSingleEvent(of: .value, with: { snapshot in
            let summaries = snapshot.value as? [String: Any]
            
            onLoad(summaries)
        })
    }
    
    class func loadOrders(tenantId: String, onLoad: @escaping ([DataSnapshot]) -> ()) {
        let refCharges = Database.database().reference().child("receipts/\(tenantId)/charges")
        refCharges.queryOrdered(byChild: "paidAt").observeSingleEvent(of: .value, with: { snapshot in
            onLoad(snapshot.children.allObjects as! [DataSnapshot])
        })
    }
    
    class func findCharge(key: String, onLoad: @escaping ([String: Any]) -> ()) {
        let refCharges = Database.database().reference().child("charges/\(key)")
        refCharges.observeSingleEvent(of: .value, with: { snapshot in
            onLoad(snapshot.value as! [String: Any])
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
    
    class func agreeTerms(tenantId: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateStr = dateFormatter.string(from: Date())
        
        let fbRef = Database.database().reference()
        fbRef.child("tenants/\(tenantId)/isAgreed").setValue(true)
        fbRef.child("tenants/\(tenantId)/agreedAt").setValue(dateStr)
    }
    
    class func isAgreed(tenantId: String, onAgreed: @escaping () -> (), onNotAgreed: @escaping () -> (), onError: @escaping () -> ()) {
        let fbRef = Database.database().reference()
        fbRef.child("tenants").child(tenantId).observeSingleEvent(of: .value, with: { (snapshot) in
            let tenant = snapshot.value as? [String: Any]
            
            if (tenant?["isAgreed"] != nil && tenant?["isAgreed"] as! Bool) {
                onAgreed()
            } else {
                onNotAgreed()
            }
        }) { (error) in
            os_log("isAgreed error: %@", log: .default, type: .error, error.localizedDescription)
            onError()
        }
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
