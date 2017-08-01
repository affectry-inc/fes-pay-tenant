//
//  LoginViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/08.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit
import os.log

extension UITextField {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}

extension UILabel {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}

class LoginViewController: UIViewController, UITextFieldDelegate {

    let i18n = I18n(tableName: "LoginView")
    
    // MARK: - Properties
    
    @IBOutlet weak var tenantIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        if tenantIdTextField.text?.characters.count == 0 {
            present(i18n.alert(titleKey: "emptyTenantId", messageKey: "enterTenantId"), animated: true)

            return
        }
        
        if passwordTextField.text?.characters.count == 0 {
            present(i18n.alert(titleKey: "emptyPassword", messageKey: "enterPassword"), animated: true)
            
            return
        }
        
        FirebaseClient.signInAsTenant(tenantId: tenantIdTextField.text!, password: passwordTextField.text!, onSignIn: {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
            
            self.present(next, animated: true, completion: nil)
        }, onError: {
            self.present(self.i18n.alert(titleKey: "invalidIdOrPassword", messageKey: "tryAgain"), animated: true)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the text field’s user input through delegate callbacks.
        tenantIdTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tenantIdPh: String = i18n.localize(key: "tenantIdPh")
        let passwordPh: String = i18n.localize(key: "passwordPh")
        loginButton.setTitle(i18n.localize(key: "login"), for: .normal)
        
        self.view.backgroundColor = primary1Color
        
        self.tenantIdTextField.attributedPlaceholder = NSAttributedString(string: tenantIdPh, attributes: [NSForegroundColorAttributeName: UIColor.lightText])
        self.tenantIdTextField.addBorderBottom(height: 1.0, color: UIColor.white)
        
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordPh, attributes: [NSForegroundColorAttributeName: UIColor.lightText])
        self.passwordTextField.addBorderBottom(height: 1.0, color: UIColor.white)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (tenantIdTextField.isFirstResponder) {
            tenantIdTextField.resignFirstResponder()
        }
        if (passwordTextField.isFirstResponder) {
            passwordTextField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func unwindToLoginView(sender: UIStoryboardSegue) {
        tenantIdTextField.text = ""
        passwordTextField.text = ""
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
