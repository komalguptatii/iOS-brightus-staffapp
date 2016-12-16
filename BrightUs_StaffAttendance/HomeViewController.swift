//
//  HomeViewController.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet var mainScrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let dashboardController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DashboardView") as UIViewController
        let cameraController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Camera") as UIViewController

        self.addChildViewController(dashboardController)
        self.mainScrollView.addSubview(dashboardController.view)
        dashboardController.didMove(toParentViewController: self)
        
        self.addChildViewController(cameraController)
        self.mainScrollView.addSubview(cameraController.view)
        cameraController.didMove(toParentViewController: self)
        
        
        var cameraFrame : CGRect = cameraController.view.frame
        cameraFrame.origin.x = self.view.frame.width
        cameraController.view.frame = cameraFrame
        
        self.mainScrollView.contentSize = CGSize(width: self.view.frame.width + cameraController.view.frame.width , height: self.view.frame.height)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
}
