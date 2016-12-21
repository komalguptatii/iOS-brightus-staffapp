//
//  TiiAttendanceDetailCell.swift
//  BrightUs_StaffAttendance
//
//  Created by Komal Gupta on 21/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

/// Attendance Detail Cell

class TiiAttendanceDetailCell: UITableViewCell {
    
    /**
     Background panel in light gray color contains whole detail
     
    */
    @IBOutlet var panelView: UIView!
    
    /**
     Particular date is the date to which all the details in one panel will be related
     
    */
    @IBOutlet var particularDate: UILabel!
    
    /**
     Check-In Time is the Time at which user entered in the premises
     
    */
    @IBOutlet var checkinTime: UILabel!
    
    /**
     Check-out Time is the time at which user leaves the premises
     
    */
    @IBOutlet var checkOutTime: UILabel!
    
    /**
     Total time will indicate the number of hours spent by user in BrightUs
     
    */
    @IBOutlet var totalTime: UILabel!
}
