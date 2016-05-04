//
//  DataAccess.swift
//  Giddy
//
//  Created by Nicholas Naudé on 03/05/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import CoreData

public class DataAccess: NSObject {
    
    public class var sharedInstance : DataAccess {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : DataAccess? = nil
        }
        dispatch_once(&Static.onceToken){
            Static.instance = DataAccess()
        }
        return Static.instance!
    }
    
    
    // MARK: Get data for Apple Watch:
    public func getAppleWatchToDos()-> NSDate? {
        
        let request = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("GiddyToDo", inManagedObjectContext: self.managedObjectContext)
        request.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
        request.sortDescriptors = sortDescriptors
        
        var error: NSError? = nil
        print(error)
        let results: [AnyObject]?
        do {
            results = try self.managedObjectContext.executeFetchRequest(request)
        } catch let error1 as NSError {
            error = error1
            results = nil
        }
        //
        //        if !(DataAccess.sharedInstance.managedObjectContext.save() != nil) {
        //            print("Error fetching on the managed object context")
        //        }
        
        var date: NSDate?
        if results != nil {
            let managedObject: NSManagedObject = results![0] as! NSManagedObject
            date = managedObject.valueForKey("timeStamp") as? NSDate
        }
        
        return date
    }
    
    
    
    
    // MARK: - Core Data stack
    
    public lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.nicholasnaude.Giddy" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        print(urls)
        return urls[urls.count-1]
    }()
    
    public lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("GiddyDataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Initialize Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        ///
        //        let containerPath = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.projectds.coredatawatch.Documents")?.path
        //        print("Container path: \(containerPath)")
        //        let sqlitePath =  NSString(format:"%@/%@", containerPath!, "coredatawatch")
        //        print("sqlitepath: \(sqlitePath)")
        //
        //        let url = NSURL(fileURLWithPath: sqlitePath as String)
        //
        //        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        //        var error: NSError? = nil
        ///
        
        //delete from here:
        // URL Documents Directory
        let URLs = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let applicationDocumentsDirectory = URLs[(URLs.count - 1)]
        
        // URL Persistent Store
        let URLPersistentStore = applicationDocumentsDirectory.URLByAppendingPathComponent("Done.sqlite")
        
        do {
            // Add Persistent Store to Persistent Store Coordinator
            try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: URLPersistentStore, options: nil)
            
        } catch {
            // Populate Error
            var userInfo = [String: AnyObject]()
            
            //To here?
            userInfo[NSLocalizedDescriptionKey] = "There was an error creating or loading the application's saved data."
            userInfo[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            
            userInfo[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "com.tutsplus.Done", code: 1001, userInfo: userInfo)
            
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            
            abort()
        }
        
        return persistentStoreCoordinator
    }()
    
    public lazy var managedObjectContext: NSManagedObjectContext = {
        let persistentStoreCoordinator = self.persistentStoreCoordinator
        
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    public func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
} // End