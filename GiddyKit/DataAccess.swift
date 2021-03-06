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
        
        var date: NSDate?
        if results != nil {
            let managedObject: NSManagedObject = results![0] as! NSManagedObject
            date = managedObject.valueForKey("timeStamp") as? NSDate
        }
        
        return date
    }
    
    
    // MARK: - Core Data stack
    public lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    
 
    
    public lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("GiddyDataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        let containerPath = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.giddyAppGroup")!.path
        print(containerPath)
        let sqlitePath = NSString(format: "%@/%@", containerPath!, "Giddy")
        let url = NSURL(fileURLWithPath: sqlitePath as String)
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var error: NSError? = nil
        
        var failureReason = "There was an error creating or loading the application's saved data."
        
        ///
        do
        {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        }
        catch(let error as NSError)
        {
            NSLog(error.localizedDescription) //error has occurred.
            abort() //abort
        }
        ///
        return coordinator
    }()
    //
    
    
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