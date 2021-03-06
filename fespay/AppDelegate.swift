//
//  AppDelegate.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/04/22.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit
import AWSCognito
import Firebase
import os.log

let primary1Color = UIColor(red: 146.0/255.0, green: 208.0/255.0, blue: 80.0/255.0, alpha:1)
let title1Color = UIColor(red: 255.0/255.0, green: 225.0/255.0, blue: 255.0/255.0, alpha:1)

let infoDict = Bundle.main.infoDictionary! as Dictionary
let envFileName = infoDict["EnvFileName"] as! String
let envFilePath = Bundle.main.path(forResource: envFileName, ofType: "plist")
let env = NSDictionary(contentsOfFile: envFilePath!) as! [String: Any]

extension String {
    func isNumber() -> Bool {
        let pattern = "^[\\d]+$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: characters.count))
        return matches.count > 0
    }
}

extension Double {
    func toJPY() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.currencyGroupingSeparator = ","
        
        return formatter.string(from: self as NSNumber)!
    }
}

extension Date {
    func toTokyoTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        return formatter.string(from: self)
    }
    
    func toTokyoDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        return formatter.string(from: self)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Init AWS
        let identityPoolId = env["IDENTITY_POOL_ID"] as! String
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .APNortheast1, identityPoolId: identityPoolId)
        
        let configuration = AWSServiceConfiguration(region:.APNortheast1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        // Init Firebase
        let plistPath = Bundle.main.path(forResource: env["FIREBASE_PLIST_NAME"] as? String, ofType: "plist")
        guard let fileopts = FirebaseOptions.init(contentsOfFile: plistPath!) else {
            os_log("Couldn't load Firebase config file", log: OSLog.default, type: .debug)
            return false
        }
        FirebaseApp.configure(options: fileopts)
        
        // Design navigation bar
        let attributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20),
            NSForegroundColorAttributeName: title1Color
        ]
        UINavigationBar.appearance().barTintColor = primary1Color
        UINavigationBar.appearance().titleTextAttributes = attributes
        UINavigationBar.appearance().tintColor = title1Color
        
        // Design tab bar
        UITabBar.appearance().tintColor = primary1Color
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

