//
//  RootVCViewController.swift
//  Giddy
//
//  Created by Nicholas Naudé on 04/04/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import CoreData

class RootVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var addToDoTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var darkOverlay: UIView!
    @IBOutlet weak var imageOverlay: UIView!
    
    var editToDoVC: EditToDoVC? = nil
//    var managedObjectContext: NSManagedObjectContext? = nil
    var giddyToDo : [GiddyToDo] = []
    var selectedToDo: GiddyToDo! = nil
    var record: NSManagedObject!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "GiddyToDo")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    //
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        imageOverlay.hidden = true
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }

        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            managedObjectContext = appDelegate.managedObjectContext
            let context : NSManagedObjectContext = appDelegate.managedObjectContext
        }
        print("MOC: \(managedObjectContext)")
        
        // set nav color
        navigationController?.navigationBar.barTintColor = UIColor(red:0.98, green:0.68, blue:0.09, alpha:1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        //watch textField for changes
        addToDoTextField.addTarget(self, action: #selector(RootVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        hideTextFieldView()
        self.darkOverlay.alpha = 0
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RootVC.handleTap(_:)))
        self.darkOverlay.addGestureRecognizer(gestureRecognizer)
    }
    //
    
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureButton()
        tableView.reloadData()
    }
    //
    
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editTheToDo" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! GiddyToDo
                let selectedRecord = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
                print(object)
                let controller = segue.destinationViewController as! EditToDoVC
                controller.record = selectedRecord
                controller.detailItem = object.content! as String
                print("Controller.detailItem: \(object)")
                //                controller.title = object.content
                //               controller.editTextField.text = object.content
            }
        }
    }
    //
    
    
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        hideTextFieldView()
        self.addToDoTextField.resignFirstResponder()
        self.plusButton.hidden = false
        fadeOutOverlay()
        self.addToDoTextField.text = ""
    }
    //
    
    
    func configureButton()
    {
        plusButton.layer.cornerRadius = 0.5 * plusButton.bounds.size.width
        plusButton.layer.borderColor = UIColor(red:0.0/255.0, green:122.0/255.0, blue:255.0/255.0, alpha:1).CGColor as CGColorRef
        plusButton.layer.borderWidth = 0
        plusButton.clipsToBounds = true
    }
    //
    
    
    func textFieldDidChange(textField: UITextField) {
    }
    //
    
    
    // MARK: Animations
    func slideOutTextFieldView() {
        self.textFieldView.alpha = 1
        UIView.animateWithDuration(0.2, delay: 0.1, options: .CurveEaseIn, animations: {
            var textFieldViewToAnimate = self.textFieldView.frame
            textFieldViewToAnimate.origin.y += textFieldViewToAnimate.size.height
            
            self.textFieldView.frame = textFieldViewToAnimate
            }, completion: { finished in
                print("Textfield visible")
        })
    }
    //
    
    
    func hideTextFieldView() {
        UIView.animateWithDuration(0.2, delay: 0.1, options: .CurveEaseOut, animations: {
            self.textFieldView.alpha = 0
            }, completion: { finished in
                print("Textfield hidden")
        })
    }
    //
    
    
    func fadeInOverlay() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseIn, animations: {
            self.darkOverlay.alpha = 0.6
            }, completion: { finished in
                print("Fade in overlay")
        })
    }
    //
    
    
    func fadeOutOverlay() {
        UIView.animateWithDuration(0.2, delay: 0.1, options: .CurveEaseOut, animations: {
            self.darkOverlay.alpha = 0
            }, completion: { finished in
                print("Fade out overlay")
        })
    }
    //
    
    func fadeInDefaultImage() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseIn, animations: {
            self.imageOverlay.alpha = 1
            }, completion: { finished in
                print("Fade in default image")
        })
    }
    //
    
    
    func fadeOutDefaultImage() {
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.imageOverlay.alpha = 0
            }, completion: { finished in
                print("Fade out default image")
        })
    }
    //
    
    
    @IBAction func onPlusButtonTapped(sender: UIButton) {
        slideOutTextFieldView()
        self.plusButton.hidden = true
        fadeInOverlay()
        addToDoTextField.becomeFirstResponder()
    }
    //
    
    
    // MARK: Textfield method:
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if addToDoTextField.text != "" {
            ///
            let context = self.fetchedResultsController.managedObjectContext
            let entity = self.fetchedResultsController.fetchRequest.entity!
            let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
            
            newManagedObject.setValue(addToDoTextField.text, forKey: "content")
            newManagedObject.setValue("no", forKey: "doneStatus")
            newManagedObject.setValue(NSDate(), forKey: "timeStamp")
            
            do {
                try context.save()
                print("Saved successfully.")
                addToDoTextField.text = ""
                addToDoTextField.resignFirstResponder()
                hideTextFieldView()
                fadeOutOverlay()
                self.plusButton.hidden = false
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
            
            ///
            //
            //            let appDel : AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            //            let context : NSManagedObjectContext = appDel.managedObjectContext
            //
            //
            //            let entity = self.fetchedResultsController.fetchRequest.entity!
            //            let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
            //
            //            newManagedObject.setValue(addToDoTextField.text, forKey: "content")
            //            newManagedObject.setValue("no", forKey: "doneStatus")
            //            newManagedObject.setValue(NSDate(), forKey: "timeStamp")
            //
            //            do {
            //                try context.save()
            //                print("Saved successfully.")
            //                addToDoTextField.text = ""
            //                addToDoTextField.resignFirstResponder()
            //                hideTextFieldView()
            //                fadeOutOverlay()
            //                self.plusButton.hidden = false
            //            } catch {
            //                // Replace this implementation with code to handle the error appropriately.
            //                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //                //print("Unresolved error \(error), \(error.userInfo)")
            //                abort()
            //        }
        }
        
        return true
    }
    //
    
    
    
    // MARK: TableView methods:
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        
        cell.textLabel!.text = object.valueForKey("content")!.description as String
        
        cell.textLabel!.font = UIFont(name:"SF UI Display Regular", size:18)
        
        if object.valueForKey("doneStatus") as! String == "no" {
            let image : UIImage = UIImage(named: "unchecked")!
            cell.imageView!.image = image
        } else if object.valueForKey("doneStatus") as! String == "yes" {
            let image : UIImage = UIImage(named: "checked")!
            cell.imageView!.image = image
        }
        
        cell.imageView!.transform = CGAffineTransformMakeScale(3, 3)
        cell.imageView!.userInteractionEnabled = true
        cell.imageView!.tag = indexPath.row
        cell.backgroundColor? = UIColor.whiteColor()
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(RootVC.tappedMe))
        tap.numberOfTapsRequired = 1
        cell.imageView!.addGestureRecognizer(tap)
        
        return cell
    }
    //
    
    
    func tappedMe(sender: UITapGestureRecognizer) {
        print("Tap detected")
        let touch = sender.locationInView(tableView)
        
        if let indexPath = tableView.indexPathForRowAtPoint(touch) {
            
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            cell?.backgroundColor = UIColor.lightGrayColor()
            
            let object = fetchedResultsController.objectAtIndexPath(indexPath)
            
            let context = fetchedResultsController.managedObjectContext
            
            UIView.animateWithDuration(1, delay: 4, options: .CurveEaseOut, animations: {
                cell!.imageView?.image = UIImage(named: "checked")
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
                }, completion: { finished in
                    print("Object deleted")
            })
            
            context.deleteObject(fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
            
            self.tableView.reloadData()
            print(object)
            //
        } else {
            print("Could not find index path")
        }
    }//
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    //
    
    // MARK: -
    // MARK: Table View Data Source Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Fetch Record
        let cell = UITableViewCell()
        let record = fetchedResultsController.objectAtIndexPath(indexPath)
        
        // Update Cell
        if let contentForLabel = record.valueForKey("content") as? String {
            cell.textLabel!.text = contentForLabel
        }

        if record.valueForKey("doneStatus") as! String == "no" {
            let image : UIImage = UIImage(named: "unchecked")!
            cell.imageView!.image = image
        } else if record.valueForKey("doneStatus") as! String == "yes" {
            let image : UIImage = UIImage(named: "checked")!
            cell.imageView!.image = image
        }
        
//        cell.didTapButtonHandler = {
//            if let done = record.valueForKey("done") as? Bool {
//                record.setValue(!done, forKey: "done")
//            }
//        }
    }


    
    
    //    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //
    //        let sectionInfo = self.fetchedResultsController.sections![section]
    //        if sectionInfo.numberOfObjects == 0 {
    //            fadeInDefaultImage()
    //        } else {
    //            fadeOutDefaultImage()
    //        }
    //
    //        return sectionInfo.numberOfObjects
    //    }
    //
    
    
    // allow editing of the tableview
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    //
    
    
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
    //
    
    
