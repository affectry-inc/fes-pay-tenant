//
//  PasscodeViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/05/04.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class PasscodeViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var passcodeTextField: UITextField!
    @IBOutlet weak var settleButton: UIButton!
    
    var payInfo: PayInfo?
    
    // MARK: - Events
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        updateSettleButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        passcodeTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateSettleButtonState()
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
    
    // MARK: - Private Methods
    
    private func updateSettleButtonState() {
        // Disable the Pay button if the text field is empty.
        let text = passcodeTextField.text ?? ""
        settleButton.isEnabled = text.characters.count == 4
    }

}
