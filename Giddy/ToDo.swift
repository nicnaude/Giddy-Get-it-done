//
//  ToDoRecord.swift
//  Giddy
//
//  Created by Nicholas Naudé on 24/03/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import Foundation
import CloudKit


class Message: EVCloudKitDataObject {
    // From which Channel is this message
    var From: CKReference? // = CKReference(recordID: CKRecordID(recordName: "N/A"), action: CKReferenceAction.None)
    var From_ID: String = ""
    func setFromFields(id: String) {
        self.From_ID = id
        self.From = CKReference(recordID: CKRecordID(recordName: id), action: CKReferenceAction.DeleteSelf)
}
}



//struct ToDo {
//    
//    let key: String!
//    let toDo: String!
//    var checked: String!
//    var db: CKDatabase!
//    //    let ref: Firebase?
//    
//    // Initialize from arbitrary data
//    init(key: String, toDo: String, checked: String) {
//        //init(name: String, completed: Bool, key: String = "") {
//        self.key = key
//        self.toDo = toDo
//        self.checked = checked
//        //        self.ref = nil
//    }
//    
