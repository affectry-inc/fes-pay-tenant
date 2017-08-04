//
//  NewPayInfoViewController.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/04/22.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit
import os.log

class NewPayInfoViewController: UIViewController, UITextFieldDelegate {
    
    let i18n = I18n(tableName: "NewPayInfoView")
    
    // MARK: - Properties
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountBorderLabel: UILabel!
    @IBOutlet weak var goNextButton: UIButton!
    
    // MARK: - Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        amountTextField.delegate = self
        
        // Enable the Pay button only if the text field has a valid Pay info.
        updatePayButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = i18n.localize(key: "amount")
        self.amountTextField.placeholder = i18n.localize(key: "inputAmountPh")
        self.goNextButton.setTitle(i18n.localize(key: "next"), for: .normal)
        
        amountBorderLabel.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        
        amountTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        updatePayButtonState()
    }

    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "CaptureView" {
            guard let captureView = segue.destination as? QRCaptureViewController else {
                os_log("The destination is not a CaptureView", log: OSLog.default, type: .debug)
                return
            }
            captureView.payInfo = PayInfo()
            captureView.payInfo?.amount = Double(amountTextField.text!)!
            captureView.payInfo?.bandId = "a001"
        }
        else if segue.identifier == "UnwindToPayList" {
            self.amountTextField.text = ""
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Private Methods
    
    private func updatePayButtonState() {
        // Disable the Pay button if the text field is empty.
        let text = amountTextField.text ?? ""
        goNextButton.isEnabled = !text.isEmpty
    }
}

