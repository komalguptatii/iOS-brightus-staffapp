//
//  ChangePassword.swift
//  BrightUs_StaffAttendance
//
//  Created by Komal Gupta on 27/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

class ChangePassword: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var currentPasswordTextField: HoshiTextField!
    @IBOutlet var newPasswordTextfield: HoshiTextField!
    @IBOutlet var confirmNewPasswordTextfield: HoshiTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentPasswordTextField.delegate = self
        newPasswordTextfield.delegate = self
        confirmNewPasswordTextfield.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func BackButtonAction(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SubmitButtonAction(_ sender: UIButton) {
        if Validation(){
            self.ChangePasswordCall()
        }
    }
    
    /**
     Validation Method to validate content on the screen
    */
    func Validation()->Bool{
        //OldPassword
        //NewPassword
        //Match Old and New password
        return true
    }
    
    func ChangePasswordCall(){
        let apiString = baseURL + "/api/user"
        let encodedApiString = apiString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: encodedApiString!)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let token = defaults.value(forKey: "accessToken") as! String
        //        let header = "\(defaults.value(forKey: "tokenType")!)" + " \(defaults.value(forKey: "accessToken")!)"
        let header = "Bearer" + " \(token)"
        print(header)
        
        request.setValue(header, forHTTPHeaderField: "Authorization")
        
        let jsonDict = NSMutableDictionary()
        jsonDict.setValue("", forKey: "old_password")
        jsonDict.setValue("", forKey: "new_password")
        
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
                        if httpResponseValue.statusCode == 204 {
                            let alert = self.ShowAlert()
                            alert.message = "Password is successfully changed"
                            _ = self.present(alert, animated: true, completion: nil)
                            _ = self.navigationController?.popViewController(animated: true)


                        }
                        else if httpResponseValue.statusCode == 401 {
                            let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                            print(dict)
                            let alert = self.ShowAlert()
                            
                            alert.message = "\(dict.value(forKey: "message"))"
                            alert.title = "\(dict.value(forKey: "title"))"
                            _ = self.present(alert, animated: true, completion: nil)
                            
                            
                        }
                        else if httpResponseValue.statusCode == 422{
                            let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                            print(dict)
                            
                            if let arrayReceived = dict.value(forKey: "error") as? NSArray{
                                print(arrayReceived)
                                if let dictInArray = arrayReceived.object(at: 0) as? NSDictionary{
                                    print(dictInArray)
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
            catch{
                print(error)
            }
        }.resume()


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

    
}
