//
//  ViewController.swift
//  PullCam
//
//  Created by Matt Bettinson on 2015-02-23.
//  Copyright (c) 2015 Matt Bettinson. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var stillImageOutput: AVCaptureStillImageOutput?
    
    

    let expandedHeight : CGFloat = 70.0
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession.sessionPreset? = AVCaptureSessionPresetPhoto
        
        self.navigationController?.title = "Take picture"

        
        let devices = AVCaptureDevice.devices()
        let pSelector : Selector = "handleDragDown:"
        let pullDownRecognizer = UIPanGestureRecognizer(target: self, action: pSelector)
        pullDownRecognizer.maximumNumberOfTouches = 1
        
        self.view.addGestureRecognizer(pullDownRecognizer)
        
        var backCamera  = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error : NSError?
        var input = AVCaptureDeviceInput(device: backCamera, error: &error)
        
//        if error == nil && captureSession.canAddInput(input) {
//            captureSession.addInput(input)
//            stillImageOutput = AVCaptureStillImageOutput()
//            
//            stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
//        }
        
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if (device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    stillImageOutput = AVCaptureStillImageOutput()
                    stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]

                }
            }
        }
        if captureDevice != nil {
            beginSession()
        }

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func beginSession() {
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        if err != nil {
            println("Error: \(err?.localizedDescription)")
        }
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        self.view.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.view.layer.frame
        captureSession.startRunning()
        
    }
    
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = .Locked
            device.unlockForConfiguration()
        }
    }
    
    func focusTo(value : Float) {
        var ratioValue = Float(value)/Float(self.view.frame.width)
        if let device = captureDevice {
            if (device.lockForConfiguration(nil)) {
                device.setFocusModeLockedWithLensPosition(ratioValue, completionHandler: {
                    (time) -> Void in
                })
                device.unlockForConfiguration()
            }
            println(ratioValue)
        }
    }
    

    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var anyTouch = touches.anyObject() as UITouch
        var touchPercentFocus = anyTouch.locationInView(self.view).x
//        handleDragDown(pull: )
        //focusTo(Float(touchPercentFocus))
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var anyTouch = touches.anyObject() as UITouch
        var touchPercentFocus = anyTouch.locationInView(self.view).x
        //focusTo(Float(touchPercentFocus))
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        println("Ended touches")
        //takeStillImage()
    }
    
    // Pan Gesture handler
    
    var dragStartPositionRelativeToCenter : CGPoint?
    
    func handleDragDown(pull : UIPanGestureRecognizer) {
        if (pull.state == UIGestureRecognizerState.Began) {
            let locationInView = pull.locationInView(self.view)
            dragStartPositionRelativeToCenter = CGPoint(x: self.view.center.x, y: locationInView.y - self.view.center.y)
            return
        }
        
        if pull.state == UIGestureRecognizerState.Changed {
            if (pull.translationInView(self.view).y > self.expandedHeight && pull.translationInView(self.view).y > CGFloat(0.0)) {
                //TODO: Indicator animation
            }
        }
        
        if pull.state == UIGestureRecognizerState.Ended {
            if (pull.translationInView(self.view).y > self.expandedHeight && pull.translationInView(self.view).y > CGFloat(0.0)) {
                println("Took a picture")
                takeStillImage()
                animateBackFromPull(pull)
            } else {
                animateBackFromPull(pull)
            }
            dragStartPositionRelativeToCenter = nil
            return
        }
        
        if (pull.translationInView(self.view).y > self.expandedHeight && pull.translationInView(self.view).y < CGFloat(0.0)) {
//            println("lmaooooo")
        }
        
        let locationInView = pull.locationInView(self.view)
        UIView.animateWithDuration(0.1) {
            self.view.bounds.origin = CGPoint(x: self.view.bounds.origin.x, y:-(pull.translationInView(self.view).y) - self.view.bounds.origin.y )
        }
    }

    func animateBackFromPull (sender : AnyObject) {
        var springRatio = -(sender.translationInView(self.view).y / self.view.bounds.origin.y)
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: springRatio * 0.25, initialSpringVelocity: springRatio * 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
            self.view.bounds.origin = CGPoint(x: self.view.bounds.origin.x, y: 0)
        }), completion:nil)
    }
    
    func takeStillImage(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            //find the video connection
            if let videoConnection = self.stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
                videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
                println("got here")
                self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer : CMSampleBufferRef!, error) in
                    if (sampleBuffer != nil) {
                        let imageDataJpeg = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        var pickedImage: UIImage = UIImage(data: imageDataJpeg)!
                        UIImageWriteToSavedPhotosAlbum(pickedImage,nil,nil,nil)
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

