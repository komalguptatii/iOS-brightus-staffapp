//
//  ViewController.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth

/// Login View

class ViewController: UIViewController, UITextFieldDelegate {

    /**
    
     - parameter emailTextField : Email entered by user in email textfield (Instead of UITextfield, it is inherited from HoshiTextField)
    
     */
    @IBOutlet var emailTextField: HoshiTextField!
    
    /**
 
     - parameter passTextField : Password entered by user in password textfield (Instead of UITextfield, it is inherited from HoshiTextField)

     */
    @IBOutlet var passwordTextField: HoshiTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Self delegates of TextFields
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //Default Email ID & Password for Testing
        
        emailTextField.text = "staff@maildrop.cc"
        passwordTextField.text = "staff"
        
        
        // Custom Button to show password
        let showPasswordButton = UIButton()
        
        if screenheight <= 568{
            showPasswordButton.frame = CGRect(x: 236.0, y: 318.0, width: 35.0, height: 35.0)

        }
        else if screenheight <= 667{
            showPasswordButton.frame = CGRect(x: 290.0, y: 372.0, width: 35.0, height: 35.0)

        }
        else if screenheight <= 736{
            showPasswordButton.frame = CGRect(x: 330.0, y: 410.0, width: 40.0, height: 40.0)

        }
        
        showPasswordButton.setImage(UIImage(named: "eyeIcon"), for: UIControlState.normal)
        showPasswordButton.addTarget(self, action: #selector(ViewController.ShowPasswordAction(_sender:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(showPasswordButton)

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        self.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    /**
     Show Password in Text Format Action
     
     -parameter description : User can tap on eye to view password and then again to hide the same
 
    */
    func ShowPasswordAction(_sender: UIButton){
        if _sender.tag == 0{
            passwordTextField.isSecureTextEntry = false
            _sender.tag = 1
        }
        else if _sender.tag == 1{
            passwordTextField.isSecureTextEntry = true
            _sender.tag = 0
        }
    }
    
    //MARK: - Button Actions
    //MARK: -
    /**
     Login Button Action
     
     - parameter description : Check for Validate Email & Passwords
     
    */
    
    @IBAction func LoginButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showHomeViewController", sender: self.storyboard)

        if (Validation()){
//            AuthorizeUser()
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
        
        let emailCheck = ValidateEmail(text: emailTextField.text!)
        let emptyEmail = ValidateEmptyContent(textField: emailTextField)
        let emptyPassword = ValidateEmptyContent(textField: passwordTextField)
        
        let alert = ShowAlert()

        if !emptyEmail{
            
            alert.message = "Email cannot be empty."
            _ = self.present(alert, animated: true, completion: nil)
            return false
        }
        else if !emailCheck {
            
            alert.message = "Invailid email address"
            _ = self.present(alert, animated: true, completion: nil)

            return false
        }
        else if !emptyPassword {
            
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
//            _ = segue.destination as! HomeViewController
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
     Authorize User - Method for User to login into App along with authorization
     
     - parameter input : client_id, client_secret, grant_type, username, password
     
     - parameter return : token_type, expires_in, access_token, refresh_token
 
    */
    func AuthorizeUser() {
        let apiString = baseURL + "/oauth/token"
        let encodedApiString = apiString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: encodedApiString!)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let jsonDict = NSMutableDictionary()
        jsonDict.setValue("2", forKey: "client_id")
        jsonDict.setValue("XNgcybCHTfz0wfehSQcDOStyGCnwakCIIECZzWtD", forKey: "client_secret")
        jsonDict.setValue("password", forKey: "grant_type")
        jsonDict.setValue(emailTextField.text, forKey: "username")
        jsonDict.setValue(passwordTextField.text, forKey: "password")
        
       
        print(jsonDict)
        
        var jsonData = Data()
        
        do{
            jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
        }
        catch{
            print("Error")
        }
        
        request.httpBody = jsonData
        print(jsonData)
        
        _ = URLSession.shared.dataTask(with: request as URLRequest){(data, response, error) -> Void in
            do {
                if data != nil{
                    if let httpResponseValue = response as? HTTPURLResponse{
                        print(httpResponseValue.statusCode)
                        if httpResponseValue.statusCode == 200 {
                            let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                            print(dict)
                            
                            let tokenTypeValue = dict.value(forKey: "token_type")
                            let accessTokenValue = dict.value(forKey: "access_token")
                            let refreshTokenValue = dict.value(forKey: "refresh_token")
                            
                            defaults.setValue(tokenTypeValue, forKey: "tokenType")
                            defaults.setValue(accessTokenValue, forKey: "accessToken")
                            defaults.setValue(refreshTokenValue, forKey: "refreshToken")
                            defaults.synchronize()
                            
                            self.TokenForFirebase()
                        }
                        else if httpResponseValue.statusCode == 400{
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
    
    /**
     Get Token For Firebase
     
     - parameter return : token sent to firebase
 
    */
    func TokenForFirebase(){
        let apiString = baseURL + "/api/user/firebase"
        
        let encodedApiString = apiString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: encodedApiString!)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let token = defaults.value(forKey: "accessToken") as! String
//        let header = "\(defaults.value(forKey: "tokenType")!)" + " \(defaults.value(forKey: "accessToken")!)"
        let header = "Bearer" + " \(token)"
        print(header)
        
        request.setValue(header, forHTTPHeaderField: "Authorization")
        
        
        _ = URLSession.shared.dataTask(with: request as URLRequest){(data, response, error) -> Void in
            do {
                if data != nil{
                    if let httpResponseValue = response as? HTTPURLResponse{
                        print(httpResponseValue.statusCode)
                        if httpResponseValue.statusCode == 200{
                            let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                            print(dict)
                            
                            let firebaseTokenValue = dict.value(forKey: "token") as! String
                            defaults.setValue(firebaseTokenValue, forKey: "firebaseToken")
                            defaults.synchronize()
                            self.FirebaseLogin(token: "\(firebaseTokenValue)")
                        }
                    }
                }
            }
            catch{
               print("Error")
            }
        }.resume()
    }
    
    /**
     Login into Firebase
     
     - parameter description : Sign into Firebase & navigate to Home View controller
     
    */
    
    func FirebaseLogin(token : String) {
        print(token)
        FIRAuth.auth()?.signIn(withCustomToken: token ) { (user, error) in
            if let user = FIRAuth.auth()?.currentUser {
                print(user)
            }
            
            //TODO
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showHomeViewController", sender: self.storyboard)
            }

        }
    }
    
    //MARK: - TextField Delegate
    //MARK: -
    /**
     TextField Return Delegate
    */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField{
            passwordTextField.resignFirstResponder()
        }
        return true
    }
}
