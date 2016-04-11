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
    
    func imageTapped(img: AnyObject)
    {
        // Your action
    }
    
    
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
    }
    //
    
    
    // MARK: Textfield method:
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if addToDoTextField.text != "" {
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
        }
        
        return true
    }
    //
    
    
    // MARK: TableView methods:
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        cell.textLabel!.text = object.valueForKey("content")!.description as String
        cell.textLabel!.font = UIFont(name:"San Francisco", size:16)
        
        //imageView
        if object.valueForKey("doneStatus") as! String == "no" {
            let image : UIImage = UIImage(named: "unchecked")!
            cell.imageView!.image = image
        } else if object.valueForKey("doneStatus") as! String == "yes" {
            let image : UIImage = UIImage(named: "checked")!
            cell.imageView!.image = image
        }
        
        cell.imageView!.userInteractionEnabled = true
        cell.imageView!.tag = indexPath.row
        cell.imageView!.transform = CGAffineTransformMakeScale(0.4, 0.4)
        
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(ToDosVC.tappedMe))
        //        cell.imageView!.addGestureRecognizer(tap)
        //        cell.imageView!.userInteractionEnabled = true
        
        
        //        let longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress")
        //        cell.addGestureRecognizer(longPress)
        //        longPress.minimumPressDuration = 1.0
        //        longPress.delegate = longPress.delegate
        
        let longPress = UILongPressGestureRecognizer(target: self, action: Selector("longPressGestureRecognized:"))
        longPress.minimumPressDuration = 0.5
        longPress.numberOfTouchesRequired = 1
        cell.addGestureRecognizer(longPress)
        
        return cell
    }
    //
    
    
    func longPressGestureRecognized(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            performSegueWithIdentifier("editToDo", sender: self)
            print("Long press detected.")
        }
    }
    //
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        
        //        let selectedobject = self.fetchedResultsController.objectAtIndexPath(indexPath)
        
        let context = self.fetchedResultsController.managedObjectContext
        
        UIView.animateWithDuration(0.7, delay: 4, options: .CurveEaseOut, animations: {
            cell.imageView?.image = UIImage(named: "checked")
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            }, completion: { finished in
                print("Object deleted")
        })
        
        context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
        
        self.tableView.reloadData()
        //
        //
        //        if object.valueForKey("doneStatus") as! String == "no" {
        //            selectedobject.setValue("yes", forKey: "doneStatus")
        //            cell.imageView?.image = UIImage(named: "checked")
        //            //            cell.textLabel?.text = NSAttributedString.
        //            print("The to-do is now done")
        //        } else if object.valueForKey("doneStatus") as! String == "yes" {
        //            selectedobject.setValue("no", forKey: "doneStatus")
        //            cell.imageView?.image = UIImage(named: "unchecked")
        //            print("The to-do is NOT done")
        //        }
        print(object)
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
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Top)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Top)
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
    //
    
} //END