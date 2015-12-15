//
//  RandomColourViewController.swift
//  PullCam
//
//  Created by Matt Bettinson on 2015-09-15.
//  Copyright © 2015 Matt Bettinson. All rights reserved.
//

import UIKit

class RandomColourViewController: UIView {
    
    override func drawRect(rect: CGRect, forViewPrintFormatter formatter: UIViewPrintFormatter) {
        let bounds = self.bounds
        let destinationColour = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        while destinationColour.CIColor.red >= 0 {
            let newColour = UIColor(red: destinationColour.CIColor.red - 1, green: destinationColour.CIColor.green - 2, blue: destinationColour.CIColor.blue - 3, alpha: 1)
            self.backgroundColor = newColour
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.redColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

