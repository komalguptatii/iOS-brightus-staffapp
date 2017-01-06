//
//  DashboardView.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DashboardView: UIViewController,CLLocationManagerDelegate, UIScrollViewDelegate {
    
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
    
    /**
     * Label that displays Check-In Time
    */
    @IBOutlet var checkInTimeValueLabel: UILabel!
    
    /**
     * Label that displays Check-Out Time
     */
    @IBOutlet var checkOutTimeValueLabel: UILabel!
    
    /**
     * Intialized instance of CLLocationManager
     */
    
    var locationManager = CLLocationManager()
    
    /**
     * To keep check of access to mark attendance
     */
    var isAllowedToMarkAttendance = false

    /**
     * Display and give alert to user that whether he is allowed or not to mark attendance
    */
    @IBOutlet var locationUpdateLabel: UILabel!
    //MARK: - Methods
    //MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Change Navigation Bar tint color according to theme
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 222.0/255.0, green: 60.0/255.0, blue: 77.0/255.0, alpha: 1.0)
        
        //Called class functions to display date and greet user
        currentDateLabel.text = "It's \(self.CurrentDateFormat())"
        self.DisplayGreetings()
        
        performSelector(inBackground: #selector(DashboardView.ViewProfile), with: nil)
        performSelector(inBackground: #selector(DashboardView.GetTodayAttendanceDetail), with: nil)

        //StartUpdatingLocation()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let controller = self.parent as? HomeViewController
        let scrollView = controller?.mainScrollView

        scrollView?.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let nameOfUser = defaults.value(forKey: "name") as? String{
            userNameLabel.text = "\(nameOfUser)"
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        print(scrollView.contentOffset.x)
        if (scrollView.contentOffset.x >= self.view.frame.width){
            print("Observer added")

            NotificationCenter.default.addObserver(self, selector: #selector(DashboardView.MarkAttendanceOnServer), name: NSNotification.Name(rawValue: "MarkAttendanceOnServer"), object: nil)
        }

    }
    
    //MARK: - Button Action
    //MARK: -
    /**
     Attendance Detail Button Action
     
     - parameter description : When user tap this button, app navigates to attendance detail section
     
    */
    @IBAction func AttendanceDetailButtonAction(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AttendanceDetail") as UIViewController
        self.navigationController?.show(vc, sender: nil)
    }
    
    //MARK: - ScrollView Delegate
    
       
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
    
    //MARK: - TimeStamp Conversion
    //MARK: -

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

//        print(dateValue)
        let receivedDateTime = formatStyle.date(from: dateValue)
        
//        print(receivedDateTime!)
        formatStyle.dateFormat = "HH:mm a"
        let timeValue = formatStyle.string(from: receivedDateTime!)
//        print(timeValue)
        return timeValue
    }
    
    //MARK: - View Profile Request
    //MARK: -
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
                                
                                //Get User name from here
                                defaults.setValue(dict.value(forKey: "name")!, forKey: "name")
                                
                                DispatchQueue.main.async {
                                    if let nameOfUser = defaults.value(forKey: "name") as? String{
                                        self.userNameLabel.text = "\(nameOfUser)"
                                    }
                                    
                                }
                                //Get Latitude & longitude of branch
                                if let locationValues = dict.value(forKey: "allowed_locations") as? NSArray{
                                    print(locationValues)
                                    if let locationDict = locationValues.object(at: 0) as? NSDictionary{
                                        print(locationDict)
                                        defaults.setValue(locationDict.value(forKey: "lattitude"), forKey: "latitude")
                                        defaults.setValue(locationDict.value(forKey: "longitude"), forKey: "longitude")
                                    }
                                }
                                defaults.synchronize()
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

    
    //MARK: - Today's Attendance detail
    //MARK: -
    /**
     Today Attendance Detail Request
     
     - parameter return : Check - In/Out Time
     
     */
    func GetTodayAttendanceDetail(){
        let apiString = baseURL + "/api/user/attendance?filter=today"
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
                            
                            if let detailArray = dict.value(forKey: "data") as? NSArray{
                                print(detailArray)
                                if detailArray.count > 0{
                                    if let detailDictionary = detailArray.object(at: 0) as? NSDictionary{
                                        print(detailDictionary)
                                        if let checkInValue = detailDictionary.value(forKey: "check_in") as? String{
                                            if checkInValue.isEmpty{
                                                isCheckedIn = false
                                                DispatchQueue.main.async {
                                                    self.checkInTimeValueLabel.text = "Let's go"

                                                }
                                                
                                            }
                                            else{
                                                //Here it means check in time is there already
                                                DispatchQueue.main.async {
                                                    isCheckedIn = true
                                                    let value = self.ConvertTimeStampToRequiredHours(dateValue: checkInValue)
                                                    self.checkInTimeValueLabel.text = "\(value)"
                                                    
                                                    if let checkOutValue = detailDictionary.value(forKey: "check_out") as? String{
                                                        if !checkOutValue.isEmpty{
                                                            let value = self.ConvertTimeStampToRequiredHours(dateValue: checkOutValue)
                                                            self.checkOutTimeValueLabel.text = "\(value)"
                                                            
                                                        }
                                                        else{
                                                            self.checkOutTimeValueLabel.text = "Pending"
                                                            
                                                        }
                                                    }
                                                }
                                               
                                            }
                                        }
                                    }
                                    
                                }
                                else{
                                    DispatchQueue.main.async {
                                        self.checkInTimeValueLabel.text = "Let's go"
                                        self.checkOutTimeValueLabel.text = "Pending"
                                        isCheckedIn = false
                                    }
                                    
                                }
                            }
                            

                            
                        }
                        else if httpResponseValue.statusCode == 401{
                            let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                            print(dict)
                            
                        }
                    }
                }
            }
            catch{
                print(error)
            }
            }.resume()
    }

    //MARK: - Location Methods
    //MARK: -
    
    /**
     Authorization Status to use location method
     */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    /**
     Update Location Method
     
     - parameter description : Check whether user is in premises or not
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print (locations)
        if let location = locations.first {
            print(location)
            
            // Techies Office Location = 30.892668,75.8225618
            // Grand Walk Location = 30.8868835,75.7906816
//            let destinationLatitude = defaults.value(forKey: "latitude") as? Double
//            let destinationLongitude = defaults.value(forKey: "longitude") as? Double
            
            let destinationLatitude = 30.892668
            let destinationLongitude = 75.8225618

            //TODO - Testing Pending as not receiving lat long yet
            let destination = CLLocation(latitude: destinationLatitude, longitude: destinationLongitude)
            
            let distance = location.distance(from: destination)
            print(distance)
            
            let distanceDouble = Double(distance)
            print(distanceDouble)
            let controller = self.parent as? HomeViewController
            let scrollView = controller?.mainScrollView

            if (distanceDouble <= 300.00){
//                if (location.verticalAccuracy * 0.5 <= destination.verticalAccuracy * 0.5){
                
                    print("in premises")
                    //Checkin
                    isAllowedToMarkAttendance = true
                scrollView?.isScrollEnabled = true
                locationUpdateLabel.text = "You are allowed to mark attendance"
                locationManager.stopUpdatingLocation()

                
            }else{
                print("out of premises")
                locationUpdateLabel.text = "You are not allowed to mark attendance"

                //Cant check in
                isAllowedToMarkAttendance = false
                scrollView?.isScrollEnabled = false
                
            }
        }
    }

    
    /**
     Mark Attendance Request
     
     - parameter sent : type i.e. check_in,check_out
     
     */

    func MarkAttendanceOnServer(){
        NotificationCenter.default.removeObserver(self)

        let apiString = baseURL + "/api/user/attendance"
        let encodedApiString = apiString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: encodedApiString!)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = defaults.value(forKey: "accessToken") as! String
        
        let header = "Bearer" + " \(token)"
        print(header)
        
        request.setValue(header, forHTTPHeaderField: "Authorization")
        
        let jsonDict = NSMutableDictionary()
        
        if isCheckedIn{
            jsonDict.setValue("check_out", forKey: "type")
        }
        else{
            jsonDict.setValue("check_in", forKey: "type")
        }
        
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
                                }
                                self.performSelector(inBackground: #selector(DashboardView.GetTodayAttendanceDetail), with: nil)

                            }
                        }
                    }
                }
                catch{
                    print(error)
                }
                }.resume()
        }
        catch{
            print("Error")
        }
        
        
    }

}
