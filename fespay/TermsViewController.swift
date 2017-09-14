//
//  TermsViewController.swift
//  fespay
//
//  Created by Shizuka Kakimoto on 2017/09/11.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit
import os.log

class TermsViewController: UIViewController, UIWebViewDelegate {

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
        
        webView.delegate = self
        
        LoadingProxy.set(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.agreeButton.setTitle(i18n.localize(key: "agree"), for: .normal)
        self.cancelButton.setTitle(i18n.localize(key: "cancel"), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // let pathToTerms = URL(string: "https://s3-ap-northeast-1.amazonaws.com/fespay-prd/legal/terms_of_use_tenant.html")
        let pathToTerms = URL(string: Bundle.main.path(forResource: "terms_of_use_tenant", ofType: "html")!)
        let urlRequest = URLRequest(url: pathToTerms!)
        webView.loadRequest(urlRequest as URLRequest)
        
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

    func webViewDidStartLoad(_ webView: UIWebView) {
        LoadingProxy.on()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        LoadingProxy.off()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        os_log("webView Load Error: %@", log: .default, type: .error, error as CVarArg)
        LoadingProxy.off()
        
        let alert = self.i18n.alert(titleKey: "loadFailed", messageKey: "tryAgain", handler: {
            self.dismiss(animated: true, completion: nil)
        })
        self.present(alert, animated: true)
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
