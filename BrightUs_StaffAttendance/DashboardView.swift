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

/// Dashboard View - Display time, greet user , check - in/out timings, Mark Attendance

class DashboardView: BaseViewController,CLLocationManagerDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    /**
     * Dashboard Table View which holds the all detail
    */
    @IBOutlet var dashboardTableView: UITableView!
    
    /**
     * Mark Attendance Button
    */
    @IBOutlet var markAttendanceButton: UIButton!
    
    /**
     * Current Date will be displayed on this label
     */
    var currentDateLabel = UILabel()
    
    /**
     * Greet user
     */
    var greetingLabel = UILabel()
    
    /**
     *   Display User Name
     */
    var userNameLabel = UILabel()
    
    /**
     * Label that displays Check-In Time
     */
    var checkInTimeValueLabel = UILabel()
    
    /**
     * Label that displays Check-Out Time
     */
    var checkOutTimeValueLabel = UILabel()
    
    /**
     * Intialized instance of CLLocationManager
     */
    
    var locationManager = CLLocationManager()
    
    /**
     * Time Image - Display morning, afternoon, evening images
     */
    var timeImage = UIImageView()
    

    /**
     * To keep check of access to mark attendance
     */
    var isAllowedToMarkAttendance = false
    
    /**
     * Instance of Camera Class
    */
    let cameraController = Camera()
    
    
    /**
     * Indicator to let user know about data loading
     */
    var indicator = UIActivityIndicatorView()
    
    /**
     * rowsForSectionTwo - Update number of rows in dashboard table view
    */
    var rowsForSectionTwo = 0

    var noOfTimesMarkAttendanceCalled = 2
    
    //MARK: - Methods
    
    /**
    * viewDidLoad Method
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Custom Loading Indicator
        indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = self.view.center
        indicator.backgroundColor = UIColor.clear
        indicator.color = UIColor.black

        indicator.startAnimating()
//        self.view.isUserInteractionEnabled = false
//        self.view.addSubview(indicator)
//        self.view.bringSubview(toFront: indicator)
        
        dashboardTableView.delegate = self
        dashboardTableView.dataSource = self
        dashboardTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        //Called class functions to display date and greet user
        currentDateLabel.text = "It's \(self.CurrentDateFormat())"
        self.DisplayGreetings()
        
        DispatchQueue.main.async {
            if let nameOfUser = defaults.value(forKey: "name") as? String{
                self.userNameLabel.text = "\(nameOfUser)"
            }
            
        }
        
        if IsConnectionAvailable(){
           
            performSelector(inBackground: #selector(DashboardView.GetTodayAttendanceDetail), with: nil)
        }
        else{
            
            self.indicator.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
            self.view.window?.isUserInteractionEnabled = true
            
            let alert = self.ShowAlert()
            alert.title = "BrightUs"
            alert.message = "Check the internet connection on your device"
            _ = self.present(alert, animated: true, completion: nil)
            
        }
        
        
        //StartUpdatingLocation()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let controller = self.parent as? HomeViewController
        let scrollView = controller?.mainScrollView
        
        scrollView?.delegate = self
        

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
//        let controller = self.parent as? HomeViewController
//        controller?.title = "Dashboard"
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        if let nameOfUser = defaults.value(forKey: "name") as? String{
            userNameLabel.text = "\(nameOfUser)"
        }
        
        DispatchQueue.main.async {
            self.dashboardTableView.reloadData()
        }
    }
    
    
    //MARK: - TableView Delegate & Datasource
    
    /**
     Number of Sections in TableView
     
     - parameter return : number of sections
     
     */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    /**
     Number of Rows in Section
     
     - parameter return : number of rows in one section
     
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        return rowsForSectionTwo
    }

    /**
     Height of Row
     
     - parameter return : CGFLoat (height)
     
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 317.0
        }
        else{
            return 120.0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let greetingCell = tableView.dequeueReusableCell(withIdentifier: "GreetCell", for: indexPath) as! TiiGreetingCell
            
            greetingCell.greetingImage.image = timeImage.image
            greetingCell.userName.text = userNameLabel.text
            greetingCell.todaysDateTime.text = currentDateLabel.text
            greetingCell.wishes.text = greetingLabel.text
            
            greetingCell.selectionStyle = UITableViewCellSelectionStyle.none
            return greetingCell
        }
        else{
            let checkInOutCell = tableView.dequeueReusableCell(withIdentifier: "CheckCell", for: indexPath) as! TiiCheckInOutCell
            
            if indexPath.row == 0{
                checkInOutCell.checkInOutImage.image = UIImage(named: "green-man")!
                checkInOutCell.timeLabel.text = checkInTimeValueLabel.text
                checkInOutCell.indicationLabel.text = "Check-in Time"
            }
            
            if indexPath.row == 1{
                checkInOutCell.checkInOutImage.image = UIImage(named: "red-man")!
                checkInOutCell.timeLabel.text = checkOutTimeValueLabel.text
                checkInOutCell.indicationLabel.text = "Check-out Time"

            }
            checkInOutCell.selectionStyle = UITableViewCellSelectionStyle.none

            return checkInOutCell
        }
        
    }
    
    //MARK: - ScrollView Delegate
    /**
     scrollViewDidEndDecelerating Method
     
        - parameter argument : UIScrollView
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        print(scrollView.contentOffset.x)
        if (scrollView.contentOffset.x >= self.view.frame.width){
            print("Observer added")
            //Code removed from here and to Button action "Tap to MArk Attendance"

        }
        else if (scrollView.contentOffset.x <= self.view.frame.width){
           
            let controller = self.parent as? HomeViewController
            controller?.mainScrollView.contentSize = CGSize(width: (self.view.frame.width), height: (self.view.frame.height))

            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "remove"), object: nil)
            

        }
        
    }
    
    //MARK: - Remove Controller Action
    /**
     Remove Controller Action
     
     - Camera Controller will be removed once the attendance marked on server
     
     */
    
    func RemoveController(){
        cameraController.vwQRCode?.frame = CGRect.zero
        
        cameraController.objCaptureSession?.stopRunning()
        cameraController.didMove(toParentViewController: nil)
        cameraController.view.removeFromSuperview()
        cameraController.removeFromParentViewController()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "remove"), object: nil)
    }

    
    //MARK: - Button Action
    /**
     Attendance Detail Button Action
     
     - parameter description : When user tap this button, app navigates to attendance detail section
     
     */
    
    @IBAction func TaptoMarkAttendance(_ sender: UIButton) {
        
        self.noOfTimesMarkAttendanceCalled = 2
        
        let controller = self.parent as? HomeViewController
//        controller?.title = "Mark Attendance"
//        controller?.navigationItem.leftBarButtonItem?.isEnabled = false
        
        
        controller?.addChildViewController(cameraController)
        controller?.mainScrollView.addSubview(cameraController.view)
        cameraController.didMove(toParentViewController: self)
        
        // Double the scroll view size when added new camera controller as child
        controller?.mainScrollView.contentSize = CGSize(width: (self.view.frame.width * 2), height: (self.view.frame.height))

//        controller?.mainScrollView.contentSize = CGSize(width: (self.view.frame.width * 2), height: (self.view.frame.height - 64))
        //
        
        cameraController.vwQRCode?.frame = CGRect.zero
        
        cameraController.objCaptureSession?.startRunning()
        
        var cameraFrame : CGRect = cameraController.view.frame
        cameraFrame.origin.x = self.view.frame.width
        cameraController.view.frame = cameraFrame
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardView.MarkAttendanceOnServer), name: NSNotification.Name(rawValue: "MarkAttendanceOnServer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardView.RemoveController), name: NSNotification.Name(rawValue: "remove"), object: nil)
        
        //Automatic Swipe - always set content offset
        controller?.mainScrollView.contentOffset = CGPoint(x: self.view.frame.width, y: 0.0)
        
        //Changed "Y" as navgation bar is excluded
//        controller?.mainScrollView.contentOffset = CGPoint(x: self.view.frame.width, y: 64.0)
        
    }
    
    
    //MARK: - Display Methods
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
            
            timeImage.image = UIImage(named: "morning-bg")
            print(NSLocalizedString("Morning", comment: "Morning"))
        case 12 :
            greetingLabel.text = "Good Afternoon!"
            timeImage.image = UIImage(named: "afternoon-bg")
            
            print(NSLocalizedString("Noon", comment: "Noon"))
        case 13..<17 :
            greetingLabel.text = "Good Afternoon!"
            timeImage.image = UIImage(named: "afternoon-bg")
            
            print(NSLocalizedString("Afternoon", comment: "Afternoon"))
        case 17..<22 :
            greetingLabel.text = "Good Evening!"
            timeImage.image = UIImage(named: "evening-bg")
            
            print(NSLocalizedString("Evening", comment: "Evening"))
        default:
            greetingLabel.text = "Good Night!"
            timeImage.image = UIImage(named: "evening-bg")
            
            print(NSLocalizedString("Night", comment: "Night"))
        }
    }

    //MARK: - TimeStamp Conversion
    
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
        formatStyle.dateFormat = "hh:mm a"
        let timeValue = formatStyle.string(from: receivedDateTime!)
        //        print(timeValue)
        return timeValue
    }
    
    
    
    //MARK: - Today's Attendance detail
    /**
     Today Attendance Detail Request
     
     - parameter return : Check - In/Out Time
     
     */
    func GetTodayAttendanceDetail(){
       
        DispatchQueue.main.async {
            self.indicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            self.view.addSubview(self.indicator)
            self.view.bringSubview(toFront: self.indicator)
            
        }
        
        if IsConnectionAvailable(){
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
                    
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.indicator.removeFromSuperview()
                    }
                    
                    if data != nil{
                        if let httpResponseValue = response as? HTTPURLResponse{
                            print(httpResponseValue.statusCode)
                            if httpResponseValue.statusCode == 200{
                                let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                                print(dict)
                                
                                //                            let controller = self.parent as? HomeViewController
                                //                            let scrollView = controller?.mainScrollView
                                
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
                                                    self.markAttendanceButton.alpha = 1.0
                                                    self.markAttendanceButton.setImage(UIImage(named: "green-checkin"), for: UIControlState.normal)
                                                    
                                                }
                                                else{
                                                    //Here it means check in time is there already
                                                    DispatchQueue.main.async {
                                                        isCheckedIn = true
                                                        let value = self.ConvertTimeStampToRequiredHours(dateValue: checkInValue)
                                                        self.checkInTimeValueLabel.text = "\(value)"
                                                        if self.rowsForSectionTwo < 1{
                                                            self.rowsForSectionTwo = 1
                                                            self.dashboardTableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: UITableViewRowAnimation.fade)
                                                            
                                                        }
                                                        
                                                        
                                                    }
                                                    
                                                    if let checkOutValue = detailDictionary.value(forKey: "check_out") as? String{
                                                        print(checkOutValue)
                                                        if !checkOutValue.isEmpty{
                                                            DispatchQueue.main.async {
                                                                let value = self.ConvertTimeStampToRequiredHours(dateValue: checkOutValue)
                                                                self.checkOutTimeValueLabel.text = "\(value)"
                                                                self.markAttendanceButton.alpha = 0.0
                                                                if self.rowsForSectionTwo < 2{
                                                                    self.rowsForSectionTwo = 2
                                                                    self.dashboardTableView.insertRows(at: [IndexPath(row: 1, section: 1)], with: UITableViewRowAnimation.fade)
                                                                    
                                                                }
                                                            }
                                                        }
                                                        else{
                                                            DispatchQueue.main.async {
                                                                self.checkOutTimeValueLabel.text = "Pending"
                                                                self.markAttendanceButton.alpha = 1.0
                                                                self.markAttendanceButton.setImage(UIImage(named: "red-checkin"), for: UIControlState.normal)
                                                            }
                                                        }
                                                    }
                                                    else{
                                                        DispatchQueue.main.async {
                                                            self.checkOutTimeValueLabel.text = "Pending"
                                                            self.markAttendanceButton.alpha = 1.0
                                                            self.markAttendanceButton.setImage(UIImage(named: "red-checkin"), for: UIControlState.normal)
                                                        }
                                                        
                                                    }
                                                    
                                                    
                                                }
                                            }
                                            else{
                                                DispatchQueue.main.async {
                                                    self.checkInTimeValueLabel.text = "Let's go"
                                                    self.markAttendanceButton.alpha = 1.0
                                                    self.markAttendanceButton.setImage(UIImage(named: "green-checkin"), for: UIControlState.normal)
                                                    
                                                }
                                            }
                                        }
                                        
                                        
                                    }
                                    else{
                                        DispatchQueue.main.async {
                                            self.checkInTimeValueLabel.text = "Let's go"
                                            self.checkOutTimeValueLabel.text = "Pending"
                                            self.markAttendanceButton.alpha = 1.0
                                            self.markAttendanceButton.setImage(UIImage(named: "green-checkin"), for: UIControlState.normal)
                                            
                                            isCheckedIn = false
                                        }
                                        
                                    }
                                }
                                
                                //                            DispatchQueue.main.async {
                                //                                self.dashboardTableView.endUpdates()
                                
                                //                                let sectionNumber = NSIndexSet(index: 1)
                                //
                                //                                self.dashboardTableView.reloadSections(sectionNumber as IndexSet, with: UITableViewRowAnimation.none)
                                //                            }
                                
                                
                            }
                            else if httpResponseValue.statusCode == 401{
                                let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                                print(dict)
                                
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
                    print(error)
                    
                    //TODO: Remove indicator
                    
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.indicator.removeFromSuperview()
                    }
                }
                }.resume()

        }
        else{
            DispatchQueue.main.async {
                self.indicator.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
                self.view.window?.isUserInteractionEnabled = true
                
                let alert = self.ShowAlert()
                alert.title = "BrightUs"
                alert.message = "Check the internet connection on your device"
                _ = self.present(alert, animated: true, completion: nil)
            }

        }
        
        
    }
    
    //MARK: - Location Methods
    
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
            
