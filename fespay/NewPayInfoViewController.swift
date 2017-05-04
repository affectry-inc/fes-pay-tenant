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
    
    // MARK: - Properties
    
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var captureButton: UIButton!
    
    var payInfo: PayInfo?
    
    // MARK: - Events
    
    override func viewWillAppear(_ animated: Bool) {
        priceTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        priceTextField.delegate = self
        
        // Enable the Pay button only if the text field has a valid Pay info.
        updatePayButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        updatePayButtonState()
    }

    // MARK: - Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the pay button is pressed.
        guard let button = sender as? UIBarButtonItem, button === captureButton else {
            os_log("The pay button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let price = Double(priceTextField.text!) ?? 0
        
        // Set the payInfo to be passed to PayInfoTableViewController after the unwind segue.
        payInfo = PayInfo(price: price, paid_at: Date(), payer: "")
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Actions
    @IBAction func goToCapture(_ sender: UIButton) {
    }
    
    // MARK: - Private Methods
    
    private func updatePayButtonState() {
        // Disable the Pay button if the text field is empty.
        let text = priceTextField.text ?? ""
        captureButton.isEnabled = !text.isEmpty
    }
}

