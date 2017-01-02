//
//  DetailsViewController.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

/// Attendance Details 
class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    /**
     * Table View to display attendance details
    */
    @IBOutlet var detailTableView: UITableView!
    
    /**
     * Picker View to select filters
    */
    @IBOutlet var filterPickerView: UIPickerView!
    
    /**
     * From Date Button i.e. start date from which user want to see the details
    */
    @IBOutlet var fromDateButton: UIButton!
    
    /**
     * From Date Button i.e. end date upto which user want to see the details
     */
    @IBOutlet var toDateButton: UIButton!
    
    /**
     * Date Picker View Outler
    */
    @IBOutlet var datePickerView: UIDatePicker!
   
    /**
     * Array of values marked as filters
    */
    var filterValueArray = ["today","yesterday", "this week", "last week", "this month", "last month", "custom"]
    
    /**
     * Array that hold the detail fetched temporarily to be displayed
    */
    var attendanceDetailArray = NSMutableArray()
    
    /**
     * Selected Filer Value, default is "Today"
    */
    var selectedFilter = "today"
    
    /**
     * Bool to check that From Date is selected before moving to selection of End date
    */
    var isSelectedFromDate = false
    
    /**
     *
    */
    var currentPage = 1
    
    var totalNoOfPages = 0
    var checkCurrentPage = 1
    
    var selectedFromDate = ""
    var selectedToDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        detailTableView.backgroundColor = UIColor.clear
        
        
        
        filterPickerView.delegate = self
        filterPickerView.dataSource = self
        filterPickerView.isHidden = true
        filterPickerView.isUserInteractionEnabled = false
        
        datePickerView.isHidden = true
        datePickerView.isUserInteractionEnabled = false
        datePickerView.maximumDate = Date()
        
        datePickerView.addTarget(self, action: #selector(DetailsViewController.DatePickerValueSelected(sender:)), for: UIControlEvents.valueChanged)
        
        fromDateButton.isUserInteractionEnabled = false
        toDateButton.isUserInteractionEnabled = false
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Back Button Action
     
     - paramater description : Pop Controller to Previous View
     
     */

    @IBAction func BackButtonAction(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)

    }
    
    
    @IBAction func SearchButtonAction(_ sender: UIButton) {
        self.GetAttendanceDetails()
    }
    
    /**
     Filter Action
     
     - paramater description : Display picker view to select filter
     
     */

    @IBAction func FilterAction(_ sender: UIBarButtonItem) {
        filterPickerView.isHidden = false
        filterPickerView.isUserInteractionEnabled = true

        self.view.bringSubview(toFront: filterPickerView)

    }
    
    /**
     From Date Button Action
     
     - parameter description : Display date picker view to select date as "From Date"
     
    */
    @IBAction func FromDateButtonAction(_ sender: UIButton) {
        datePickerView.isHidden = false
        datePickerView.isUserInteractionEnabled = true
        
        datePickerView.setDate(Date(), animated: false)
        datePickerView.tag = 1
        
    }
    
    /**
     To Date Button Action
     
     - parameter description : Display date picker view to select date as "To Date"
     
     */

    @IBAction func ToDateButtonAction(_ sender: UIButton) {
        if isSelectedFromDate{
            datePickerView.isHidden = false
            datePickerView.isUserInteractionEnabled = true
            datePickerView.setDate(Date(), animated: false)
            datePickerView.tag = 2

        }
        else{
            print("Please select the From Date first")
        }

    }
    
    /**
     Date Picker Selected Value Method
     
     - parameter description : To deal with the selected date, this method is target for date picker view
     
     */

    func DatePickerValueSelected(sender : UIDatePicker){
        
        let selectedDateFormatter = DateFormatter()
        selectedDateFormatter.dateFormat = "dd-MM-yyyy"
        
        
        if sender.tag == 1{
            isSelectedFromDate = true
            selectedFromDate = selectedDateFormatter.string(from: sender.date)
            fromDateButton.setTitle(selectedFromDate, for: UIControlState.normal)
        }
        else{
            selectedToDate = selectedDateFormatter.string(from: sender.date)
            toDateButton.setTitle(selectedToDate, for: UIControlState.normal)
        }
        
        datePickerView.isHidden = true
        datePickerView.isUserInteractionEnabled = false
        self.view.endEditing(true)
    }
    
    //MARK: - TableView Delegate & Datasource
    //MARK: - 
    
    /**
     Number of Sections in TableView
     
     - parameter return : number of sections
 
    */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     Number of Rows in Section 
     
     - parameter return : number of rows in one section
 
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return attendanceDetailArray.count
        return attendanceDetailArray.count
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    /**
    Definition of Cell
     
     - parameter return : TiiAttendanceDetailCell 
     
     - parameter defined_Terms : particularDate, checkinTime, checkOutTime, totalTime
 
    */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TiiAttendanceDetailCell
        
        let dict = attendanceDetailArray.object(at: (indexPath as NSIndexPath).section) as! NSDictionary
        print(dict)
        
        cell.particularDate.text = ConvertTimeStampToRequiredHours(dateValue: "\(dict.value(forKey: "check_in")!)").0
        
        let checkinTimeValue = ConvertTimeStampToRequiredHours(dateValue: "\(dict.value(forKey: "check_in")!)").1
        print(checkinTimeValue)
        cell.checkinTime.text = "\(checkinTimeValue)"
        
        let checkInHours = ConvertTimeStampToRequiredHours(dateValue: "\(dict.value(forKey: "check_in")!)").2
        print(checkInHours)
        
        let checkInMinutes = ConvertTimeStampToRequiredHours(dateValue: "\(dict.value(forKey: "check_in")!)").3
        print(checkInMinutes)

        let checkOutTimeValue = ConvertTimeStampToRequiredHours(dateValue: "\(dict.value(forKey: "check_out")!)").1
        print(checkOutTimeValue)
        cell.checkOutTime.text = "\(checkOutTimeValue)"
        
        let checkOutHours = ConvertTimeStampToRequiredHours(dateValue: "\(dict.value(forKey: "check_out")!)").2
        print(checkOutHours)
        
        let checkOutMinutes = ConvertTimeStampToRequiredHours(dateValue: "\(dict.value(forKey: "check_out")!)").3
        print(checkOutMinutes)
        
        let totalHourValue = Int(checkOutHours)! - Int(checkInHours)!
        let totalMinuteValue = Int(checkOutMinutes)! - Int(checkInMinutes)!

        cell.totalTime.text = "\(totalHourValue)h \(totalMinuteValue)min"
        
        return cell
    }

    
    //MARK: - Picker View Delegate & datasources
    
    /**
     Picker View Delegate & Datasources
        
     - parameter methodsInAction : numberOfComponents, numberOfRowsInComponent, titleForRow, didSelectRow
     
    */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filterValueArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filterValueArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.attendanceDetailArray.removeAllObjects()
        
        selectedFilter = filterValueArray[row]
        print(selectedFilter)
        if selectedFilter == "custom"{
            fromDateButton.isUserInteractionEnabled = true
            toDateButton.isUserInteractionEnabled = true
        }
        else if selectedFilter == "this week"{
            selectedFilter = "this_week"
        }
        else if selectedFilter == "last week"{
            selectedFilter = "last_week"

        }
        else if selectedFilter == "this month"{
            selectedFilter = "this_month"
        }
        else if selectedFilter == "last month"{
            selectedFilter = "last_month"
        }
        
        if selectedFilter != "custom"{
            self.GetAttendanceDetails()
        }
        
        filterPickerView.isHidden = true
        filterPickerView.isUserInteractionEnabled = false

        filterPickerView.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollViewContentSizeHeight = scrollView.contentSize.height
        let scrollViewContentOfSetY = scrollView.contentOffset.y
        print("\(scrollViewContentOfSetY), \(scrollViewHeight),\(scrollViewContentSizeHeight)")
        if (scrollViewContentOfSetY + scrollViewHeight == scrollViewContentSizeHeight) {
            if currentPage < totalNoOfPages{
                currentPage = currentPage + 1
                self.GetAttendanceDetails()
            }
        }
    }
    /**
     Attendance Detail Request
     
     - parameter method : GET
     
    */
    func GetAttendanceDetails(){
        
        var stringToBePassed = ""
        
        if selectedFilter == "custom"{
            //Send From Date & To Date
            stringToBePassed = "/api/user/attendance?filter=\(selectedFilter)&page=\(currentPage)&from=\(selectedFromDate)&to=\(selectedToDate)"
        }
        else{
            stringToBePassed = "/api/user/attendance?filter=\(selectedFilter)&page=\(currentPage)"
        }
        let apiString = baseURL + stringToBePassed
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
                            
                            self.totalNoOfPages = dict.value(forKey: "last_page") as! Int
                            self.currentPage = dict.value(forKey: "current_page") as! Int
                            
                            if let detailArray = dict.value(forKey: "data") as? NSArray{
                                print(detailArray)
//                                self.attendanceDetailArray = detailArray.mutableCopy() as! NSArray
                                self.attendanceDetailArray.addObjects(from: detailArray.mutableCopy() as! [AnyObject])

                                DispatchQueue.main.async {
                                        //Section is 1
                                        //Pagination Required + Fetch and display details on tableView
                            
                                    self.detailTableView.reloadData()
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
    
    /**
     Conversion of TimeStamp (ISO 8601) to required value
     
     - parameter argument : Date (String)
     
     - parameter return : Date, Time, Hours, Minutes in required format (String)
     
     */
    func ConvertTimeStampToRequiredHours(dateValue : String)-> (String,String, String, String){
        let formatStyle = DateFormatter()
        print(dateValue)
        formatStyle.timeZone = TimeZone.current
        formatStyle.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        formatStyle.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"   //"2016-12-19T07:25:57+0000"  ZZZZZ SSSS
        
        print(dateValue)
        let receivedDateTime = formatStyle.date(from: dateValue)
        
        print(receivedDateTime!)
        formatStyle.dateFormat = "dd EEEE,yyyy"
        let dateValue = formatStyle.string(from: receivedDateTime!)
        
        formatStyle.dateFormat = "HH:mm a"
        let timeValue = formatStyle.string(from: receivedDateTime!)
        print(timeValue)

        formatStyle.dateFormat = "HH"
        let hourValue = formatStyle.string(from: receivedDateTime!)
        
        formatStyle.dateFormat = "mm"
        let minuteValue = formatStyle.string(from: receivedDateTime!)
        
        return (dateValue,timeValue,hourValue,minuteValue)
    }

}
