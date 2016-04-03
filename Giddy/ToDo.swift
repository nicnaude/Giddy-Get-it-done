//
//  ToDoRecord.swift
//  Giddy
//
//  Created by Nicholas Naudé on 24/03/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import Foundation
import CloudKit

class ToDo {
    //    var recordID: CKRecordID = CKRecordID(recordName: NSUUID().UUIDString)
    var giddyRecordID: CKRecordID!
    var content: String = ""
    var doneStatus: String = ""

    func createNewToDo(recordID: CKRecordID, content: String, doneStatus: String) {
        self.giddyRecordID = recordID
        self.content = content
        self.doneStatus = doneStatus
//        super.init()
    }
    
//    required init(coder aDecoder: NSCoder)
//    {
//        super.init(coder: aDecoder)!
//    }
    
    //    convenience init(content: String, doneStatus: String) {
    //        let content = content
    //        let doneStatus = doneStatus
    ////        self.init(content: content, doneStatus: doneStatus)
    //    }
    //
    //    required init?(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
}

