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
    
    @IBOutlet var mainScrollView: UIScrollView!
    
    var locationManager = CLLocationManager()
    
    var isAllowedToMarkAttendance = false

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

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
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
                    
                }else{
                    //Cant check in
                    isAllowedToMarkAttendance = false
                }
                
            }else{
                //Cant check in
                isAllowedToMarkAttendance = false
            }
        }
    }

    
    /**
     Logout Action
     
     - parameter description : User can logout from app via tapping on Logout Button
     
    */
    @IBAction func LogoutAction(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /**
     Menu Button Action 
     
     - parameter description : Slider Menu will be shown to user
     
    */
    @IBAction func MenuButtonPressed(_ sender: Any) {
        self.onSlideMenuButtonPressed(sender as! UIBarButtonItem)
    }

    //Profile Call for Name & Location
    
    func ViewProfile() {
        let apiString = baseURL + "/api/user"
        let encodedApiString = apiString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: encodedApiString!)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let token = defaults.value(forKey: "accessToken") as! String
        
        let header = "Bearer" + " \(token)"
        print(header)
        
        request.setValue(header, forHTTPHeaderField: "Authorization")
        
        
        _ = URLSession.shared.dataTask(with: request as URLRequest){(data, response, error) -> Void in
            do {
                if data != nil{
                    if let httpResponseValue = response as? HTTPURLResponse{
                        print(httpResponseValue.statusCode)
                        if httpResponseValue.statusCode == 200{
                            let dict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                            print(dict)
                            
                            defaults.setValue(dict.value(forKey: "name"), forKey: "name")
                            if let locationValues = dict.value(forKey: "allowed_locations") as? NSArray{
                                print(locationValues)
                                if let locationDict = locationValues.object(at: 0) as? NSDictionary{
                                    print(locationDict)
                                    defaults.setValue(locationDict.value(forKey: "lattitude"), forKey: "latitude")
                                    defaults.setValue(locationDict.value(forKey: "longitude"), forKey: "longitude")
                                }
                            }
                            defaults.synchronize()
                        }
                    }
                }
            }
            catch{
                print("Error")
            }
            }.resume()
        
    }

}
