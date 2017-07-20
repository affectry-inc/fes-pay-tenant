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
    
    class func createPayKey() -> String {
        let fbRef = Database.database().reference()
        return fbRef.child("pays").childByAutoId().key
    }
    
    class func findCardCustomer(bandId: String, onFind: @escaping (String, String) -> ()) {
        let fbRef = Database.database().reference()
        fbRef.child("bands").child(bandId).observeSingleEvent(of: .value, with: { (snapshot) in
            let band = snapshot.value as? [String: Any]
            let cardCustomerId = band?["cardCustomerId"] as! String
            let cardId = band?["cardId"] as! String
            os_log("cardCustomerId: %@", log: .default, type: .debug, cardCustomerId)
            os_log("cardId: %@", log: .default, type: .debug, cardId)
            
            onFind(cardCustomerId, cardId)
        }) { (error) in
            os_log("findCardCustomer error: %@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
}
