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

class LoginViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var tenantIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let next = self.storyboard?.instantiateViewController(withIdentifier: "PayListView") as! PayListViewController
        
        self.present(next, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = primary1Color
        self.tenantIdTextField.attributedPlaceholder = NSAttributedString(string: "Tenant ID", attributes: [NSForegroundColorAttributeName: UIColor.lightText])
        self.tenantIdTextField.addBorderBottom(height: 1.0, color: UIColor.white)
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.lightText])
        self.passwordTextField.addBorderBottom(height: 1.0, color: UIColor.white)
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
