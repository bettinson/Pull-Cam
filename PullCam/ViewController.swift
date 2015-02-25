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

    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession.sessionPreset? = AVCaptureSessionPreset1920x1080
        let devices = AVCaptureDevice.devices()
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
    
    
    
    func moveScreen(value : Float) {
        var ratioValue = Float(value)/Float(self.view.frame.height)
        if let device = captureDevice {
            self.view.frame.origin.y += CGFloat(ratioValue)
        }
    }
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width
    let screenHeight = UIScreen.mainScreen().bounds.size.height
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        var anyTouch = touches.anyObject() as UITouch
        var touchPercentFocus = anyTouch.locationInView(self.view).x
        var touchPercentCapture = anyTouch.locationInView(self.view).y

        moveScreen(Float(touchPercentCapture))
        focusTo(Float(touchPercentFocus))
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var anyTouch = touches.anyObject() as UITouch
        var touchPercentFocus = anyTouch.locationInView(self.view).x
        var touchPercentCapture = anyTouch.locationInView(self.view).y
        moveScreen(Float(touchPercentCapture))
        focusTo(Float(touchPercentFocus))
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        println("Ended touches")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

