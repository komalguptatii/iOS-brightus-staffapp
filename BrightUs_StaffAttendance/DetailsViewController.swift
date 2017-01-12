//
//  DetailsViewController.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

/// Attendance Details - Shows the history, user can apply filters and choose time period

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
     * View which contains date picker view - as it is not allowed to change the background color of date picker
    */
    @IBOutlet var datePickerCustomView: UIView!
    
    /**
     * Done button
    */
    @IBOutlet var doneButton: UIButton!
    
    /**
     * No Data Image
    */
    @IBOutlet var noDataImage: UIImageView!
    
    /**
 
    */
    @IBOutlet var searchButton: UIButton!
    
    /**
     * Indicator to let user know about data loading
     */
    var indicator = UIActivityIndicatorView()
    
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
     * Current Page of Detail Request
     */
    var currentPage = 1
    
    /**
     * Total number of Pages of Detail Request
     */
    var totalNoOfPages = 0
    
    /**
     * This will contain selected from date
     */
    var selectedFromDate = ""
    
    /**
     * This will contain selected to date
     */
    var selectedToDate = ""

    /**
    * No Record Found Label
    */
    @IBOutlet var noRecordFound: UILabel!
    
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
        
        
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        detailTableView.backgroundColor = UIColor.clear
        
        filterPickerView.delegate = self
        filterPickerView.dataSource = self
        filterPickerView.isHidden = true
        filterPickerView.isUserInteractionEnabled = false
        
        doneButton.isHidden = true
        doneButton.isUserInteractionEnabled = false
        datePickerCustomView.isHidden = true
        datePickerView.isHidden = true
        datePickerView.isUserInteractionEnabled = false
        datePickerView.maximumDate = Date()
        
