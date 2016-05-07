import UIKit
import CoreData
import GiddyKit

class RootVC: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var addToDoTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var darkOverlay: UIView!
    @IBOutlet weak var imageOverlay: UIView!
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    var editToDoVC: EditToDoVC? = nil
    var giddyToDo : [GiddyToDo] = []
    var selectedToDo: GiddyToDo! = nil
    var record: NSManagedObject!
    let moc = DataAccess.sharedInstance.managedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "GiddyToDo")
        
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataAccess.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    //
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
        print("MOC: \(moc)")
        
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
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
            }
        )}
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureButton()
    }
    //
    
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editTheToDo" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! GiddyToDo
                let selectedRecord = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
                let controller = segue.destinationViewController as! EditToDoVC
                controller.record = selectedRecord
                controller.detailItem = object.content! as String
                controller.selectedGiddyContent = object.content! as String
            } else if (segue.identifier == "unwindToRoot") {
                print("Yay! Hamsters!")
            }
        }
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
    
    
    // MARK: Textfield methods:
    func textFieldDidChange(textField: UITextField) {
        print("Typing detected.")
    }
    //
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if addToDoTextField.text != "" {
            ///
            let entityDescription = NSEntityDescription.entityForName("GiddyToDo", inManagedObjectContext: DataAccess.sharedInstance.managedObjectContext)
            let allTheToDos = GiddyToDo(entity:entityDescription!, insertIntoManagedObjectContext:moc)
            allTheToDos.content = addToDoTextField.text
            allTheToDos.doneStatus = "no"
            allTheToDos.timeStamp = NSDate()
            
            do {
                try DataAccess.sharedInstance.managedObjectContext.save()
                print("Saved successfully.")
                addToDoTextField.text = ""
                addToDoTextField.resignFirstResponder()
                hideTextFieldView()
                fadeOutOverlay()
                self.plusButton.hidden = false
            } catch {
                showAlertWithTitle("Error", message: "Unable to load to-do.", cancelButtonTitle: "Cancel")
                //                abort()
            }
        }
        return true
    }
    //
    
    //MARK: Gesture recognizer methods:
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        hideTextFieldView()
        self.addToDoTextField.resignFirstResponder()
        self.plusButton.hidden = false
        fadeOutOverlay()
        self.addToDoTextField.text = ""
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
            
            //            self.tableView.reloadData()
            print(object)
            //
        } else {
            print("Could not find index path")
        }
    }//
    
    
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
        cell.textLabel!.font = UIFont(name:"Avenir", size:17)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(RootVC.tappedMe))
        tap.numberOfTapsRequired = 1
        cell.imageView!.addGestureRecognizer(tap)
        
        return cell
    }
    //
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            imageOverlay.hidden = true
            return sectionInfo.numberOfObjects
        } else {
            imageOverlay.hidden = true
            return 0
        }
    }
    //
    
    
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
    }
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
    
    // MARK: -
    // MARK: Helper Methods
    private func showAlertWithTitle(title: String, message: String, cancelButtonTitle: String) {
        // Initialize Alert Controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Configure Alert Controller
        alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .Default, handler: nil))
        
        // Present Alert Controller
        presentViewController(alertController, animated: true, completion: nil)
    }
    
} //END




