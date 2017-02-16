//
//  UserProfile.swift
//  BrightUs_StaffAttendance
//
//  Created by Komal Gupta on 27/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

/// User Profile - View User Information

class UserProfile: UIViewController, UITextFieldDelegate {
    
    /**
     *Name label to Display User Name
    */
    @IBOutlet var nameLabel: HoshiTextField!
    
    /**
     *Email label to Display User Email
     */
    @IBOutlet var emailLabel: HoshiTextField!
    
    /**
     *Role label to Display User Role
     */
    @IBOutlet var roleLabel: HoshiTextField!
    
    /**
     * Every individual has its unique pin
    */
    @IBOutlet var pinCode: HoshiTextField!
    /**
     * Indicator to let user know about data loading
     */
    var indicator = UIActivityIndicatorView()
    
    //MARK: - Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Custom Loading Indicator
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = self.view.center
        indicator.backgroundColor = UIColor.clear
        indicator.color = UIColor.black
        indicator.startAnimating()
        
        self.view.addSubview(indicator)
        self.view.isUserInteractionEnabled = false
        self.view.window?.isUserInteractionEnabled = false
        
        if screenheight <= 480{
            nameLabel.font = UIFont.systemFont(ofSize: 11.0)
            emailLabel.font = UIFont.systemFont(ofSize: 11.0)
            roleLabel.font = UIFont.systemFont(ofSize: 11.0)
            pinCode.font = UIFont.systemFont(ofSize: 11.0)

        }
        
        if IsConnectionAvailable(){
            self.ViewProfile()
        }
        else{
            let alert = ShowAlert()
            alert.title = "BrightUs"
            alert.message = "Check the internet connection on your device"
            _ = self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - Button Action

    /**
     Back Button Action
     
     - paramater description : Pop Controller to Previous View
 
    */
    @IBAction func BackButtonAction(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)            //Testing Required
    }
    
    //MARK: - API Request
    /**
     View Profile Request
 
     - parameter method : GET
     
     - parameter return : Name, Email, Role
     
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
                                
                                DispatchQueue.main.async {
                                    self.nameLabel.text = dict.value(forKey: "name") as? String
                                    self.emailLabel.text = dict.value(forKey: "email") as? String
                                    self.roleLabel.text = dict.value(forKey: "role") as? String
                                    self.pinCode.text = dict.value(forKey: "pin") as? String
                                    
                                }
                            }
                        }
                    }
                }
                else if let error = error{
                    DispatchQueue.main.async {
                        self.indicator.removeFromSuperview()
                        self.view.isUserInteractionEnabled = true
                        self.view.window?.isUserInteractionEnabled = true
                        
                        let alert = self.ShowAlert()
                        alert.title = "BrightUs"
                        alert.message = error.localizedDescription
                        _ = self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            catch{
                print("Error")
            }
            }.resume()
        
        DispatchQueue.main.async {
            self.indicator.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
            self.view.window?.isUserInteractionEnabled = true
            
        }
    }
    
    //MARK: - Alert Controller
    
    /**
     Alert Controller Method
     
     - paramter return : Returns UIAlertController
     
     - parameter description : Method to intialize and add actions to alert controller
     */
    
    func ShowAlert() -> UIAlertController{
        let alertController = UIAlertController(title: "BrightUs", message: "Device not supported for this application", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            self.dismiss(animated: false, completion: nil)
            print("Cancel")
        }
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.dismiss(animated: false, completion: nil)
            print("Okay")
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        //        _ = self.present(alertController, animated: true, completion: nil)
        return alertController
    }

}
