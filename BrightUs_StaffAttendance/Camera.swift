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

/// Camera Controller - To scan QR code
class Camera: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    /**
    * objCaptureSession is the initialized variable of AVCaptureSession
    */
    var objCaptureSession:AVCaptureSession?
    
    /**
     * objCaptureVideoPreviewLayer is the initialized variable of AVCaptureVideoPreviewLayer
     */
    var objCaptureVideoPreviewLayer:AVCaptureVideoPreviewLayer?
    
    /**
     * vwQRCode - View of QR code (frame)
    */
    var vwQRCode:UIView?
    
    /**
     * attendanceStatus - save status of attendance fetched from Firebase
     */
    var attendanceStatus = String()
    
    /**
     * randomQRCode - code scanned by the camera
     */
    var randomQRCode = String()
    
    /**
     * ref - Reference to Firebase Database
    */
    let ref = FIRDatabase.database().reference()
    
    /**
     * snapshotReference - To fetch and save reference of FIRDataSnapshot
    */
    var snapshotReference = FIRDataSnapshot()
    
    /**
     * userId - Id seperated from scanned QR code
    */
    var userId = ""
    
    //MARK: - Methods
    //MARK: -
    
    /**
     * viewDidLoad Method
    */
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
        
        
    }
    
    /**
     * didReceiveMemoryWarning Method
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
        viewWillAppear Method
     
        - parameter argument - animated (Bool)
     
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if IsConnectionAvailable(){
            
            if let branchCode = defaults.value(forKey: "branchCode") as? String{
                ref.child("mainAttendanceApp").child("branches").child(branchCode).child("qrCode").child("users").observe(.value, with: {(snapshot) in
                    print("Reading data")
                    
                    if (snapshot.hasChildren() == true){
                        self.snapshotReference = snapshot
                    }
                })
                
            }
            
        }
        else{
            let alert = ShowAlert()
            alert.title = "Alert"
            alert.message = "Check Network Connection"
            _ = self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    //MARK: - Camera Methods
    //MARK: -
    
    /**
     Method - configureVideoCapture
     
     - parameter description : It configures the AVCaptureDevice
     
    */
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
    
    /**
     Method - addVideoPreviewLayer
     
     - parameter description : It configures the AVCaptureVideoPreviewLayer
     
     */
    func addVideoPreviewLayer()
    {
        objCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: objCaptureSession)
        objCaptureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        objCaptureVideoPreviewLayer?.frame = view.layer.bounds
        self.view.layer.addSublayer(objCaptureVideoPreviewLayer!)
        objCaptureSession?.startRunning()
        //        self.view.bringSubview(toFront: qrResultLabel)
    }
    
    /**
     Method - initializeQRView
     
     - parameter description : It initialized the frame of QR code
     
     */
    func initializeQRView() {
        vwQRCode = UIView()
        //        vwQRCode?.layer.borderColor = UIColor.red.cgColor
        //        vwQRCode?.layer.borderWidth = 5
        self.view.addSubview(vwQRCode!)
        self.view.bringSubview(toFront: vwQRCode!)
    }
    
    /**
     Method - captureOutput
     
     - parameter description : To record output
     
     - parameter argument - AVCaptureOutput, metadataObjects as Any, AVCaptureConnection
     
     */
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
                //4:abcd - 4 is user id, abcd is code
                //already have array as snapshot
                //Break code here
                
                let mathString: String = randomQRCode
                let numbers = mathString.components(separatedBy: [":"])
                print(numbers)
                userId = numbers[0]
                
                getQrCodeStatus()
                
                objCaptureSession?.stopRunning()
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
        
        if IsConnectionAvailable(){
            print(snapshotReference)
            print(userId)
            if let dict = snapshotReference.childSnapshot(forPath: userId) as? FIRDataSnapshot{
                print(dict)
                if dict.childrenCount != 0{
                    print(dict.childrenCount)
                    if let snapValue = dict.value as? NSMutableDictionary{
                        print(snapValue)
                        let status = snapValue.value(forKey: "status")
                        let randomNmbr = snapValue.value(forKey: "code")
                        self.attendanceStatus = status as! String
                        let nmbr = String(describing: randomNmbr!)
                        
                        print(nmbr)
                        print(self.randomQRCode)
                        
                        
                        if (nmbr == self.randomQRCode){
                            print(nmbr)
                            print(self.randomQRCode)
                            if (self.attendanceStatus == "new"){
                                
                                let branchCode = defaults.value(forKey: "branchCode") as! String
                                
                                self.ref.child("mainAttendanceApp").child("branches").child(branchCode).child("qrCode").child("users").child(userId).updateChildValues(["status" : "old"])
                                
                                DispatchQueue.main.async {
                                    self.randomQRCode = ""
                                    
                                    self.vwQRCode?.frame = CGRect.zero
                                    self.objCaptureSession?.startRunning()
                                    let controller = self.parent as? HomeViewController
                                    let scrollView = controller?.mainScrollView
                                    scrollView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                                    
                                    
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MarkAttendanceOnServer"), object: nil)
                                    //                            self.ref.removeAllObservers()
                                }
                                
                            }
                            else{
                                print("different status")
                                
                                DispatchQueue.main.async {
                                    self.randomQRCode = ""
                                    
                                    self.vwQRCode?.frame = CGRect.zero
                                    self.objCaptureSession?.startRunning()
                                    
                                    let controller = self.parent as? HomeViewController
                                    let scrollView = controller?.mainScrollView
                                    scrollView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                                }
                                
                            }
                            
                        }else {
                            
                            print("different code")
                            
                            DispatchQueue.main.async {
                                self.randomQRCode = ""
                                
                                self.vwQRCode?.frame = CGRect.zero
                                self.objCaptureSession?.startRunning()
                                
                                let controller = self.parent as? HomeViewController
                                let scrollView = controller?.mainScrollView
                                scrollView?.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
                            }
                            
                        }
                        
                        
                        
                    }
                }
                else{
                    print("Null Snapshot")
                    DispatchQueue.main.async {
                        self.objCaptureSession?.stopRunning()
                        self.randomQRCode = ""
                        
                        self.vwQRCode?.frame = CGRect.zero
                        self.objCaptureSession?.startRunning()

                    }
                }
                
            }
            
        }
        else{
            let alert = ShowAlert()
            alert.title = "Alert"
            alert.message = "Check Network Connection"
            _ = self.present(alert, animated: true, completion: nil)
            
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
    
    //MARK: - Alert Controller
    //MARK: -
    
    
    /**
     Alert Controller Method
     
     - paramter return : Returns UIAlertController
     
     - parameter description : Method to intialize and add actions to alert controller
     */
    
    func ShowAlert() -> UIAlertController{
        let alertController = UIAlertController(title: "Alert", message: "Device not supported for this application", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (result : UIAlertAction) -> Void in
            self.dismiss(animated: false, completion: nil)
            print("Cancel")
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            self.dismiss(animated: false, completion: nil)
            print("OK")
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        //        _ = self.present(alertController, animated: true, completion: nil)
        return alertController
    }
}
