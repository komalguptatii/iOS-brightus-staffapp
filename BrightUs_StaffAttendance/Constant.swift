//
//  Constant.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation

func IsConnectionAvailable()->Bool{                     //Reachability Check Function
    return Reachability.isConnectedToNetwork()
}

let delegateObject = AppDelegate()
var defaults = UserDefaults.standard

let baseURL = "brightus-attendance.herokuapp.com"
