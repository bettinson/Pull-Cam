//
//  RandomColourViewController.swift
//  PullCam
//
//  Created by Matt Bettinson on 2015-09-15.
//  Copyright © 2015 Matt Bettinson. All rights reserved.
//

import UIKit

class RandomColourViewController: UIViewController {

    var bounds = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
    var mainView : UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.redColor()
        randomizeColour()
    }
    
    init (_view : UIViewController) {
        self.mainView = _view
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func randomizeColour () {
        let destinationColour = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
        while destinationColour.CIColor.red >= 0 {
            let newColour = UIColor(red: destinationColour.CIColor.red - 1, green: destinationColour.CIColor.green - 2, blue: destinationColour.CIColor.blue - 3, alpha: 1)
            mainView.view.backgroundColor = newColour
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