//        datePickerView.addTarget(self, action: #selector(DetailsViewController.DatePickerValueSelected(sender:)), for: UIControlEvents.valueChanged)
        
        
        fromDateButton.isUserInteractionEnabled = false
        toDateButton.isUserInteractionEnabled = false
        
        self.searchButton.isEnabled = false

        if IsConnectionAvailable(){
            self.view.addSubview(indicator)
            self.indicator.startAnimating()
            self.view.bringSubview(toFront: indicator)
            
            self.view.isUserInteractionEnabled = false
            self.view.window?.isUserInteractionEnabled = false
            
            self.performSelector(inBackground: #selector(DetailsViewController.GetAttendanceDetails), with: nil)
            
        }
        else{
            let alert = ShowAlert()
            alert.title = "Alert"
            alert.message = "Check Network Connection"
            _ = self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    /**
     * didReceiveMemoryWarning Method
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Button Actions

    /**
     Back Button Action
     
     - paramater description : Pop Controller to Previous View
     
     */

    @IBAction func BackButtonAction(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)

    }
    
    /**
     Search Button Action
     
     - paramater description : Search for the data on the basis of filter and time period selected
     
     */
    
    @IBAction func SearchButtonAction(_ sender: UIButton) {
        
        self.attendanceDetailArray.removeAllObjects()
        self.detailTableView.reloadData()
        self.searchButton.isEnabled = false
        if IsConnectionAvailable(){
            self.view.addSubview(indicator)
            self.indicator.startAnimating()
            self.view.bringSubview(toFront: indicator)
            
            self.view.isUserInteractionEnabled = false
            self.view.window?.isUserInteractionEnabled = false
            
            self.performSelector(inBackground: #selector(DetailsViewController.GetAttendanceDetails), with: nil)
            

        }
        else{
            self.searchButton.isEnabled = true

            let alert = ShowAlert()
            alert.title = "Alert"
            alert.message = "Check Network Connection"
            _ = self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    /**
     Done Button Action
     
     - parameter description : It will hide the date picker and filter picker view on the screen
     
    */
    @IBAction func DoneButtonAction(_ sender: UIButton) {
        

        if sender.tag == 0{
            
            self.attendanceDetailArray.removeAllObjects()
            self.detailTableView.reloadData()


            doneButton.isHidden = true
            doneButton.isUserInteractionEnabled = false
            
            filterPickerView.isHidden = true
            filterPickerView.isUserInteractionEnabled = false
            
            self.view.endEditing(true)

            sender.tag = 1
        }
        else if sender.tag == 1{
            
            let selectedDateFormatter = DateFormatter()
            selectedDateFormatter.dateFormat = "dd-MM-yyyy"
            
            self.searchButton.isEnabled = true

            
            if datePickerView.tag == 1{
                isSelectedFromDate = true
                selectedFromDate = selectedDateFormatter.string(from: datePickerView.date)
                fromDateButton.setTitle(selectedFromDate, for: UIControlState.normal)
            }
            else{
                selectedToDate = selectedDateFormatter.string(from: datePickerView.date)
                toDateButton.setTitle(selectedToDate, for: UIControlState.normal)
            }
            
            doneButton.isHidden = true
            doneButton.isUserInteractionEnabled = false

            datePickerCustomView.isHidden = true
            datePickerView.isHidden = true
            datePickerView.isUserInteractionEnabled = false
            self.view.endEditing(true)
            
            sender.tag = 0
        }
        
        
    }
    
    /**
     Filter Action
     
     - paramater description : Display picker view to select filter
     
     */

    @IBAction func FilterAction(_ sender: UIBarButtonItem) {
        
        datePickerCustomView.isHidden = true
        datePickerView.isHidden = true
        datePickerView.isUserInteractionEnabled = false
        
        selectedFilter = "today"
        selectedFromDate = "From Date"
        selectedToDate = "To Date"
        fromDateButton.setTitle(selectedFromDate, for: UIControlState.normal)
        toDateButton.setTitle(selectedToDate, for: UIControlState.normal)

        
        fromDateButton.isUserInteractionEnabled = false
        toDateButton.isUserInteractionEnabled = false

        doneButton.isHidden = false
        doneButton.isUserInteractionEnabled = true
        doneButton.tag = 0
        
        filterPickerView.isHidden = false
        filterPickerView.isUserInteractionEnabled = true

        self.view.bringSubview(toFront: filterPickerView)
        

    }
    
    /**
     From Date Button Action
     
     - parameter description : Display date picker view to select date as "From Date"
     
    */
    @IBAction func FromDateButtonAction(_ sender: UIButton) {
        doneButton.isHidden = false
        doneButton.isUserInteractionEnabled = true
        
        datePickerCustomView.isHidden = false

        datePickerView.isHidden = false
        datePickerView.isUserInteractionEnabled = true
        
        datePickerView.setDate(Date(), animated: false)
        doneButton.tag = 1
        datePickerView.tag = 1
        
    }
    
    /**
     To Date Button Action
     
     - parameter description : Display date picker view to select date as "To Date"
     
     */

    @IBAction func ToDateButtonAction(_ sender: UIButton) {
        
        if isSelectedFromDate{
            
            doneButton.isHidden = false
            doneButton.isUserInteractionEnabled = true
            doneButton.tag = 1

            datePickerCustomView.isHidden = false

            datePickerView.isHidden = false
            datePickerView.isUserInteractionEnabled = true
            datePickerView.setDate(Date(), animated: false)
            datePickerView.tag = 2
            
            

        }
        else{
            print("Please select the From Date first")
        }

    }
    
    //MARK: - TableView Delegate & Datasource
    
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
    
    /**
     Height of Row
     
     - parameter return : CGFLoat (height)
     
     */


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
        
        if attendanceDetailArray.count > 0 {
            let dict = attendanceDetailArray.object(at: (indexPath as NSIndexPath).row) as! NSDictionary
            print(dict)
            
            cell.particularDate.text = ConvertTimeStampToRequiredHours(dateValue: "\(dict.value(forKey: "check_in")!)").0
            
            let checkinTimeValue = ConvertTimeStampToRequiredHours(dateValue: "\(dict.value(forKey: "check_in")!)").1
            print(checkinTimeValue)
            cell.checkinTime.text = "\(checkinTimeValue)"
            
            let checkInHours = ConvertTimeStampToRequiredHours(dateValue: "\(dict.value(forKey: "check_in")!)").2
            print(checkInHours)
            
            let checkInMinutes = ConvertTimeStampToRequiredHours(dateValue: "\(dict.value(forKey: "check_in")!)").3
            print(checkInMinutes)
            
            //TODO - Check for empty check out
            if let checkForCheckOutTimeValid = dict.value(forKey: "check_out") as? String{
                if checkForCheckOutTimeValid.isEmpty{
                    cell.checkOutTime.text = "Pending"
                    cell.totalTime.text = "--"
                }
                else{
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
                }
            }
            
           
        }
       
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }

    
    //MARK: - Picker View Delegate & datasources
    
    /**
     Picker View Delegate & Datasources
        
     - parameter methodsInAction : numberOfComponents, numberOfRowsInComponent, titleForRow, didSelectRow
     
    */
    
    /**
     numberOfComponents in PickerView
     
     - parameter return : Int(Number of components)
     
    */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     numberOfRowsInComponent in PickerView
     
     - parameter return : Int(Number of rows)

     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filterValueArray.count
    }
    
    /**
     titleForRow in PickerView
     
     - parameter return : String

     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return filterValueArray[row]
    }
    
    /**
     *didSelectRow in PickerView
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.attendanceDetailArray.removeAllObjects()
        self.detailTableView.reloadData()

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
            if IsConnectionAvailable(){
                
                self.searchButton.isEnabled = true

                self.view.addSubview(indicator)
                self.indicator.startAnimating()
                self.view.bringSubview(toFront: indicator)

                self.view.isUserInteractionEnabled = false
                self.view.window?.isUserInteractionEnabled = false
                self.performSelector(inBackground: #selector(DetailsViewController.GetAttendanceDetails), with: nil)
                
            }
            else{
                self.searchButton.isEnabled = true

                let alert = ShowAlert()
                alert.title = "Alert"
                alert.message = "Check Network Connection"
                _ = self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        
    }
    
    //MARK: - ScrollView Delegate

    /**
     Delegate method of scroll view 
     
     - parameter - to check whether user is moving onto next page or data and request for data accordingly
     
    */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.size.height
        let scrollViewContentSizeHeight = scrollView.contentSize.height
        let scrollViewContentOfSetY = scrollView.contentOffset.y
        print("\(scrollViewContentOfSetY), \(scrollViewHeight),\(scrollViewContentSizeHeight)")
        if (scrollViewContentOfSetY + scrollViewHeight == scrollViewContentSizeHeight) {
            if currentPage < totalNoOfPages{
                currentPage = currentPage + 1
                self.view.addSubview(indicator)
                self.indicator.startAnimating()
                self.view.bringSubview(toFront: indicator)

                self.view.isUserInteractionEnabled = false
                self.view.window?.isUserInteractionEnabled = false

                self.performSelector(inBackground: #selector(DetailsViewController.GetAttendanceDetails), with: nil)
            }
        }
    }
    
    //MARK: - API Request

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
                            if let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as?  NSDictionary{
                                print(dict)
                                
                                self.totalNoOfPages = dict.value(forKey: "last_page") as! Int
                                self.currentPage = dict.value(forKey: "current_page") as! Int
                                
                                if let detailArray = dict.value(forKey: "data") as? NSArray{
                                    print(detailArray)
                                    if detailArray.count > 0{
                                        
                                        self.attendanceDetailArray.addObjects(from: detailArray.mutableCopy() as! [AnyObject])
                                        
                                        DispatchQueue.main.async {
                                            //Section is 1
                                            //Pagination Required + Fetch and display details on tableView
                                            self.noRecordFound.alpha = 0.0
                                            self.noDataImage.alpha = 0.0

                                            self.detailTableView.reloadData()
                                            self.searchButton.isEnabled = true

                                        }
                                    }
                                    else{
                                        DispatchQueue.main.async {
                                            self.noRecordFound.alpha = 1.0

                                            self.noDataImage.alpha = 1.0

                                        }
                                    }
                                 
                                    
                                }

                            }
                            
                        }
                        else if httpResponseValue.statusCode == 401{
                            if let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as?  NSDictionary{
                                print(dict)
                                
                                DispatchQueue.main.async {
                                    self.searchButton.isEnabled = true

                                    let alert = self.ShowAlert()
                                    
                                    alert.message = "\(dict.value(forKey: "message"))"
                                    alert.title = "\(dict.value(forKey: "title"))"
                                    _ = self.present(alert, animated: true, completion: nil)
                                    
                                }
                            }
                           

                        }
                        else if httpResponseValue.statusCode == 403{
                            if let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as?  NSDictionary{
                                print(dict)
                                
                                DispatchQueue.main.async {
                                    self.searchButton.isEnabled = true

                                    let alert = self.ShowAlert()
                                    
                                    alert.message = "\(dict.value(forKey: "message"))"
                                    alert.title = "\(dict.value(forKey: "title"))"
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
        
        DispatchQueue.main.async {
            self.indicator.removeFromSuperview()
            self.indicator.stopAnimating()

            self.view.isUserInteractionEnabled = true
            self.view.window?.isUserInteractionEnabled = true

        }
    }
    
    //MARK: - TimeStamp Conversion Method

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
        formatStyle.dateFormat = "dd MMMM, yyyy"
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

    //MARK: - Alert Controller
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
