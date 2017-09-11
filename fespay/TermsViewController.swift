//
//  TermsViewController.swift
//  fespay
//
//  Created by Shizuka Kakimoto on 2017/09/11.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    let i18n = I18n(tableName: "TermsView")
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var agreeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func agreeTapped(_ sender: UIButton) {
        let tenantInfo = TenantInfo.sharedInstance
        FirebaseClient.agreeTerms(tenantId: tenantInfo.tenantId)
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
        
        self.present(next, animated: true, completion: nil)
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.agreeButton.setTitle(i18n.localize(key: "agree"), for: .normal)
        self.cancelButton.setTitle(i18n.localize(key: "cancel"), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let htmlData = Bundle.main.path(forResource: "terms_of_use", ofType: "html") {
            webView.loadRequest(URLRequest(url: URL(fileURLWithPath: htmlData)))
        } else {
            let alert = self.i18n.alert(titleKey: "failToLoad", messageKey: "tryAgain", handler: {
                self.dismiss(animated: true, completion: nil)
            })
            self.present(alert, animated: true)
        }

        let border = CALayer()
        border.frame = CGRect(x: 0, y: 0, width: webView.frame.width, height: webView.frame.height)
        border.borderColor = UIColor.lightGray.cgColor
        border.borderWidth = 0.5
        webView.layer.addSublayer(border)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
