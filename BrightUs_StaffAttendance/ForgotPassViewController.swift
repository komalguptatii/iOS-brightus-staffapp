//
//  ForgotPassViewController.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

/// Forgot Password - To recover password in case forgot

class ForgotPassViewController: UIViewController, UITextFieldDelegate {
    
    
    /**
     * Email Text field
    */
    
    @IBOutlet var emailTextField: HoshiTextField!
    
    /**
     * Indicator to let user know about data loading
     */
    var indicator = UIActivityIndicatorView()
    
    //MARK: - Methods
    //MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        emailTextField.delegate = self
        emailTextField.text = "staff@maildrop.cc"

        //Custom Loading Indicator
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = self.view.center
        indicator.backgroundColor = UIColor.clear
        indicator.color = UIColor.black
        indicator.startAnimating()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Button Actions
    //MARK: -

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
        let checkValue = Validation()
        print(checkValue)
        if IsConnectionAvailable(){
            if (Validation()){      //Only performed successfully if specified email format get matched
                self.view.addSubview(indicator)
                self.view.isUserInteractionEnabled = false
                self.view.window?.isUserInteractionEnabled = false
                
                ForgotPasswordActionCall()
            }
        }
        else{
            let alert = ShowAlert()
            alert.title = "Alert"
            alert.message = "Check Network Connection"
            _ = self.present(alert, animated: true, completion: nil)

        }
    }
    
    //MARK: - Validation Method
    //MARK: -

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
    
    //MARK: - API Call
    /**
     API Call - Forgot Password
     
     - parameter method : POST
     
     - parameter send : Email, Content-Type
     
     - parameter return : Empty Content to mark success
     
    */
    func ForgotPasswordActionCall(){
        let apiString = baseURL + "/api/user/forgot-password"
        let encodedApiString = apiString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: encodedApiString!)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let jsonDict = NSMutableDictionary()
        jsonDict.setValue(emailTextField.text!, forKey: "email")
        
        var jsonData = Data()
        
        do{
            jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            request.httpBody = jsonData
            print(jsonData)
            
            _ = URLSession.shared.dataTask(with: request as URLRequest){(data, response, error) -> Void in
                do {
                    if data != nil{
                        if let httpResponseValue = response as? HTTPURLResponse{
                            print(httpResponseValue.statusCode)
                            if httpResponseValue.statusCode == 204 {
                                DispatchQueue.main.async {
                                    let alert = self.ShowAlert()
                                    alert.message = "Please check your email and recover the password"
                                    _ = self.present(alert, animated: true, completion: nil)
                                    _ = self.navigationController?.popViewController(animated: true)
                                    
                                }
                            }
                            else if httpResponseValue.statusCode == 401 {
                                if let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as?  NSDictionary{
                                    print(dict)
                                    
                                    DispatchQueue.main.async {
                                        let alert = self.ShowAlert()
                                        
                                        alert.message = "\(dict.value(forKey: "message"))"
                                        alert.title = "\(dict.value(forKey: "title"))"
                                        _ = self.present(alert, animated: true, completion: nil)
                                        
                                    }
                                }
                               
                            }
                            else if httpResponseValue.statusCode == 422{
                                let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                                print(dict)
                                
                                
                                if let arrayReceived = dict.value(forKey: "error") as? NSArray{
                                    print(arrayReceived)
                                    if let dictInArray = arrayReceived.object(at: 0) as? NSDictionary{
                                        print(dictInArray)
                                        DispatchQueue.main.async {
                                            let alert = self.ShowAlert()
                                            
                                            alert.message = "\(dictInArray.value(forKey: "message"))"
                                            alert.title = "\(dictInArray.value(forKey: "detail"))"
                                            _ = self.present(alert, animated: true, completion: nil)
                                            
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    
                }
                catch{
                    print(error)
                }
                }.resume()

        }
        catch{
            print("Error")
        }
        
       
        DispatchQueue.main.async {
            self.indicator.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
            self.view.window?.isUserInteractionEnabled = true

        }
    }
    
    
    //MARK: - TextField Delegate
    /**
     TextField Return Delegate
     
    */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField{
            emailTextField.resignFirstResponder()
        }
        return true
    }
    
    //MARK: - Alert Controller
    //MARK: -

    
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

}
