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
    
    /**
     * Current Date will be displayed on this label
    */
    @IBOutlet var currentDateLabel: UILabel!
    
    /**
     * Greet user
    */
    @IBOutlet var greetingLabel: UILabel!
    
    /**
    *   Display User Name
    */
    @IBOutlet var userNameLabel: UILabel!
    
    
    @IBOutlet var checkInTimeValueLabel: UILabel!
    
    @IBOutlet var checkOutTimeValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Change Navigation Bar tint color according to theme
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 222.0/255.0, green: 60.0/255.0, blue: 77.0/255.0, alpha: 1.0)
        
        //Called class functions to display date and greet user
        currentDateLabel.text = "It's \(self.CurrentDateFormat())"
        self.DisplayGreetings()
        if let nameOfUser = defaults.value(forKey: "name") as? String{
            userNameLabel.text = "\(nameOfUser)"
        }
        

        //Display Check - In/Out time
        if isCheckedIn{
            if let checkInTime = defaults.value(forKey: "CheckInTime") as? String{
                if !checkInTime.isEmpty{
                    //Test
                    let value = ConvertTimeStampToRequiredHours(dateValue: "2016-12-19T07:25:57+0000")
//                    let value = ConvertTimeStampToRequiredHours(dateValue: checkInTime)
                    checkInTimeValueLabel.text = "\(value)"
                }
                else{
                    checkInTimeValueLabel.text = "Let's go"
                }
            }
            if let checkOutTime = defaults.value(forKey: "") as? String{
                if !checkOutTime.isEmpty{
                    let value = ConvertTimeStampToRequiredHours(dateValue: checkOutTime)
                    checkOutTimeValueLabel.text = "\(value)"
                }
                else{
                    checkOutTimeValueLabel.text = "Pending"
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Attendance Detail Button Action
     
     - parameter description : When user tap this button, app navigates to attendance detail section
     
    */
    @IBAction func AttendanceDetailButtonAction(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AttendanceDetail") as UIViewController
        self.navigationController?.show(vc, sender: nil)
    }
    
       
    //MARK: - Display Methods
    //MARK: - 
    
    /**
     Specify date format Methods
     
     - parameter return : Returns String Value in format of Day, Date Month
 
    */
    func CurrentDateFormat() -> String{
        let todaysDate = Date()
        
        let dateFormatOftodayDate = DateFormatter()
        
        dateFormatOftodayDate.dateFormat = "EEEE, dd MMMM"
        
        dateFormatOftodayDate.timeZone = NSTimeZone.local
        
        let returnDate = dateFormatOftodayDate.string(from: todaysDate)
        print(returnDate)
        return returnDate
    }
    
    
    /**
     Greet User Methods
     
     - parameter description : Method check the current time range and display morning, afternoon, night etc according to that.
     
    */
    func DisplayGreetings(){       //To Display Morning, Afternoon, Evening

        let hour = NSCalendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<12 :
            greetingLabel.text = "Good Morning!"

            print(NSLocalizedString("Morning", comment: "Morning"))
        case 12 :
            greetingLabel.text = "Good Afternoon!"

            print(NSLocalizedString("Noon", comment: "Noon"))
        case 13..<17 :
            greetingLabel.text = "Good Afternoon!"

            print(NSLocalizedString("Afternoon", comment: "Afternoon"))
        case 17..<22 :
            greetingLabel.text = "Good Evening!"

            print(NSLocalizedString("Evening", comment: "Evening"))
        default:
            greetingLabel.text = "Good Night!"

            print(NSLocalizedString("Night", comment: "Night"))
        }
    }
    
    /**
     Conversion of TimeStamp (ISO 8601) to required value
     
     - parameter argument : Date (String)
     
     - parameter return : Date in required format (String)
     
    */
    func ConvertTimeStampToRequiredHours(dateValue : String)-> String{
        let formatStyle = DateFormatter()
        formatStyle.timeZone = TimeZone.current
        formatStyle.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        formatStyle.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"   //"2016-12-19T07:25:57+0000"  ZZZZZ SSSS

        print(dateValue)
        let receivedDateTime = formatStyle.date(from: dateValue)
        
        print(receivedDateTime!)
        formatStyle.dateFormat = "HH:mm"
        let timeValue = formatStyle.string(from: receivedDateTime!)
        print(timeValue)
        return timeValue
    }
    
    
}
