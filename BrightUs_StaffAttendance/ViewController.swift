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
import FirebaseDatabase

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
    
    /**
     * Indicator to let user know about data loading
    */
    var indicator = UIActivityIndicatorView()
    
    /**
     * viewDidLoad Method
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Self delegates of TextFields
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //Default Email ID & Password for Testing
        
//        emailTextField.text = "staff@maildrop.cc"
//        passwordTextField.text = "staff"

        //Custom Loading Indicator
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = self.view.center
        indicator.backgroundColor = UIColor.clear
        indicator.color = UIColor.black
        indicator.startAnimating()
        
        // Custom Button to show password
        let showPasswordButton = UIButton()
        
        if screenheight <= 568{
            showPasswordButton.frame = CGRect(x: 236.0, y: 316.0, width: 35.0, height: 35.0)

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

    /**
     * didReceiveMemoryWarning Method
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * viewWillAppear Method
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let tokenValue = defaults.value(forKey: "accessToken"){
            if tokenValue as! String == ""{
                print("No token exists")
            }
            else{
                
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                self.navigationController?.pushViewController(vc, animated: false)
            }
            
        }
        self.navigationController?.navigationBar.isHidden = true
    }
    
    /**
     * viewWillDisappear Method
     */
//    override func viewWillDisappear(_ animated: Bool) {
//        self.viewWillDisappear(true)
//        self.navigationController?.navigationBar.isHidden = false
//    }
    
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
    /**
     Login Button Action
     
     - parameter description : Check for Validate Email & Passwords
     
    */
    
    @IBAction func LoginButtonPressed(_ sender: UIButton) {
//        self.performSegue(withIdentifier: "showHomeViewController", sender: self.storyboard)

        if IsConnectionAvailable(){
            if (Validation()){
                
                self.view.addSubview(indicator)
                self.view.isUserInteractionEnabled = false
                self.view.window?.isUserInteractionEnabled = false
                
                AuthorizeUser()
            }
        }
        else{
            let alert = ShowAlert()
            alert.title = "BrightUs"
            alert.message = "Check the internet connection on your device"
            _ = self.present(alert, animated: true, completion: nil)
            
        }
    }

    
    //MARK: - Validation Method
    
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
            
            alert.message = "Email is required"
            _ = self.present(alert, animated: true, completion: nil)
            return false
        }
        else if !emailCheck {
            
            alert.message = "Please enter the vailid email address"
            _ = self.present(alert, animated: true, completion: nil)

            return false
        }
        else if !emptyPassword {
            
            alert.message = "Password is required"
            _ = self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    //MARK: - Prepare Segue
    
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
    
    /**
     ShowAlert - Common method to declare controller properties and actions
 
     - parameter return : UIAlertController (to change title & messages later while using this method)
     
    */
    
    func ShowAlert() -> UIAlertController{
        let alertController = UIAlertController(title: "BrightUs", message: "Device not supported for this application", preferredStyle: UIAlertControllerStyle.alert)
//        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
//            self.dismiss(animated: false, completion: nil)
//            print("Cancel")
//        }
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.dismiss(animated: false, completion: nil)
            print("Okay")
        }
//        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
//        _ = self.present(alertController, animated: true, completion: nil)
        return alertController
    }
    
    //MARK: - API Requests

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
            
            request.httpBody = jsonData
            print(jsonData)
            
            _ = URLSession.shared.dataTask(with: request as URLRequest){(data, response, error) -> Void in
                do {
                    if data != nil{
                        if let httpResponseValue = response as? HTTPURLResponse{
                            print(httpResponseValue.statusCode)
                            if httpResponseValue.statusCode == 200 {
                                if let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as?  NSDictionary{
                                    print(dict)
                                    
                                    let tokenTypeValue = dict.value(forKey: "token_type")
                                    let accessTokenValue = dict.value(forKey: "access_token")
                                    let refreshTokenValue = dict.value(forKey: "refresh_token")
                                    
                                    defaults.setValue(self.passwordTextField.text!, forKey: "password")
                                    defaults.setValue(tokenTypeValue, forKey: "tokenType")
                                    defaults.setValue(accessTokenValue, forKey: "accessToken")
                                    defaults.setValue(refreshTokenValue, forKey: "refreshToken")
                                    defaults.synchronize()
                                    

                                    self.TokenForFirebase()
                                }
                               
                            }
                            else if httpResponseValue.statusCode == 400{
                                let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                                print(dict)
                            }
                            else if httpResponseValue.statusCode == 401{
                                let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                                print(dict)
                                
                                DispatchQueue.main.async {
                                    let alert = self.ShowAlert()
                                    
                                    alert.message = "\(dict.value(forKey: "message")!)"
                                    alert.title = "BrightUs"
                                    _ = self.present(alert, animated: true, completion: nil)
                                    self.indicator.removeFromSuperview()
                                    self.view.isUserInteractionEnabled = true
                                    self.view.window?.isUserInteractionEnabled = true
                                }
                                
                            }
                            
                        }
                    }
                    else if let error = error{
                        let alert = self.ShowAlert()
                        alert.title = "BrightUs"
                        alert.message = error.localizedDescription
                        _ = self.present(alert, animated: true, completion: nil)
                    }
                }
                catch{
                    print("Error")
                }
                
                }.resume()
        }
        catch{
            print("Error")
        }
        
       
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
                            if let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as?  NSDictionary{
                                print(dict)
                                
                                let firebaseTokenValue = dict.value(forKey: "token") as! String
                                defaults.setValue(firebaseTokenValue, forKey: "firebaseToken")
                                defaults.synchronize()
                                self.FirebaseLogin(token: "\(firebaseTokenValue)")
                            }
                        }
                    }
                }
                else if let error = error{
                    let alert = self.ShowAlert()
                    alert.title = "BrightUs"
                    alert.message = error.localizedDescription
                    _ = self.present(alert, animated: true, completion: nil)
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
        if IsConnectionAvailable(){
            FIRAuth.auth()?.signIn(withCustomToken: token ) { (user, error) in
                if let user = FIRAuth.auth()?.currentUser {
                    print(user)
                }

                self.performSelector(inBackground: #selector(ViewController.ViewProfile), with: nil)


            }

        }
        else{
            let alert = ShowAlert()
            alert.title = "BrightUs"
            alert.message = "Check the internet connection on your device"
            _ = self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    //MARK: - TextField Delegate

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
    
    //MARK: - View Profile Request

    /**
     View Profile Request
     
     - parameter method : GET
     
     - parameter return : Name, Latitude & Longitude of Branch Location
     
     */
    func ViewProfile() {
        let apiString = baseURL + "/api/user"
        let encodedApiString = apiString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: encodedApiString!)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let token = defaults.value(forKey: "accessToken") as! String
        
        let header = "Bearer" + " \(token)"
        //        print(header)
        
        request.setValue(header, forHTTPHeaderField: "Authorization")
        
        
        _ = URLSession.shared.dataTask(with: request as URLRequest){(data, response, error) -> Void in
            do {
                if data != nil{
                    if let httpResponseValue = response as? HTTPURLResponse{
                        //                        print(httpResponseValue.statusCode)
                        if httpResponseValue.statusCode == 200{
                            if let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as?  NSDictionary{
                                print(dict)
                                
                                let userType = dict.value(forKey: "user_type") as! String
                                
                                //Get User name from here
                                defaults.setValue(dict.value(forKey: "name")!, forKey: "name")
                                defaults.setValue(dict.value(forKey: "id"), forKey: "userId")
                                
                                //TODO : - Add branch code
                                
                                //Get Latitude & longitude of branch
                                if let locationValues = dict.value(forKey: "branches") as? NSArray{
                                    print(locationValues)
                                    if let locationDict = locationValues.object(at: 0) as? NSDictionary{
                                        print(locationDict)
                                        defaults.setValue(locationDict.value(forKey: "branch_code"), forKey: "branchCode")
                                        defaults.setValue(locationDict.value(forKey: "latitude"), forKey: "latitude")
                                        defaults.setValue(locationDict.value(forKey: "longitude"), forKey: "longitude")
                                    }
                                }
                                defaults.synchronize()
                                
                                if userType == "staff"{
                                    self.perform(#selector(ViewController.getdeviceInfo))
//                                    self.performSelector(inBackground: #selector(ViewController.getdeviceInfo), with: nil)
                                    
                                    //Perform Segue i.e. Navigate to DashboardView after successful Login process
                                    DispatchQueue.main.async {
                                        
                                        self.indicator.removeFromSuperview()
                                        self.view.isUserInteractionEnabled = true
                                        self.view.window?.isUserInteractionEnabled = true
                                        
                                        self.performSegue(withIdentifier: "showHomeViewController", sender: self.storyboard)
                                    }
                                }
                                else{
                                    DispatchQueue.main.async {
                                        let alert = self.ShowAlert()
                                        
                                        alert.message = "Only Staff member can use this app"
                                        alert.title = "BrightUs"
                                        
                                        defaults.setValue("", forKey: "tokenType")
                                        defaults.setValue("", forKey: "accessToken")
                                        defaults.setValue("", forKey: "refreshToken")
                                        defaults.setValue("", forKey: "name")
                                        defaults.setValue("", forKey: "latitude")
                                        defaults.setValue("", forKey: "longitude")
                                        defaults.setValue("", forKey: "password")
                                        
                                        defaults.synchronize()

                                        _ = self.present(alert, animated: true, completion: nil)
                                        self.indicator.removeFromSuperview()
                                        self.view.isUserInteractionEnabled = true
                                        self.view.window?.isUserInteractionEnabled = true

                                    }
                                }

                            }
                        }
                    }
                }
                else if let error = error{
                    let alert = self.ShowAlert()
                    alert.title = "BrightUs"
                    alert.message = error.localizedDescription
                    _ = self.present(alert, animated: true, completion: nil)
                }
            }
            catch{
                print("Error")
            }
            }.resume()
        
    }

    //MARK: - Get Device Information

    /**
     *Save the information into Firebase
    */
    func getdeviceInfo(){
        
        
        let model = UIDevice.current.modelName
        let name = UIDevice.current.name
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        var appVersion = ""
        var appBuild = ""
        
        print("Model - \(model)")
        print("description - \(UIDevice.current.description)")
        print("localizedModel - \(UIDevice.current.modelName)")
        print("name - \(name)")
        print("systemName - \(systemName)")
        print("systemVersion - \(systemVersion)")
        print("batteryLevel - \(UIDevice.current.batteryLevel)")
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            print("App Version - \(version)")
            appVersion = version
        }
        
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            print("App Build - \(build)")
            appBuild = build
            
        }
        
        deviceInfo(appBuild, appVersion: appVersion, deviceModel: model, deviceName: name, systemName: systemName, systemVersion: systemVersion)
        
    }
    
    /**
     Get the device Information
        
        - parameter argument : appBuild, appVersion, deviceModel, deviceName
     */
    func deviceInfo(_ appBuild : String, appVersion : String, deviceModel : String,deviceName : String,systemName : String,systemVersion : String) {
        let userId = defaults.value(forKey: "userId") as! Int
        let branchCode = defaults.value(forKey: "branchCode") as! String
        
        let ref = FIRDatabase.database().reference()
        
            let infoDict = NSMutableDictionary()
            infoDict.setValue(appBuild, forKey: "appBuild")
            infoDict.setValue(appVersion, forKey: "appVersion")
            infoDict.setValue(deviceModel, forKey: "deviceModel")
            infoDict.setValue(deviceName, forKey: "deviceName")
            infoDict.setValue(systemName, forKey: "systemName")
            infoDict.setValue(systemVersion, forKey: "systemVersion")
        
        ref.child("iOSstaffApp").child("branches").child(branchCode).child("deviceInfo").child("users").child("\(userId)").setValue(infoDict)

    }
}
