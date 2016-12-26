//
//  ForgotPassViewController.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

class ForgotPassViewController: UIViewController, UITextFieldDelegate {
    
    
    /**
     * Email Text field
    */
    
    @IBOutlet var emailTextField: HoshiTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        emailTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Back Button Action 
     
     - parameter description : When user tap on back button, app will navigate to previous screen along with animation
     
    */
    
    @IBAction func BackButtonAction(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    /**
     Submit Button Action
     
     - parameter description : performs action to receive email in order to recover the forgotten password
 
    */
    
    @IBAction func submitButton(_ sender: UIButton) {
        if (Validation()){      //Only performed successfully if specified email format get matched
            
        }
    }
    
    /**
     Validation Method
     
     - parameter return : Return Bool value
     
     - parameter checks : Empty email content, email format
 
    */
    func Validation()->Bool{
        
        let emailCheck = ValidateEmail(text: emailTextField.text!)
        let emptyEmail = ValidateEmptyContent(textField: emailTextField)
        
        let alert = ShowAlert()

        if !emptyEmail {
            
            alert.message = "Email cannot be empty."
            _ = self.present(alert, animated: true, completion: nil)
            return false
        }
        else if !emailCheck {
            
            alert.message = "Invalid Email Address"
            _ = self.present(alert, animated: true, completion: nil)

            return false
        }
       
        return true
    }
    
    /**
     Alert Controller Method
     
        - paramter return : Returns UIAlertController
 
        - parameter description : Method to intialize and add actions to alert controller
    */
    
    func ShowAlert() -> UIAlertController{
        let alertController = UIAlertController(title: "Alert", message: "Device not supported for this application", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            self.dismiss(animated: false, completion: nil)
            print("Cancel")
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.dismiss(animated: false, completion: nil)
            print("OK")
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        //        _ = self.present(alertController, animated: true, completion: nil)
        return alertController
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField{
            emailTextField.resignFirstResponder()
        }
        return true
    }
}
