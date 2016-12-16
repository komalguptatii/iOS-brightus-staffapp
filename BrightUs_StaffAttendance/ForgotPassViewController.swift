//
//  ForgotPassViewController.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

class ForgotPassViewController: UIViewController {
    
    @IBOutlet var emailTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitButton(_ sender: UIButton) {
        if (Validation()){
            
        }
    }
    
    func Validation()->Bool{
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        var result = false
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        result = emailTest.evaluate(with: emailTextField.text)
        let alert = ShowAlert()

        if emailTextField.text == "" {
            
            alert.message = "Email cannot be empty."
            _ = self.present(alert, animated: true, completion: nil)
            return false
        }
        else if result == false {
            
            alert.message = "Invalid Email Address"
            _ = self.present(alert, animated: true, completion: nil)

            return false
        }
       
        return true
    }
    
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
}
