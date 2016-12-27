//
//  CameraViewController.swift
//  BrightUs_StaffAttendance
//
//  Created by Mohit Sharma on 12/12/16.
//  Copyright © 2016 Techies India Inc. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import MapKit

class Camera: UIViewController, AVCaptureMetadataOutputObjectsDelegate, CLLocationManagerDelegate {
    
    var objCaptureSession:AVCaptureSession?
    var objCaptureVideoPreviewLayer:AVCaptureVideoPreviewLayer?
    var vwQRCode:UIView?
    var attendanceStatus = String()
    var randomQRCode = String()
    
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
        
        configureVideoCapture()
        addVideoPreviewLayer()
        initializeQRView()
        
        //Added Custom Image on Camera Preview
        let customImagePreview = UIImageView()
        customImagePreview.frame = CGRect(x: 0.0, y: 0.0, width: 254.0, height: 254.0)
        customImagePreview.center = self.view.center
        
        customImagePreview.image = UIImage(named: "scanArea")
        self.view.addSubview(customImagePreview)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Location Methods
    
    
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
    
    //MARK: - Camera Methods
    
    
    func configureVideoCapture() {
        let objCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        var error:NSError?
        let objCaptureDeviceInput: AnyObject!
        do {
            objCaptureDeviceInput = try AVCaptureDeviceInput(device: objCaptureDevice) as AVCaptureDeviceInput
        } catch let error1 as NSError {
            error = error1
            objCaptureDeviceInput = nil
        }
        if (error != nil) {
            let alertController = UIAlertController(title: "Device Error", message: "Device not supported for this application", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
                print("Cancel")
            }
            // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                print("OK")
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            _ = self.present(alertController, animated: true, completion: nil)
        }
        objCaptureSession = AVCaptureSession()
        objCaptureSession?.addInput(objCaptureDeviceInput as! AVCaptureInput)
        let objCaptureMetadataOutput = AVCaptureMetadataOutput()
        objCaptureSession?.addOutput(objCaptureMetadataOutput)
        objCaptureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        objCaptureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
    }
    
    func addVideoPreviewLayer()
    {
        objCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: objCaptureSession)
        objCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        objCaptureVideoPreviewLayer?.frame = view.layer.bounds
        self.view.layer.addSublayer(objCaptureVideoPreviewLayer!)
        objCaptureSession?.startRunning()
//        self.view.bringSubview(toFront: qrResultLabel)
    }
    
    func initializeQRView() {
        vwQRCode = UIView()
//        vwQRCode?.layer.borderColor = UIColor.red.cgColor
//        vwQRCode?.layer.borderWidth = 5
        self.view.addSubview(vwQRCode!)
        self.view.bringSubview(toFront: vwQRCode!)
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            vwQRCode?.frame = CGRect.zero
//            qrResultLabel.text = "NO QRCode text detacted"
            return
        }
        let objMetadataMachineReadableCodeObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if objMetadataMachineReadableCodeObject.type == AVMetadataObjectTypeQRCode {
            let objBarCode = objCaptureVideoPreviewLayer?.transformedMetadataObject(for: objMetadataMachineReadableCodeObject as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            vwQRCode?.frame = objBarCode.bounds;
            if objMetadataMachineReadableCodeObject.stringValue != nil {
                randomQRCode = objMetadataMachineReadableCodeObject.stringValue
                print(randomQRCode)
                objCaptureSession?.stopRunning()
                if let userId = FIRAuth.auth()?.currentUser?.uid {
                    getQrCodeStatus(userId)
                }
            }
        }
    }

    func getQrCodeStatus (_ uid : String){
        let ref = FIRDatabase.database().reference()
        ref.child("qrCode").observeSingleEvent(of: .value, with: {(snapshot) in

            
            if (snapshot.hasChildren() == true){
                if let snapValue = snapshot.value as? NSMutableDictionary {
                    let status = snapValue.value(forKey: "status")
                    let randomNmbr = snapValue.value(forKey: "code")
                    self.attendanceStatus = status as! String
                    let nmbr = String(describing: randomNmbr!)
                    
                    //Check for location here
                    if self.isAllowedToMarkAttendance{
                        print("\(randomNmbr!) == \(self.randomQRCode)")
                        if (nmbr == self.randomQRCode){
                            if (self.attendanceStatus == "new"){
                                
                                self.changeStatus()
                                //Back to Dashboard
                                
                            }
                            
                        }else {
                            print("different code")
                            
                            self.vwQRCode?.frame = CGRect.zero
                            self.objCaptureSession?.startRunning()
                            
                            let controller = self.parent as? HomeViewController
                            let tag = controller?.mainScrollView.tag
                            print(tag!)
                            
                            let scrollView = controller?.mainScrollView
                            scrollView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                        }

                    }
                    
                }
                
                
            }else{ // if no data available
                
                
            }
            
        })
        
    }
    
    func changeStatus() {
        let ref = FIRDatabase.database().reference()
        ref.child("qrCode").observeSingleEvent(of: .value, with: {(snapshot) in
            ref.child("qrCode").updateChildValues(["status" : "old"])
            self.randomQRCode = ""
            self.vwQRCode?.frame = CGRect.zero
            self.objCaptureSession?.startRunning()
            let controller = self.parent as? HomeViewController
            let scrollView = controller?.mainScrollView
            scrollView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        })
    }
    
}
