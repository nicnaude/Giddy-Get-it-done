//
//  AppleWatchInterfaceController.swift
//  Giddy
//
//  Created by Nicholas Naudé on 20/03/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import WatchKit
import Foundation
import CoreData
//import GiddyKit

class AppleWatchInterfaceController: WKInterfaceController {

    @IBOutlet var watchFaceLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        // Configure interface objects here.
//        let date: NSDate? = DataAccess.sharedInstance.getAppleWatchToDos()
        
//        if date != nil {
//            watchFaceLabel.setText(date!.description)
//        }
        watchFaceLabel.setText("Hello")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
