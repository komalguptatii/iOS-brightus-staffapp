//
//  HomeViewController.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class HomeViewController: BaseViewController, UIScrollViewDelegate, CLLocationManagerDelegate {
    
    /**
     * ScrollView on which dashboard & camera controller view is added
    */
    @IBOutlet var mainScrollView: UIScrollView!
    
    /**
     * Intialized instance of CLLocationManager
     */

    var locationManager = CLLocationManager()
    
    /**
     * To keep check of access to mark attendance
    */
    var isAllowedToMarkAttendance = false

    //MARK: - Methods
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //StartUpdatingLocation()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //            locationManager.distanceFilter = 50
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        
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
        mainScrollView.tag = 200
        print(mainScrollView.bounds.size.width)
        print(mainScrollView.contentSize.width)


        //Enabled bar button for slider menu
//        //Hide Back button on this view
//        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
//        navigationItem.leftBarButtonItem = backButton

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Location Methods
    //MARK: -

    /**
     Authorization Status to use location method
    */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    /**
     Update Location Method
     
     - parameter description : Check whether user is in premises or not
    */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print (locations)
        if let location = locations.first {
            print(location)
            let destinationLatitude = defaults.value(forKey: "latitude") as? Double
            let destinationLongitude = defaults.value(forKey: "longitude") as? Double
            
            let destination = CLLocation(latitude: destinationLatitude!, longitude: destinationLongitude!)
            
            let distance = location.distance(from: destination)
            print(distance)
            
            let distanceDouble = Double(distance)
            
            if (distanceDouble <= 30.00){
                if (location.verticalAccuracy * 0.5 <= destination.verticalAccuracy * 0.5){
                    
                    //Checkin
                    isAllowedToMarkAttendance = true
                    
                    //Disable ScrollView or add child after this
                    self.mainScrollView.isPagingEnabled = true
                    
                    
                }else{
                    //Cant check in
                    isAllowedToMarkAttendance = false
                    self.mainScrollView.isPagingEnabled = false

                }
                
            }else{
                //Cant check in
                isAllowedToMarkAttendance = false
                self.mainScrollView.isPagingEnabled = false

            }
        }
    }
    
    //MARK: - Button Action
    //MARK: -
    /**
     Menu Button Action 
     
     - parameter description : Slider Menu will be shown to user
     
    */
    @IBAction func MenuButtonPressed(_ sender: Any) {
        self.onSlideMenuButtonPressed(sender as! UIBarButtonItem)
    }
    
    
 
}
