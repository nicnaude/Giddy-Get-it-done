//
//  ToDoItem.swift
//  Giddy
//
//  Created by Nicholas Naudé on 03/04/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import Foundation
import CloudKit

class ToDoItem: CKRecord {
//    var recordID: CKRecordID = ""
    var content: String = ""
    var doneStatus: String = ""
    
//    mutating func createNewToDoItem(recordID: CKRecordID, content: String, doneStatus: String) {
//        self.recordID = recordID
//        self.content = content
//        self.doneStatus = doneStatus
//    }
}
