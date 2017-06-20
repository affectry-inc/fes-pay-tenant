//
//  LoginViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/06/08.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var shopIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // let next = self.storyboard?.instantiateViewController(withIdentifier: "PayListView") as! PayListViewController
        let next = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
        
        self.present(next, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the text field’s user input through delegate callbacks.
        shopIdTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let shopIdPh: String = i18n.localize(key: "shopIdPh")
        let passwordPh: String = i18n.localize(key: "passwordPh")
        loginButton.setTitle(i18n.localize(key: "login"), for: .normal)
        
        self.view.backgroundColor = primary1Color
        
        self.shopIdTextField.attributedPlaceholder = NSAttributedString(string: shopIdPh, attributes: [NSForegroundColorAttributeName: UIColor.lightText])
        self.shopIdTextField.addBorderBottom(height: 1.0, color: UIColor.white)
        
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordPh, attributes: [NSForegroundColorAttributeName: UIColor.lightText])
        self.passwordTextField.addBorderBottom(height: 1.0, color: UIColor.white)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (shopIdTextField.isFirstResponder) {
            shopIdTextField.resignFirstResponder()
        }
        if (passwordTextField.isFirstResponder) {
            passwordTextField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        textField.resignFirstResponder()
        
        return true
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
