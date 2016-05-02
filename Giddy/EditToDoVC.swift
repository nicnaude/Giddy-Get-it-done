//
//  EditToDoVC.swift
//  Giddy
//
//  Created by Nicholas Naudé on 04/04/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import CoreData

class EditToDoVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var editTextView: UITextView!
    var selectedGiddyContent = String()
    
    var record: NSManagedObject!
    let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    
    var detailItem: AnyObject! {
        didSet {
            print("Detail Item: \(detailItem)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editTextView.becomeFirstResponder()
        fetchSelectedToDo()
        print("EditToDoVC moc: \(moc)")
        self.editTextView.text = detailItem.description
    }
    //
    
    
    //Fetch entity
    func fetchSelectedToDo() {
        let entityDescription = NSEntityDescription.entityForName("GiddyToDo", inManagedObjectContext: moc)
        let request = NSFetchRequest()
        request.entity = entityDescription
        let condition = NSPredicate(format: "content = %@", selectedGiddyContent)
        request.predicate = condition
        
        print("I found what you're looking for: \(request.predicate)")
        
        do {
            let result = try moc.executeFetchRequest(request)
            if result.count > 0 {
                let allTheToDos = result[0] as! GiddyToDo
                editTextView.text = allTheToDos.content as String
                self.title = allTheToDos.content as String
            } else {
                showAlertWithTitle("Error", message: "Unable to load to-do.", cancelButtonTitle: "Cancel")
            }
        } catch {
            showAlertWithTitle("Error", message: "Unable to load to-do.", cancelButtonTitle: "Cancel")
        }
    }
    //
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let entityDescription = NSEntityDescription.entityForName("GiddyToDo", inManagedObjectContext: moc)
        let request = NSFetchRequest()
        request.entity = entityDescription
        let condition = NSPredicate(format: "content = %@", selectedGiddyContent)
        request.predicate = condition
        
        print("I found what you're looking for: \(request.predicate)")
        
        do {
            try moc.save()
            print("Saved successfully.")
            editTextView.resignFirstResponder()
            self.title = "Updated To-Do"
            //            self.title = allTheToDos.content as String
        } catch {
            showAlertWithTitle("Error", message: "Unable to load to-do.", cancelButtonTitle: "Cancel")
        }
        return true
    }
    //
    
    
    override func viewDidDisappear(animated: Bool) {
        let entityDescription = NSEntityDescription.entityForName("GiddyToDo", inManagedObjectContext: moc)
        let request = NSFetchRequest()
        request.entity = entityDescription
        let condition = NSPredicate(format: "content = %@", selectedGiddyContent)
        request.predicate = condition
        
        print("I found what you're looking for: \(request.predicate)")
        
        do {
            try moc.save()
            print("Saved successfully.")
            editTextView.resignFirstResponder()
            //            self.title = allTheToDos.content as String
        } catch {
            showAlertWithTitle("Error", message: "Unable to load to-do.", cancelButtonTitle: "Cancel")
        }
    }
    //
    
    
    
    @IBAction func onMarkAsDoneTapped(sender: AnyObject) {
        moc.deleteObject(record)
        print("\(record) successfully deleted")
        self.performSegueWithIdentifier("unwindToRoot", sender: self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        print(detailItem)
        let content = editTextView.text
        
        if let isEmpty = content?.isEmpty where isEmpty == false {
            // Update Record
            record.setValue(content, forKey: "content")
            
            do {
                // Save Record
                try record.managedObjectContext?.save()
                
                // Dismiss View Controller
                self.performSegueWithIdentifier("unwindToRoot", sender: self)
                
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
}


