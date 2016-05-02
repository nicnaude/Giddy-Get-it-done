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
import WatchCoreDataProxy

class AppleWatchInterfaceController: WKInterfaceController {
    
    @IBOutlet var tableView: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        loadData()
    }
    
    func loadData() {
        
        let toDos = ["one", "two", "three"]
        
        tableView.setNumberOfRows(toDos.count, withRowType: "ToDoTableRowController")
        
        for (index, value) in toDos.enumerate() {
            
//            let row = tableView.rowControllerAtIndex(index) as ToDoTableRowController
//            row.titleLabel?.setText(value)
            
        }
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
