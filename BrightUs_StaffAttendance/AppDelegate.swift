//
//  AppDelegate.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications
import UserNotificationsUI
import FirebaseInstanceID

/// App Delegate
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate{

    /**
     * UIWindow Initializer
    */
    var window: UIWindow?

    /**
     * Method for setting Launch Options
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Configured Firebase in App
        FIRApp.configure()
       
        //Changed Color of Navigation Bar
//        UINavigationBar.appearance().barTintColor = UIColor(red: 222.0/255.0, green: 60.0/255.0, blue: 77.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 17.0/255.0, alpha: 1.0)

        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
//       UINavigationBar.appearance().isTranslucent = false
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
//        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        application.registerForRemoteNotifications()
        
//        FIRDatabase.database().persistenceEnabled = true
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getRefreshToken") , object: nil)
//        firInstanceToken = FIRInstanceID.instanceID().token()!

//        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification),
//                                                         name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)

        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        
        // Print full message.
        print(userInfo)
    }
    
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
//
        // Print full message.
        print(userInfo)

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "getAttendanceDetail"), object: nil)
        }
        
        if let rootViewController = window?.rootViewController as? UINavigationController {
            print(rootViewController.viewControllers.count)
            
            for controllers in rootViewController.viewControllers{
                print(controllers)
                if let vc = controllers as? HomeViewController {
                    for subView in vc.childViewControllers {
                        if let subView = subView as? DashboardView {
                            subView.GetTodayAttendanceDetail()
                        }
                    }
                }
            }
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // Let FCM know about the message for analytics etc.
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)
        // handle your message
    }

    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
   
    func tokenRefreshNotification() {   //_ notification: Notification
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            firInstanceToken = refreshedToken
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()

    }
    
    func connectToFcm() {
        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            return
        }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        if let tokenAvailable = FIRInstanceID.instanceID().token(){
            firInstanceToken = tokenAvailable
        }

        FIRInstanceID.instanceID().setAPNSToken(deviceToken as Data, type: FIRInstanceIDAPNSTokenType.sandbox)   //FIRInstanceIDAPNSTokenTypeSandbox
    }
    
    /**
     * Sent when the application is about to move from active to inactive state.
     */
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    /**
     * Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     */
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
//        FIRMessaging.messaging().disconnect()
//        print("Disconnected from FCM.")

    }

    /**
     * Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    */
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    /**
     * Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    */
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    /**
     * Called when the application is about to terminate.
    */
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

