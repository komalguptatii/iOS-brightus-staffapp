//
//  TiiCheckInOutCell.swift
//  BrightUs_StaffAttendance
//
//  Created by Komal Gupta on 25/01/17.
//  Copyright © 2017 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

/// Check - In/Out detail Cell

class TiiCheckInOutCell: UITableViewCell {
    
    /**
     * Time Label - Shows Attendance to display the time at which attendance is marked
     */
    @IBOutlet var timeLabel: UILabel!
    
    /**
     *Indication Label - Indicate check - in/out
     */
    @IBOutlet var indicationLabel: UILabel!
    
    /**
     Check In/Out Image
     */
    @IBOutlet var checkInOutImage: UIImageView!
    
}
