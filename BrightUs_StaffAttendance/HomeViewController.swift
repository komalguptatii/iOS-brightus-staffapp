//
//  HomeViewController.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: BaseViewController, UIScrollViewDelegate {
    
    @IBOutlet var mainScrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Added Dashboard Controller and Camera as child to HomeView
        
        let dashboardController = self.storyboard?.instantiateViewController(withIdentifier: "DashboardView") as! DashboardView
        let cameraController = self.storyboard?.instantiateViewController(withIdentifier: "Camera") as! Camera
        
        
        self.addChildViewController(dashboardController)
        self.mainScrollView.addSubview(dashboardController.view)
        dashboardController.didMove(toParentViewController: self)
        
        self.addChildViewController(cameraController)
        self.mainScrollView.addSubview(cameraController.view)
        cameraController.didMove(toParentViewController: self)
        
        
        var cameraFrame : CGRect = cameraController.view.frame
        cameraFrame.origin.x = self.view.frame.width
        cameraController.view.frame = cameraFrame
        
        //Changed Content Size of Scroll View
        mainScrollView.contentSize = CGSize(width: (self.view.frame.width * 2), height: (self.view.frame.height - 64))
        
//        //Hide Back button on this view
//        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
//        navigationItem.leftBarButtonItem = backButton

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     Logout Action
     
     - parameter description : User can logout from app via tapping on Logout Button
     
    */
    @IBAction func LogoutAction(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func MenuButtonPressed(_ sender: Any) {
        self.onSlideMenuButtonPressed(sender as! UIBarButtonItem)
    }
    
    
//    func MenuButton(_ sender: UIButton) {
//        self.onSlideMenuButtonPressed(sender)
//    }
}
