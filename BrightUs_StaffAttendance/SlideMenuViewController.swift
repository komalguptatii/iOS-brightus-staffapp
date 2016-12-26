//
//  SlideMenuViewController.swift
//  StudentApp
//
//  Created by Komal Gupta on 21/11/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index : Int32)
}

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
//    var btnMenu : UIButton!
    var btnMenu : UIBarButtonItem!
    
    /**
     *  Delegate of the MenuVC
     */
    var delegate : SlideMenuDelegate?

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.isUserInteractionEnabled = true
        
        updateArrayMenuOptions()
    }
    
    func updateArrayMenuOptions(){
        arrayMenuOptions.append(["title":"Profile", "icon":""])
        arrayMenuOptions.append(["title":"Logout", "icon":""])

        tblMenuOptions.reloadData()
    }

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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight : CGFloat! = 0
        if ((indexPath as NSIndexPath).section == 0) {
            rowHeight = 60.0
        }
        else if ((indexPath as NSIndexPath).section == 1){
            rowHeight = 30.0
 
        }
        return rowHeight
    }
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellMenu")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        
        if ((indexPath as NSIndexPath).section == 0){
            cell.backgroundColor = UIColor.blue
            cell.textLabel?.text = "User Information"
        }
        else if ((indexPath as NSIndexPath).section == 1){
            cell.textLabel?.text = arrayMenuOptions[(indexPath as NSIndexPath).row]["title"]!
            cell.textLabel?.textColor = UIColor.black
            cell.backgroundColor = UIColor.clear

        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if ((indexPath as NSIndexPath).section == 0) {
            
        }
        else {
            
//            let btn = UIButton(type: UIButtonType.custom)
//            btn.tag = (indexPath as NSIndexPath).row
//            self.onCloseMenuClick(btn)
        }
        
        
    }

}
