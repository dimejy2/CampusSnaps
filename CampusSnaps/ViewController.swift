//
//  ViewController.swift
//  CampusSnaps
//
//  Created by Oladimeji Abidoye on 2/14/15.
//  Copyright (c) 2015 Dimeji Abidoye. All rights reserved.
//

import UIKit
import AVFoundation
import Social

class ViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    
    // our global session
    private let captureSession = AVCaptureSession()
    // the camera, if found
    private var captureDevice : AVCaptureDevice?
    // which camera
    private var cameraPosition = AVCaptureDevicePosition.Back
    // JPEG output
    private var stillImageOutput : AVCaptureStillImageOutput?
    // preview layer
    private var previewLayer : AVCaptureVideoPreviewLayer?
    // dropbox rest client
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Terrible place to put this.  we'll fix later.
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        if findCamera(cameraPosition) {
            // start session
            beginSession()
        } else {
            // show sad error
        }
        
    }
    
    @IBAction func rewindFromSegue(segue:UIStoryboardSegue) {
        println("User aborted sending a photo")
    }
    
    
    // find camera
    func findCamera(position : AVCaptureDevicePosition) -> Bool {
        
        // grab all video capture devices
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        // find the camera matching the position
        for device in devices {
            if device.position == position {
                captureDevice = device as? AVCaptureDevice
            }
        }
        
        return captureDevice != nil
        
    }
    
    // start the capture session
    func beginSession() {
        var err : NSError? = nil
        
        // try to open the device
        let videoCapture = AVCaptureDeviceInput(device: captureDevice, error: &err)
        
        if err != nil {
            // Fail silently.  Do better in the real world.
            println("Capture session could not start: \(err?.description)")
            return
        }
        
        // add video input
        if captureSession.canAddInput(videoCapture) {
            captureSession.addInput(videoCapture)
        }
        
        // config capture session
        if !captureSession.running {
            // set JPEG output
            stillImageOutput = AVCaptureStillImageOutput()
            let outputSettings = [ AVVideoCodecKey : AVVideoCodecJPEG ]
            stillImageOutput!.outputSettings = outputSettings
            
            // add output to session
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            
            // display camera in UI
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.view.layer.addSublayer(previewLayer)
            previewLayer?.frame = self.view.layer.frame
            previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            // start camera
            captureSession.startRunning()
        }
    }
    
    
    
    @IBAction func flipCamera(sender: UIButton) {
        // Flip the camera
        
        // when session is running to make change you must...
        captureSession.beginConfiguration()
        // find and remove input
        let currentInput = captureSession.inputs[0] as AVCaptureInput
        captureSession.removeInput(currentInput)
        
        // toggle camera (if this then that if not then that)
        cameraPosition = cameraPosition == .Back ? .Front : .Back
        
        // find other camera
        if findCamera(cameraPosition) {
            beginSession()
        } else {
            // show sad panda
        }
        
        // commit changes
        captureSession.commitConfiguration()
    }
    
    @IBAction func takePhoto(sender: UIButton) {
        if let stillOutput = self.stillImageOutput {
            
            // we do this on another thread so we don't hang the UI
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                // find video connection
                var videoConnection : AVCaptureConnection?
                for connection in stillOutput.connections {
                    // find a matching input port
                    for port in connection.inputPorts! {
                        // and matching type
                        if port.mediaType == AVMediaTypeVideo {
                            videoConnection = connection as? AVCaptureConnection
                            break
                        }
                    }
                    if videoConnection != nil {
                        break // for connection
                    }
                }
                
                if videoConnection != nil {
                    // found the video connection, let's get the image
                    stillOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                        (imageSampleBuffer:CMSampleBuffer!, _) in
                        
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                        self.didTakePhoto(imageData)
                    }
                }
            }
        }
    }
    
    class func getSnapFileName() -> (String, String) {
        let fileName = "lastSnap.jpg"
        let tmpDirectory = NSTemporaryDirectory()
        let snapFileName = tmpDirectory.stringByAppendingPathComponent(fileName)
        
        return (fileName, snapFileName)
    }
    
    func didTakePhoto(imageData: NSData) {
        // parse not dropbox
        let image = UIImage(data: imageData)
        let compressedImage = compressImage(image!)
        let (_, fullFileName) = ViewController.getSnapFileName()
        compressedImage.writeToFile(fullFileName, atomically: true)
        
        // Show the preview window ..
        var sendNav = self.storyboard?.instantiateViewControllerWithIdentifier("SendNav") as UIViewController!
        self.presentViewController(sendNav, animated: true, completion: nil)
        
        /*
        // Example 1: if you want to show thumbnail
        let image = UIImage(data: imageData)
        let compressedImage = compressImage(image)
        
        // Example 2: if you want to save image
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let prefix: String = formatter.stringFromDate(NSDate())
        let fileName = "\(prefix).jpg"
        
        let tmpDirectory = NSTemporaryDirectory()
        let snapFileName = tmpDirectory.stringByAppendingPathComponent(fileName)
        compressedImage.writeToFile(snapFileName, atomically: true)
        
        // upload to dropbox
        dbRestClient?.uploadFile(fileName, toPath: "/", withParentRev: nil, fromPath: snapFileName)
        */
        
        
        
    }
    
    
    func compressImage(image:UIImage) -> NSData {
        // Drops from 2MB -> 64 KB!!!
        
        var actualHeight : CGFloat = image.size.height
        var actualWidth : CGFloat = image.size.width
        var maxHeight : CGFloat = 1136.0
        var maxWidth : CGFloat = 640.0
        var imgRatio : CGFloat = actualWidth/actualHeight
        var maxRatio : CGFloat = maxWidth/maxHeight
        var compressionQuality : CGFloat = 0.5
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }
        
        var rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        image.drawInRect(rect)
        var img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(img, compressionQuality);
        UIGraphicsEndImageContext();
        
        return imageData;
    }

    
    
    
}

