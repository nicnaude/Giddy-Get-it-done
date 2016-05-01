//
//  EditToDoVC.swift
//  Giddy
//
//  Created by Nicholas Naudé on 04/04/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import CoreData

class EditToDoVC: UIViewController {
    
    @IBOutlet weak var editTextField: UITextField!
    @IBOutlet weak var markAsDoneButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var testLabel: UILabel!
    var selectedGiddy = GiddyToDo()
    
    var record: NSManagedObject!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    var detailItem: AnyObject! {
        didSet {
            print("Detail Item: \(detailItem)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("EditToDoVC moc: \(managedObjectContext)")
        self.editTextField.text = detailItem.description
    }
    //
    
    @IBAction func onMarkAsDoneTapped(sender: AnyObject) {
        managedObjectContext.deleteObject(record)
        print("\(record) successfully deleted")
        self.performSegueWithIdentifier("unwindToRoot", sender: self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        print(detailItem)
        let content = editTextField.text
        
        if let isEmpty = content?.isEmpty where isEmpty == false {
            // Update Record
            record.setValue(content, forKey: "content")
            
            do {
                // Save Record
                try record.managedObjectContext?.save()
                
                // Dismiss View Controller
                navigationController?.popViewControllerAnimated(true)
                
            } catch {
                let saveError = error as NSError
                print("\(saveError), \(saveError.userInfo)")
                
                // Show Alert View
                showAlertWithTitle("Warning", message: "Your to-do could not be saved.", cancelButtonTitle: "OK")
            }
            
        } else {
            // Show Alert View
            showAlertWithTitle("Warning", message: "Your to-do needs a name.", cancelButtonTitle: "OK")
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "unwindToRoot") {
            let destinatation = segue.destinationViewController as! RootVC
            destinatation.tableView.reloadData()
            print("Yay! Kittens")
        }
    }
    
}