//            locationUpdateLabel.text = "You are allowed to mark attendance"
            locationManager.stopUpdatingLocation()
            // Techies Office Location = 30.892668,75.8225618
            // Grand Walk Location = 30.8868835,75.7906816
//            if let destinationLatitude = defaults.value(forKey: "latitude") as? Double{
//                
//                if let destinationLongitude = defaults.value(forKey: "longitude") as? Double{
//                    print("destinationLatitude - \(destinationLatitude)")
//                    print("destinationLongitude - \(destinationLongitude)")
//                    
//                    //TODO - Testing Pending as not receiving lat long yet
//                    let destination = CLLocation(latitude: destinationLatitude, longitude: destinationLongitude)
//                    
//                    let distance = location.distance(from: destination)
//                    print(distance)
//                    
//                    let distanceDouble = Double(distance)
//                    print(distanceDouble)
//                    let controller = self.parent as? HomeViewController
//                    let scrollView = controller?.mainScrollView
//                    
//                    if (distanceDouble <= 300.00){
//                        //                if (location.verticalAccuracy * 0.5 <= destination.verticalAccuracy * 0.5){
//                        
//                        print("in premises")
//                        //Checkin
//                        isAllowedToMarkAttendance = true
//                        scrollView?.isScrollEnabled = true
//                        locationUpdateLabel.text = "You are allowed to mark attendance"
//                        locationManager.stopUpdatingLocation()
//                        
//                        
//                    }else{
//                        print("out of premises")
//                        locationUpdateLabel.text = "You are not allowed to mark attendance"
//                        
//                        //Cant check in
//                        isAllowedToMarkAttendance = false
//                        scrollView?.isScrollEnabled = false
//                        
//                    }
//                    
//                }
//                
//            }
            
            //            let destinationLatitude = 30.892668
            //            let destinationLongitude = 75.8225618
            
        }
    }
    
    
    /**
     Mark Attendance Request
     
     - parameter sent : type i.e. check_in,check_out
     
     */
    
    func MarkAttendanceOnServer(){
        
        self.view.isUserInteractionEnabled = false
        self.view.addSubview(indicator)
        self.view.bringSubview(toFront: indicator)
        
        let controller = self.parent as? HomeViewController
        
        controller?.title = "Dashboard"
        controller?.navigationItem.leftBarButtonItem?.isEnabled = true


        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "remove"), object: nil)
        
        if IsConnectionAvailable(){
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
                                    
                                    self.noOfTimesMarkAttendanceCalled = 2
                                    
                                    if let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as?  NSDictionary{
                                        print(dict)
                                    }

                                    self.performSelector(inBackground: #selector(DashboardView.GetTodayAttendanceDetail), with: nil)
                                    
                                    
                                }
                                else{
                                    if self.noOfTimesMarkAttendanceCalled <= 2 && self.noOfTimesMarkAttendanceCalled > 0{
                                        self.noOfTimesMarkAttendanceCalled -= 1

                                        self.MarkAttendanceOnServer()
                                    }
                                    else{
                                        self.view.isUserInteractionEnabled = true
                                        self.view.window?.isUserInteractionEnabled = true

                                        let alert = self.ShowAlert2()
                                        _ = self.present(alert, animated: true, completion: nil)
                                        

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
                    catch {
                        print(error)
                        //TODO: Remove indicator
                    }
                    }.resume()
            }
            catch{
                print("Error")
            }
            
        }
        else{
            
            DispatchQueue.main.async {
                self.indicator.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
                self.view.window?.isUserInteractionEnabled = true
                
                let alert = self.ShowAlert()
                alert.title = "BrightUs"
                alert.message = "Check the internet connection on your device"
                _ = self.present(alert, animated: true, completion: nil)
            }
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
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.dismiss(animated: false, completion: nil)
            print("Okay")
        }
        alertController.addAction(okAction)
        return alertController
    }
    
    func ShowAlert2() -> UIAlertController{
        let alertController = UIAlertController(title: "BrightUs", message: "We are unable to mark your attendance, Please try again", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.dismiss(animated: false, completion: nil)
            print("Okay")
        }
        
        let retryAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.MarkAttendanceOnServer()
            self.dismiss(animated: false, completion: nil)
            print("Retry")
        }
        alertController.addAction(okAction)
        alertController.addAction(retryAction)

        return alertController
    }
    
    //MARK: - Button Action
    /**
     Menu Button Action
     
     - parameter description : Slider Menu will be shown to user
     
     */
    @IBAction func MenuButtonPressed(_ sender: Any) {
        self.onSlideMenuButtonPressed(sender as! UIButton)
    }

    
}
