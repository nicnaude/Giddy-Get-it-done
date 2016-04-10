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
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var darkOverlay: UIView!
    
    @IBOutlet weak var imageOverlay: UIView!
    var giddyToDo : [GiddyToDo] = []
    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None

        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            managedObjectContext = appDelegate.managedObjectContext
        }
    
        // set nav color
        navigationController?.navigationBar.barTintColor = UIColor(red:0.98, green:0.68, blue:0.09, alpha:1.0)
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        //watch textField for changes
        addToDoTextField.addTarget(self, action: #selector(ToDosVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
    
        hideTextFieldView()
        self.darkOverlay.alpha = 0
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ToDosVC.handleTap(_:)))
        self.darkOverlay.addGestureRecognizer(gestureRecognizer)
        
    }
    //
    
    
    override func viewDidLayoutSubviews() {
        configureButton()
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
        if addToDoTextField.text != "" {
            let context = self.fetchedResultsController.managedObjectContext
            let entity = self.fetchedResultsController.fetchRequest.entity!
            let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
            
            newManagedObject.setValue(addToDoTextField.text, forKey: "content")
            newManagedObject.setValue(NSDate(), forKey: "timeStamp")
            
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
    //
    
    
    // MARK: Textfield method:
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if addToDoTextField.text != "" {
            let context = self.fetchedResultsController.managedObjectContext
            let entity = self.fetchedResultsController.fetchRequest.entity!
            let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context)
            
            newManagedObject.setValue(addToDoTextField.text, forKey: "content")
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
        }
        
        return true
    }
    //
    
    
    // MARK: TableView methods:
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        cell.textLabel!.text = object.valueForKey("content")!.description as String
        let image : UIImage = UIImage(named: "unchecked")!
        cell.textLabel!.font = UIFont(name:"San Francisco", size:16)
        cell.textLabel!.numberOfLines = 0
        
        //imageView
        cell.imageView!.userInteractionEnabled = true
        cell.imageView!.tag = indexPath.row
        cell.imageView!.transform = CGAffineTransformMakeScale(0.1, 0.1)
        cell.imageView!.image = image
        
        return cell
    }
    //
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    //
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return storedResults.count
        let sectionInfo = self.fetchedResultsController.sections![section]
            if sectionInfo.numberOfObjects == 0 {
                fadeInDefaultImage()
            } else {
                fadeOutDefaultImage()
            }
        return sectionInfo.numberOfObjects
    }
    //
    
    
    // allow editing of the tableview
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
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
    
    
    // Configure cell
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        cell.textLabel!.text = object.valueForKey("content")!.description as String
    }
    //
    
    
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
    //
    
    
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
    //
    
    
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
    //
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    
} //END