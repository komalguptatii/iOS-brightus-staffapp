//
//  ViewController.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

/// Login View

import UIKit

/// Login View

class ViewController: UIViewController {

    /**
    
     - parameter emailTextField : Email entered by user in email textfield
    
     */
    @IBOutlet var emailTextField: UITextField!
    
    /**
 
     - parameter passTextField : Password entered by user in password textfield

     */
    @IBOutlet var passTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Button Actions
    //MARK: -
    /**
     Login Button Action
     
     - parameter description : Check for Validate Email & Passwords
     
    */
    
    @IBAction func LoginButtonPressed(_ sender: UIButton) {
        if (Validation()){
            AuthorizeUser()
//            performSegue(withIdentifier: "showHomeViewController", sender: self.storyboard)
        }
    }

    /**
     Forgot Password Button Action
 
     - parameter description : User can access this feature to create new password.
    */
    
    @IBAction func ForgotPasswordButtonPressed(_ sender: UIButton) {
        
    }
    
    //MARK: - Validation Method
    //MARK: -
    
    /**
     Validation Method
     
     - parameter return : Bool to denote whether the content is valid or not.
     
     - parameter checks : Empty email, Email format, Empty password
    */
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
            
            alert.message = "Invailid email address"
            _ = self.present(alert, animated: true, completion: nil)

            return false
        }
        else if passTextField.text == "" {
            
            alert.message = "Password cannot be empty."
            _ = self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    //MARK: - Prepare Segue
    //MARK: -
    
    /**
     Preparing Segue here
     
     - parameter description : Method prepare segue with particular identifier provided
 
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHomeViewController"{
            _ = segue.destination as! HomeViewController
        }
    }
    
    //MARK: - Show Alert Method
    //MARK: - 
    
    /**
     ShowAlert - Common method to declare controller properties and actions
 
     - parameter return : UIAlertController (to change title & messages later while using this method)
     
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
    
    /**
     
 
    */
    func AuthorizeUser(){
        let apiString = baseURL + "/oauth/token"
        let encodedApiString = apiString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: encodedApiString!)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        
        let boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
        let contentType = "multipart/form-data; boundary=" + boundary
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        let jsonDict = NSMutableDictionary()
        jsonDict.setValue("3", forKey: "client_id")
        jsonDict.setValue("XEMSzYZHclUdj39nDIzhCOkBsGS4uzGvPmmsWbvV", forKey: "client_secret")
        jsonDict.setValue("password", forKey: "grant_type")
        jsonDict.setValue("student", forKey: "password")
        jsonDict.setValue("student@maildrop.cc", forKey: "username")
        
        let bodyData = NSMutableData()
        for (key, value) in jsonDict {
            bodyData.append("--\(boundary)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
            let keyValue = "Content-Disposition: form-data;name=\"" + "\(key)" as String + "\"\r\n\r\n"
            
            bodyData.append("\(keyValue)".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
            bodyData.append("\(value)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        }
        bodyData.append("--\(boundary)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        request.httpBody = bodyData as Data
        print(bodyData.length)
        
        _ = URLSession.shared.dataTask(with: request as URLRequest){(data, response, error) -> Void in
            do {
                print(data)
                if data != nil{
                    if let httpResponseValue = response as? HTTPURLResponse{
                        if httpResponseValue.statusCode == 200{
                            let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                            print(dict)
                        }
                    }
                }
            }
            catch{
                print("Error")
            }

        }.resume()


    }
}
