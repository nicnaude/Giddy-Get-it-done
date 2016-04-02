//
//  ToDoRecord.swift
//  Giddy
//
//  Created by Nicholas Naudé on 24/03/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import Foundation
import CloudKit

class ToDo: NSObject {
//    var recordID: CKRecordID!
    var content: String!
    var doneStatus: String!

    func createNewToDo(content: String, doneStatus: String) {
//        self.recordID = recordID
        self.content = content
        self.doneStatus = doneStatus
        
//        self.userId = userId
//        self.name = name
//        self.profilePicture = profilePicture
//        self.gender = gender
//        self.latitude = latitude
//        self.longitude = longitude
//        self.bio = bio
    }
}