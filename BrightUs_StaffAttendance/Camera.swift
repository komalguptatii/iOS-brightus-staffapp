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

class Camera: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var objCaptureSession:AVCaptureSession?
    var objCaptureVideoPreviewLayer:AVCaptureVideoPreviewLayer?
    var vwQRCode:UIView?
    var attendanceStatus = String()
    var randomQRCode = String()

    let ref = FIRDatabase.database().reference()
    var snapshotReference = FIRDataSnapshot()
    
    //MARK: - Methods
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        configureVideoCapture()
        addVideoPreviewLayer()
        initializeQRView()
        
        //Added Custom Image on Camera Preview
        let customImagePreview = UIImageView()
        customImagePreview.frame = CGRect(x: 0.0, y: 0.0, width: 254.0, height: 254.0)
        customImagePreview.center = self.view.center
        
        customImagePreview.image = UIImage(named: "scanArea")
        self.view.addSubview(customImagePreview)
        
        ref.child("qrCode").observeSingleEvent(of: .value, with: {(snapshot) in
            
            print(Date())
            
            if (snapshot.hasChildren() == true){
                
                self.snapshotReference = snapshot
            }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Camera Methods
    //MARK: -
    
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
                getQrCodeStatus()

                objCaptureSession?.stopRunning()

//                if let userId = FIRAuth.auth()?.currentUser?.uid {
//                    getQrCodeStatus(userId)
//                }
            }
        }
    }

    //MARK: - Get & Set QR Code Status
    //MARK: -
    /**
     Get QR Code Status 
     
     - parameter check : Firebase checks are implementedn i.e. new or old
 
    */
//    func getQrCodeStatus (_ ids : String){
    func getQrCodeStatus (){
        print(Date())
////        let ref = FIRDatabase.database().reference()
//        ref.child("qrCode").observeSingleEvent(of: .value, with: {(snapshot) in
//
//            print(Date())
//
//            if (snapshot.hasChildren() == true){
//                
//                
//            }else{ // if no data available
//                
//                
//            }
//            
//        })
        
        if let snapValue = snapshotReference.value as? NSMutableDictionary{
            
            let status = snapValue.value(forKey: "status")
            let randomNmbr = snapValue.value(forKey: "code")
            self.attendanceStatus = status as! String
            let nmbr = String(describing: randomNmbr!)
            
            //Check for location here
            //                        print("\(randomNmbr!) == \(self.randomQRCode)")
            
            if (nmbr == self.randomQRCode){
                if (self.attendanceStatus == "new"){
                    
                    self.ref.child("qrCode").updateChildValues(["status" : "old"])
                    
                    DispatchQueue.main.async {
                        //                self.MarkAttendanceOnServer()
                        self.randomQRCode = ""
                        
                        self.vwQRCode?.frame = CGRect.zero
                        self.objCaptureSession?.startRunning()
                        let controller = self.parent as? HomeViewController
                        let scrollView = controller?.mainScrollView
                        scrollView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MarkAttendanceOnServer"), object: nil)
                        
                    }
                                        
                }
                
            }else {
                print("different code")
                
                DispatchQueue.main.async {
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
    }
    
    /**
     Change Status of QR code
     
     - parameter description : If QR code scanned successfully then change status to "old" & MArk Attendance on Server
     
    */
    
    func changeStatus() {
//        let ref = FIRDatabase.database().reference()
        DispatchQueue.main.async {
            //                self.MarkAttendanceOnServer()
            self.vwQRCode?.frame = CGRect.zero
            self.objCaptureSession?.startRunning()
            let controller = self.parent as? HomeViewController
            let scrollView = controller?.mainScrollView
            scrollView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MarkAttendanceOnServer"), object: nil)
            
        }
    }
    
}
