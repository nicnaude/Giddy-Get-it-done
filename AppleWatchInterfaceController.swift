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
import GiddyKit

class AppleWatchInterfaceController: WKInterfaceController {
    @IBOutlet var tableView: WKInterfaceTable!
    @IBOutlet var watchLabel: WKInterfaceLabel!
    
    let moc = DataAccess.sharedInstance.managedObjectContext
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        //        setupTable()
        //         Configure interface objects here.
        let date: NSDate? = DataAccess.sharedInstance.getAppleWatchToDos()
        
        if date != nil {
            watchLabel.setText(date!.description)
        }
    }
    
    //    func setupTable() {
    //        tableView.setNumberOfRows(NSFetchedResultsController.count, withRowType: "CountryRow")
    //
    //        for var i = 0; i < countries.count; ++i {
    //            if let row = tableView.rowControllerAtIndex(i) as? CountryRow {
    //                row.countryName.setText(countries[i])
    //            }
    //        }
    //    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
