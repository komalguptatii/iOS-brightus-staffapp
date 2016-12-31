//
//  UserProfile.swift
//  BrightUs_StaffAttendance
//
//  Created by Komal Gupta on 27/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add Loading Indicator
        self.ViewProfile()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     Back Button Action
     
     - paramater description : Pop Controller to Previous View
 
    */
    @IBAction func BackButtonAction(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)            //Testing Required
    }
    
    //MARK: - 
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
                            let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                            print(dict)
                    
                            DispatchQueue.main.async {
                                self.nameLabel.text = dict.value(forKey: "name") as? String
                                self.emailLabel.text = dict.value(forKey: "email") as? String
                                self.roleLabel.text = dict.value(forKey: "role") as? String

                            }
                            
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