//    // Configure cell
//    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
//        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
//        cell.textLabel!.text = object.valueForKey("content")!.description as String
//    }
//    //
    
    // MARK: -
    // MARK: Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRowAtIndexPath(indexPath) // as! ToDoCell
                configureCell(cell!, atIndexPath: indexPath)
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }
    
    
    
    //    // MARK: - Fetched results controller
    //    var fetchedResultsController: NSFetchedResultsController {
    //        if _fetchedResultsController != nil {
    //            return _fetchedResultsController!
    //        }
    //
    //        let fetchRequest = NSFetchRequest()
    //        let entity = NSEntityDescription.entityForName("GiddyToDo", inManagedObjectContext: self.managedObjectContext!)
    //        fetchRequest.entity = entity
    //
    //        // Edit the sort key as appropriate.
    //        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
    //
    //        fetchRequest.sortDescriptors = [sortDescriptor]
    //
    //        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
    //        aFetchedResultsController.delegate = self
    //        _fetchedResultsController = aFetchedResultsController
    //
    //        do {
    //            try _fetchedResultsController!.performFetch()
    //        } catch {
    //            print("An error occured")
    //            abort()
    //        }
    //        return _fetchedResultsController!
    //    }
    //    var _fetchedResultsController: NSFetchedResultsController? = nil
    //
    //
    //    func controllerWillChangeContent(controller: NSFetchedResultsController) {
    //        self.tableView.beginUpdates()
    //    }
    //    //
    //
    //
    //    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    //        switch type {
    //        case .Insert:
    //            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Top)
    //        case .Delete:
    //            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Top)
    //        default:
    //            return
    //        }
    //    }
    //    //
    //
    //
    //    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    //        switch type {
    //        case .Insert:
    //            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    //        case .Delete:
    //            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
    //        case .Update:
    //            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
    //        case .Move:
    //            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
    //            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    //        }
    //    }
    //    //
    //
    //
    //
    //    func controllerDidChangeContent(controller: NSFetchedResultsController) {
    //        self.tableView.endUpdates()
    //    }
    //    //
    
} //END




