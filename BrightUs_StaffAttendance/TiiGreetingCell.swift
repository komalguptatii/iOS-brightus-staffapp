//
//  TiiGreetingCell.swift
//  BrightUs_StaffAttendance
//
//  Created by Komal Gupta on 25/01/17.
//  Copyright © 2017 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

/// Greeting Cell - Custom Cell to greet user

class TiiGreetingCell: UITableViewCell {

    /**
     Greeting Image - Change everytime according to morning, afternoon & so on
     */
    @IBOutlet var greetingImage: UIImageView!
    
    /**
     Wishes - to greet user
     */
    @IBOutlet var wishes: UILabel!
    
    /**
     User Name - Display the user name
     */
    @IBOutlet var userName: UILabel!
    
    /**
     Today's Date time - Displays Current date & Time
     */
    @IBOutlet var todaysDateTime: UILabel!

}
