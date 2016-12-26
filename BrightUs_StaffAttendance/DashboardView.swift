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
    
    
    @IBOutlet var currentDateLabel: UILabel!
    @IBOutlet var greetingLAbel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 222.0/255.0, green: 60.0/255.0, blue: 77.0/255.0, alpha: 1.0)
        
        currentDateLabel.text = "It's \(self.CurrentDateFormat())"
        self.DisplayGreetings()
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
//TODO : Result
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
    
    
    func CurrentDateFormat() -> String{
        let todaysDate = Date()
        
        let dateFormatOftodayDate = DateFormatter()
        
        dateFormatOftodayDate.dateFormat = "EEEE, dd MMMM"
        
        dateFormatOftodayDate.timeZone = NSTimeZone.local
        
        let returnDate = dateFormatOftodayDate.string(from: todaysDate)
        print(returnDate)
        return returnDate
    }
    
    
    //TODO
    
    func DisplayGreetings(){       //To Display Morning, Afternoon, Evening

        let hour = NSCalendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<12 :
            greetingLAbel.text = "Good Morning!"

            print(NSLocalizedString("Morning", comment: "Morning"))
        case 12 :
            greetingLAbel.text = "Good Afternoon!"

            print(NSLocalizedString("Noon", comment: "Noon"))
        case 13..<17 :
            greetingLAbel.text = "Good Afternoon!"

            print(NSLocalizedString("Afternoon", comment: "Afternoon"))
        case 17..<22 :
            greetingLAbel.text = "Good Evening!"

            print(NSLocalizedString("Evening", comment: "Evening"))
        default:
            greetingLAbel.text = "Good Night!"

            print(NSLocalizedString("Night", comment: "Night"))
        }
    }
}
