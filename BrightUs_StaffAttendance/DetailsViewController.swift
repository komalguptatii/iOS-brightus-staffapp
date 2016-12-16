//
//  DetailsViewController.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet var datePickerView: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerView.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    @IBAction func fromButton(_ sender: UIButton) {
        datePickerView.isHidden = false

    }
    
    @IBAction func toButton(_ sender: UIButton) {
        datePickerView.isHidden = false

    }
    @IBAction func searchButton(_ sender: UIButton) {
        
        datePickerView.isHidden = true

    }
    
}
