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

//let baseURL = "https://brightus-attendance.herokuapp.com"

let baseURL = "https://brightus--attendance-herokuapp-com-hf2xh802zzn7.runscope.net"

//Staff App - client_id = 2, client_secret = XNgcybCHTfz0wfehSQcDOStyGCnwakCIIECZzWtD

//Student App - client_id = 3, client_secret = LlHv7I5ROyd61U3R2FJDtmiuYLAoT5IXWdn6ldS7

