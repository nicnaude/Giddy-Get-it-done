//
//  RootTableVC.swift
//  Giddy
//
//  Created by Nicholas Naudé on 19/03/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import CloudKit

class RootTableVC: UITableViewController {
    
    var toDos = [CKRecord]()
    var refresh:UIRefreshControl!
    var db: CKDatabase!
    var currentRecords:[CKRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: "loadData", forControlEvents: .ValueChanged)
        self.tableView.addSubview(refresh)
        
        loadData()
    }
    
    func loadData() {
        toDos = [CKRecord]()
        
        let publicData = CKContainer.defaultContainer().publicCloudDatabase
        let query = CKQuery (recordType: "toDo", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        publicData.performQuery(query, inZoneWithID: nil) { (results:[CKRecord]?, error:NSError?) -> Void in
            
            self.currentRecords.removeAll()
            self.currentRecords = results!
            
            if let toDos = results {
                self.toDos = toDos
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    self.tableView.reloadData()
                    self.refresh.endRefreshing()
                })
            }
        }
    }
    
    @IBAction func sendToDo(sender: AnyObject) {
        let alert = UIAlertController(title: "Get it done", message: "Add a new todo", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField:UITextField) -> Void in
            textField.placeholder = "Buy milk"
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (action:UIAlertAction) -> Void in
            let textField = alert.textFields?.first
            if textField!.text != "" {
                let newToDo = CKRecord(recordType: "ToDo")
                newToDo["content"] = textField!.text
                
                let publicData = CKContainer.defaultContainer().publicCloudDatabase
                publicData.saveRecord(newToDo, completionHandler: { (record:CKRecord?, error:NSError?) -> Void in
                    
                    if error == nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.beginUpdates()
                            self.toDos.insert(newToDo, atIndex: 0)
                            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
                            self.tableView.endUpdates()
                        })
                    } else {
                        print("Error!")
                    }
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDos.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        if toDos.count == 0 {
            return cell
        }
        
        let toDo = toDos[indexPath.row]
        
        if let toDosContent = toDo["content"] as? String {
            cell.textLabel?.text = toDosContent
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            // handle delete (by removing the data from your array and updating the tableview)
            let selectedToDo = toDos[indexPath.row]
            let deleteMe = selectedToDo.objectForKey("content") as! String
            
            deleteRecord(deleteMe)
            //            let ref = CKReference(record: toDo, action: CKReferenceAction.DeleteSelf)
            print("Delete button tapped")
        }
    }
    
    func deleteRecord(recordName: String) {
        
        var recordToDelete: CKRecord?
        
        for record in currentRecords {
            let item: String = record.objectForKey("content") as! String
            if item == recordName {
                recordToDelete = record
            }
        }
        if recordToDelete == nil {
            return
        }
        db.deleteRecordWithID(recordToDelete!.recordID) { (rID, error:NSError?) -> Void in
            if error != nil {
            return
            }
            NSOperationQueue.mainQueue().addOperationWithBlock({() -> Void in
            self.tableView.reloadData()
            })
        }
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
