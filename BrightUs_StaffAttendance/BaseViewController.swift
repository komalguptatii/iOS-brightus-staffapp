//
//  BaseViewController.swift
//  StudentApp
//
//  Created by Komal Gupta on 21/11/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit

/// BaseViewController
class BaseViewController: UIViewController, SlideMenuDelegate {
    
    /**
     * Once Completion Handler
    */
    private static var __once: () = { () -> Void in
        
    }()
    
    /**
     * viewDidLoad Method
     */
    override func viewDidLoad() {
        super.viewDidLoad()
//        addSlideMenuButton()
        // Do any additional setup after loading the view.
    }
    
    /**
     * didReceiveMemoryWarning Method
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     * slideMenuItemSelectedAtIndex Method
     */
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        switch(index){
        case 0:
            print("Profile")
            break
        case 1:
            print("Logout")
            break
        default:
            print("default")
        }
    }
    
    /**
     * addSlideMenuButton Method
    */
    func addSlideMenuButton(){
//        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)))
        let btnShowMenu = UIButton(type: UIButtonType.system)
        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControlState())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        btnShowMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
//        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
//        let customBarItem = UIBarButtonItem(image: self.defaultMenuImage(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)))
//
//        self.navigationItem.leftBarButtonItem = customBarItem
    }

    /**
     defaultMenuImage Method
     
        - parameter return : UIImage
     
     */

    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 22), false, 0.0)
        
        UIColor.black.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 10, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 30, height: 1)).fill()
        
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 4, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 18, width: 30, height: 1)).fill()
        
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return defaultMenuImage;
    }

    /**
     onSlideMenuButtonPressed Method
     
     - parameter argument : UIBarButtonItem
     
     */

    func onSlideMenuButtonPressed(_ sender : UIButton){
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1);
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
            }, completion: { (finished) -> Void in
                viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
        
        let menuVC : SlideMenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "SlideMenuViewController") as! SlideMenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
        }, completion:nil)
    }

}
