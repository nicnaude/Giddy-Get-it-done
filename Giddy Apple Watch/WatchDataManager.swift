//
//  WatchDataManager.swift
//  Giddy
//
//  Created by Nicholas Naudé on 02/05/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import CoreData

class WatchDataManager: NSObject {
    public class DataManager: NSObject {
        public class func getContext() -> NSManagedObjectContext {
            return WatchCoreDataProxy.sharedInstance.managedObjectContext!
        }
        
        public class func deleteManagedObject(object:NSManagedObject) {
            getContext().deleteObject(object)
            saveManagedContext()
        }
        
        public class func saveManagedContext() {
            var error : NSError? = nil
            do {
                try getContext().save()
            } catch let error1 as NSError {
                error = error1
                NSLog("Unresolved error saving context \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}
