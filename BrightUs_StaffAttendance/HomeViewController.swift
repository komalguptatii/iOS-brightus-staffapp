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

//    func CallBacktoScreen(){
//        print(mainScrollView.bounds.size.width)


//        mainScrollView.scrollRectToVisible(CGRect(x: mainScrollView.contentSize.width - mainScrollView.bounds.size.width * 2, y: 0.0, width: self.view.frame.width, height: (self.view.frame.height - 64)), animated: true)
//        mainScrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
//    }
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

    //TODO
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
                            if let locationValues = dict.value(forKey: "allowed_locations") as? NSArray{
                                print(locationValues)
                                if let locationDict = locationValues.object(at: 0) as? NSDictionary{
                                    print(locationDict)
                                    defaults.setValue(locationDict.value(forKey: "lattitude"), forKey: "latitude")
                                    defaults.setValue(locationDict.value(forKey: "longitude"), forKey: "longitude")
                                }
                            }
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
