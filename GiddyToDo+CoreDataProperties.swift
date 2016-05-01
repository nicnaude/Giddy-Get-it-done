//
//  GiddyToDo+CoreDataProperties.swift
//  Giddy
//
//  Created by Nicholas Naudé on 01/05/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension GiddyToDo {

    @NSManaged var content: String!
    @NSManaged var doneStatus: String!
    @NSManaged var timeStamp: NSDate!

}
