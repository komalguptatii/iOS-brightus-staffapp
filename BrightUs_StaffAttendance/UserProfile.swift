//
//  UserProfile.swift
//  BrightUs_StaffAttendance
//
//  Created by Komal Gupta on 27/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

class UserProfile: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func BackButtonAction(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)            //Testing Required
    }
    
    //TODO
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
                            //                            {
                            //                                "created_at" = "2016-12-15T11:37:58+0000";
                            //                                email = "staff@maildrop.cc";
                            //                                id = 2;
                            //                                name = "Johd doe staff";
                            //                                role = reception;
                            //                                "updated_at" = "2016-12-15T11:37:58+0000";
                            //                                "user_type" = staff;
                            //                            }
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
