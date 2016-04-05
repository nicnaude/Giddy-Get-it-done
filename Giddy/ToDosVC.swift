//
//  ToDosVCViewController.swift
//  Giddy
//
//  Created by Nicholas Naudé on 04/04/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import CoreData

class ToDosVC: UIViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var addToDoTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //    var storedResults = [GiddyToDo]()
    var giddyToDo : [GiddyToDo] = []
    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.saveButton.enabled = false
        addToDoTextField.becomeFirstResponder()
        
        //setup textField
        addToDoTextField.layer.backgroundColor = UIColor.whiteColor().CGColor
        addToDoTextField.layer.borderColor = UIColor.whiteColor().CGColor
        addToDoTextField.layer.borderWidth = 1
        addToDoTextField.layer.cornerRadius = 5
        addToDoTextField.layer.masksToBounds = true
//        addToDoTextField.layer.shadowRadius = 2.0
//        addToDoTextField.layer.shadowColor = UIColor.blackColor().CGColor
//        addToDoTextField.layer.shadowOffset = CGSizeMake(1.0, 1.0)
//        addToDoTextField.layer.shadowOpacity = 1.0
//        addToDoTextField.layer.shadowRadius = 1.0
        
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            managedObjectContext = appDelegate.managedObjectContext
        }
        
        // set nav color
        navigationController?.navigationBar.barTintColor = UIColor(red:0.98, green:0.68, blue:0.09, alpha:1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        //watch textField for changes
        addToDoTextField.addTarget(self, action: #selector(ToDosVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
    }
    
    
    func textFieldDidChange(textField: UITextField) {
        self.saveButton.enabled = true
    }
    
    
    @IBAction func onSaveButtonTapped(sender: UIBarButtonItem) {
        if addToDoTextField.text != "" {
            let context = self.fetchedResultsController.managedObjectContext
            let entity = self.fetchedResultsController.fetchRequest.entity!
            let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
            
            newManagedObject.setValue(addToDoTextField.text, forKey: "content")
            newManagedObject.setValue(NSDate(), forKey: "timeStamp")
            
            // Save the context.
            do {
                try context.save()
                print("Saved successfully.")
                addToDoTextField.text = ""
                addToDoTextField.resignFirstResponder()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }
    
    func insertNewObject(sender: AnyObject) {

    }
    
    
    @IBAction func loadCoreData(sender: UIBarButtonItem) {
        print("Load tapped")
        let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "GiddyToDo")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "content = %@", addToDoTextField.text!)
        
        do {
            let results: NSArray = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                print("\(results.count) results found!")
            }
        } catch {
            print("No results found!")
        }
    }
    
    
    // MARK: TableView methods:
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        //        let currentToDo = storedResults[indexPath.row]
        //        cell.textLabel!.text = currentToDo.content
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        cell.textLabel!.text = object.valueForKey("content")!.description as String
        let image : UIImage = UIImage(named: "checked")!
        cell.imageView!.image = image
        
//        if selectedtedToDoStatus == "No" {
//            let image : UIImage = UIImage(named: "unchecked")!
//            cell.imageView!.image = image
//        } else if (selectedtedToDoStatus == "Yes") {
//            let image : UIImage = UIImage(named: "checked")!
//            cell.imageView!.image = image
//        }
        
        return cell
    }
    
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
// this is not very DRY:
        if addToDoTextField.text != "" {
            let context = self.fetchedResultsController.managedObjectContext
            let entity = self.fetchedResultsController.fetchRequest.entity!
            let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
            
            newManagedObject.setValue(addToDoTextField.text, forKey: "content")
            newManagedObject.setValue(NSDate(), forKey: "timeStamp")
            
            // Save the context.
            do {
                try context.save()
                print("Saved successfully.")
                addToDoTextField.text = ""
                addToDoTextField.resignFirstResponder()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
        
        //        textField.resignFirstResponder()
        return true
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return storedResults.count
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    
    // allow editing of the tableview
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // edit the tableview
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            
            do {
                try context.save()
            } catch {
                print("An error occured")
                abort()
            }
        }
    }
    
    
    // Configure cell
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        cell.textLabel!.text = object.valueForKey("content")!.description as String
    }
    
    
    // MARK: - Fetched results controller
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("GiddyToDo", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        //        fetchRequest.fetchBatchSize = 30
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            print("An error occured")
            abort()
        }
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    
} //END