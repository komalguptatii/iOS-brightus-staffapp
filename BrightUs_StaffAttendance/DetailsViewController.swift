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
class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var detailTableView: UITableView!
    
    var attendanceDetailArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        detailTableView.delegate = self
        detailTableView.dataSource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func BackButtonAction(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)

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
        return 2
        
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
        
        return cell
    }

}
