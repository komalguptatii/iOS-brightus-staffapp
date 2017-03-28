//
//  SlideMenuViewController.swift
//  StudentApp
//
//  Created by Komal Gupta on 21/11/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

/**
 * SlideMenuDelegate
 */
protocol SlideMenuDelegate {
    
    /**
     * slideMenuItemSelectedAtIndex Method
     
        - parameter argument : index (Int32)
    */
    func slideMenuItemSelectedAtIndex(_ index : Int32)
}

/// SlideMenuViewController

class SlideMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /**
     *  Array to display menu options
     */
    @IBOutlet var tblMenuOptions : UITableView!
    
    /**
     *  Transparent button to hide menu
     */
    @IBOutlet var btnCloseMenuOverlay : UIButton!
    
    /**
     *  Array containing menu options
     */
    var arrayMenuOptions = [Dictionary<String,String>]()
    
    /**
     *  Menu button which was tapped to display the menu
     */
    var btnMenu : UIButton!
//    var btnMenu : UIBarButtonItem!
    
    /**
     *  Delegate of the MenuVC
     */
    var delegate : SlideMenuDelegate?

    /**
     *viewDidLoad Method
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true
        
        tblMenuOptions.tableFooterView = UIView()
        tblMenuOptions.isScrollEnabled = true
        tblMenuOptions.layer.shadowOpacity = 0.8
        tblMenuOptions.layer.shadowRadius = 4
        tblMenuOptions.layer.shadowColor = UIColor.black.cgColor
        tblMenuOptions.layer.shadowOffset = CGSize(width: 2.0, height: 1.0)
        tblMenuOptions.clipsToBounds = false
        tblMenuOptions.layer.masksToBounds = false
        tblMenuOptions.tableFooterView = UIView(frame: CGRect.zero)
        self.view.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        
        // Do any additional setup after loading the view.
    }

    /**
     *didReceiveMemoryWarning Method
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    /**
//     viewDidDisappear Method
//     
//     - parameter argument : Bool
//     
//     */
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
////        self.navigationController?.isNavigationBarHidden = true
//    }
    
    /**
     * viewWillAppear Method
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.isUserInteractionEnabled = true
        arrayMenuOptions.removeAll()
        updateArrayMenuOptions()
    }
    
    /**
     * updateArrayMenuOptions - Add Options to Menu
     */
    func updateArrayMenuOptions(){
        arrayMenuOptions.append(["title":"Profile", "icon":""])
        arrayMenuOptions.append(["title":"Attendance details", "icon":""])

        arrayMenuOptions.append(["title":"Logout", "icon":""])

        tblMenuOptions.reloadData()
    }

    /**
     onCloseMenuClick Method
     
     - parameter argument : UIBarButtonItem
     
    */
    @IBAction func onCloseMenuClick(_ button:UIBarButtonItem!){     //Changed UIButton to UIBarButtonItem
        btnMenu.tag = 0
        
        if (self.delegate != nil) {
            var index = Int32(button.tag)
            if(button == self.btnCloseMenuOverlay){
                index = -1
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width,height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
        }, completion: { (finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        })
    }
    
    /**
     numberOfSections Method
     
        - parameter argument : UITableView 
     
        - parameter return : Int
     
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    /**
     TableView - heightForRowAt Method
     
     - parameter return : CGFloat
     
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight : CGFloat! = 0
        if ((indexPath as NSIndexPath).section == 0) {
            rowHeight = 200.0
        }
        else if ((indexPath as NSIndexPath).section == 1){
            rowHeight = 60.0
 
        }
        return rowHeight
    }
    
    /**
     TableView - numberOfRowsInSection Method
     
     - parameter return : Int
     
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        var countValue = 0
        
        if section == 0{
            countValue = 1
        }
        else if section == 1{
            countValue = arrayMenuOptions.count
        }
       
        return countValue
    }
    
    /**
     TableView - cellForRowAt Method
     
     - parameter return : UITableViewCell
     
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellMenu")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        
        if ((indexPath as NSIndexPath).section == 0){
            cell.backgroundColor = UIColor(red: 255.0/255.0, green: 197.0/255.0, blue: 17.0/255.0, alpha: 1.0)
            
            let userImageView = UIImageView()
            userImageView.frame = CGRect(x: 15.0, y: 40.0, width: 48.0, height: 48.0)
            
            userImageView.image = UIImage(named : "user")
            
            let emailLabel = UILabel()
            emailLabel.text = defaults.value(forKey: "email") as? String
            emailLabel.frame = CGRect(x: 15.0, y: 160.0, width: 240.0, height: 30.0)
            emailLabel.font = UIFont.systemFont(ofSize: 16)
            emailLabel.textColor = UIColor.white
            
            let nameLabel = UILabel()
            nameLabel.text = defaults.value(forKey: "name") as? String
            nameLabel.frame = CGRect(x: 15.0, y: 120.0, width: 240.0, height: 30.0)
            nameLabel.font = UIFont.systemFont(ofSize: 18)
            nameLabel.textColor = UIColor.white
            
            cell.contentView.addSubview(userImageView)
            cell.contentView.addSubview(emailLabel)
            cell.contentView.addSubview(nameLabel)
            
            //            cell.textLabel?.textColor = UIColor.white
            //            cell.textLabel?.text = "User Information"
        }
        else if ((indexPath as NSIndexPath).section == 1){
            
            let iconImageView = UIImageView()
            iconImageView.frame = CGRect(x: 10.0, y: 20.0, width: 24.0, height: 24.0)
            
            if indexPath.row == 0{
                iconImageView.image = UIImage(named : "profile_icon")
                
            }
            else if indexPath.row == 1{
                iconImageView.image = UIImage(named : "detail_icon")
                
            }
            else if indexPath.row == 2{
                iconImageView.image = UIImage(named : "logout_icon")
                
            }
            
            let nameLabel = UILabel()
            nameLabel.text = arrayMenuOptions[(indexPath as NSIndexPath).row]["title"]!
            nameLabel.frame = CGRect(x: 60.0, y: 18.0, width: 200.0, height: 30.0)
            nameLabel.textColor = UIColor.black
            
            cell.contentView.addSubview(iconImageView)
            cell.contentView.addSubview(nameLabel)
            //            cell.textLabel?.text = arrayMenuOptions[(indexPath as NSIndexPath).row]["title"]!
            cell.textLabel?.textColor = UIColor.black
            cell.backgroundColor = UIColor.clear
            
        }
        
        return cell
    }
    
    /**
     *TableView - didSelectRowAt Method
     */

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if ((indexPath as NSIndexPath).section == 0) {
            
        }
        else {
            // Call & Navigate to Profile, Change Password & Logout
            if indexPath.row == 0{
                self.NavigateToProfile()
            }
            else if indexPath.row == 1{
                self.NavigateToAttendanceDetail()
            }
            else if indexPath.row == 2{
                self.LogoutCall()
            }
            
//            let btn = UIButton(type: UIButtonType.custom)
//            btn.tag = (indexPath as NSIndexPath).row
//            self.onCloseMenuClick(btn)
        }
        
        
    }

    /**
     * NavigateToProfile Method
    */
    func NavigateToProfile(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserProfile") as UIViewController
        self.navigationController?.show(vc, sender: nil)
    }
    
    /**
     * NavigateToAttendanceDetail Method
    */
    func NavigateToAttendanceDetail(){
        self.navigationController?.navigationBar.isHidden = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AttendanceDetail") as UIViewController
        self.navigationController?.show(vc, sender: nil)
        
    }
    
    /**
     * LogoutCall Method
     */

    func LogoutCall(){
        //Delete Token from server & local end
        //Firebase Logout
        //Pop to ViewController
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            defaults.setValue("", forKey: "tokenType")
            defaults.setValue("", forKey: "accessToken")
            defaults.setValue("", forKey: "refreshToken")
            defaults.setValue("", forKey: "name")
            defaults.setValue("", forKey: "latitude")
            defaults.setValue("", forKey: "longitude")
            defaults.setValue("", forKey: "password")
            defaults.setValue("", forKey: "branchAccess")

            defaults.synchronize()
            
            _ = self.navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}
