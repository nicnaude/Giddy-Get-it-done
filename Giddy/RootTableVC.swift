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
    var currentRecords:[CKRecord] = []
    let privateData = CKContainer.defaultContainer().privateCloudDatabase
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TO DO: Add check to see if user is logged in to iCloud.
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: "loadData", forControlEvents: .ValueChanged)
        self.tableView.addSubview(refresh)
        
        loadData()
        isICloudContainerAvailable()
    }
    
    
    func loadData() {
        toDos = [CKRecord]()
        
        let query = CKQuery (recordType: "toDo", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        privateData.performQuery(query, inZoneWithID: nil) { (results:[CKRecord]?, error:NSError?) -> Void in
            
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
    
    
    func isICloudContainerAvailable() -> Bool {
        if let currentToken = NSFileManager.defaultManager().ubiquityIdentityToken {
            print(currentToken)
            print("iCloud is signed in")
            return true
        }
        else {
            let alertController = UIAlertController(title: "iOScreator", message:
                "Hello, world!", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            print("NOT signed into iCloud")
            return false
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
                
                let privateData = CKContainer.defaultContainer().privateCloudDatabase
                privateData.saveRecord(newToDo, completionHandler: { (record:CKRecord?, error:NSError?) -> Void in
                    
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
            
            
            let container = CKContainer.defaultContainer()
            let privateData = container.privateCloudDatabase
            
            //            let query = CKQuery(recordType: "toDo", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: [selectedToDo.recordID.recordName]))
            
            
            let selectedToDo = self.toDos[indexPath.row].recordID
            print("selectedToDo: \(selectedToDo)")
            
            let query = CKQuery(recordType: "toDo", predicate: NSPredicate(format: "(content == %@)", argumentArray: [selectedToDo.recordName]))
            print("query: \(query)")
            
            privateData.performQuery(query, inZoneWithID: nil, completionHandler: { results, error in
                
                if error == nil {
                    if results!.count > 0 {
                        let record: CKRecord! = results![0]
                        print(record)
                        
                        privateData.deleteRecordWithID(record.recordID, completionHandler: { recordID, error in
                            if error != nil {
                                print(error)
                            }
                        })
                    }
                }
                else {
                    print("Fuck! ERROR")
                }
            })
            loadData()
            print("Delete button tapped")
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
