//
//  DashboardView.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

class DashboardView: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func AttendanceDetailButtonPressed(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AttendanceDetail") as UIViewController
        self.navigationController?.show(vc, sender: nil)
    }
    
    
    @IBAction func ViewProfile(_ sender: UIButton) {
        let apiString = baseURL + "/api/user"
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
//Result
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
