//
//  ToDoObject.swift
//  Giddy
//
//  Created by Nicholas Naudé on 04/04/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import CoreData

class ToDoObject: NSManagedObject {
    
    @NSManaged var content: String
    @NSManaged var doneStatus: String
    
//    func createNewToDoObject(content: String, doneStatus: Bool) {
//        self.content = content
//        self.doneStatus = doneStatus
//    }
}
