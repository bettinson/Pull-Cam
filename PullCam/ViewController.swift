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
    let expandedHeight : CGFloat = 20
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession.sessionPreset? = AVCaptureSessionPreset1920x1080
        let devices = AVCaptureDevice.devices()
        let pSelector : Selector = "handleDragDown:"
        let pullDownRecognizer = UIPanGestureRecognizer(target: self, action: pSelector)
        pullDownRecognizer.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(pullDownRecognizer)
        
        
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if (device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
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
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
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
        //focusTo(Float(touchPercentFocus))
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var anyTouch = touches.anyObject() as UITouch
        var touchPercentFocus = anyTouch.locationInView(self.view).x
        //focusTo(Float(touchPercentFocus))
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        println("Ended touches")
    }
    
    // Pan Gesture handler
    
    var dragStartPositionRelativeToCenter : CGPoint?
    func handleDragDown(pull : UIPanGestureRecognizer) {
        if (pull.state == UIGestureRecognizerState.Began) {
            let locationInView = pull.locationInView(self.view)
            dragStartPositionRelativeToCenter = CGPoint(x: self.view.center.x, y: locationInView.y - self.view.center.y)
            return
        }
        
        if pull.state == UIGestureRecognizerState.Ended {
            let locationInView = pull.locationInView(self.view)
            if (locationInView.y > -self.expandedHeight && locationInView.y < CGFloat(0.0)) {
                println("Dragged enough")
            } else {
                
                var springRatio = -(pull.translationInView(self.view).y / self.view.bounds.origin.y)
                
                println(springRatio)
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: springRatio * 0.25, initialSpringVelocity: springRatio * 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
                    self.view.bounds.origin = CGPoint(x: self.view.bounds.origin.x, y: 0)
                }), completion:nil)
            }
            dragStartPositionRelativeToCenter = nil
            return
        }
        
        let locationInView = pull.locationInView(self.view)
        
        UIView.animateWithDuration(0.1) {
            self.view.bounds.origin = CGPoint(x: self.view.bounds.origin.x, y:-(pull.translationInView(self.view).y) - self.view.bounds.origin.y )
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

