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
    var iCloudStatus = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            iCloudStatus = true
            return true
        }
        else {
            let alertController = UIAlertController(title: "iCloud Unavailable", message:
                "Please sign into iCloud in Settings and restart Giddy", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            print("NOT signed into iCloud")
            iCloudStatus = false
            return false
        }
    }
    
    
    @IBAction func sendToDo(sender: AnyObject) {
        
        if iCloudStatus == true {
            let alert = UIAlertController(title: "Get it done", message: "Add a new todo", preferredStyle: .Alert)
            alert.addTextFieldWithConfigurationHandler { (textField:UITextField) -> Void in
                textField.placeholder = "Buy milk"
            }
            
            alert.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (action:UIAlertAction) -> Void in
                let textField = alert.textFields?.first
                if textField!.text != "" {
                    let newToDo = CKRecord(recordType: "ToDo")
                    var checkedOrNot = Bool()
                    
                    newToDo["content"] = textField!.text
                    
                    let privateData = CKContainer.defaultContainer().privateCloudDatabase
                    privateData.saveRecord(newToDo, completionHandler: { (record:CKRecord?, error:NSError?) -> Void in
                        
                        if error == nil {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.tableView.beginUpdates()
                                self.toDos.insert(newToDo, atIndex: 0)
                                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
                                self.tableView.reloadData()
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
        } else {
            let alertController = UIAlertController(title: "iCloud Unavailable", message:
                "Please sign into iCloud in Settings and restart Giddy", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
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
        
        let selectedToDo = self.toDos[indexPath.row].recordID
        print("selectedToDo: \(selectedToDo)")
        
        let checkedChecker = CKQuery(recordType: "toDo", predicate: NSPredicate(format: "(checkedOrNot == %@)", argumentArray: [selectedToDo]))
        
        if (checkedChecker == false) {
            cell.accessoryType = .None
        } else {
            cell.accessoryType = .Checkmark
        }
        
        print("checkedChecker: \(checkedChecker)")
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = .None
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = .Checkmark
            
        }
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            
            let container = CKContainer.defaultContainer()
            let privateData = container.privateCloudDatabase
            
            let selectedToDo = self.toDos[indexPath.row].recordID
            print("selectedToDo: \(selectedToDo)")
            
            let query = CKQuery(recordType: "toDo", predicate: NSPredicate(format: "(content == %@)", argumentArray: [selectedToDo]))
            print("query: \(query)")
            
            privateData.deleteRecordWithID(selectedToDo) { record, error in
                if error != nil
                {
                    self.loadData()
                    self.tableView.reloadData()
                    //                    print("ERR RECORD ID: \(self.record.recordID)")
                    //                    completion(success: false, message: "could not delete entry", error: error)
                }
                else
                {
                    self.loadData()
                    //                    print("DEL RECORD ID: \(self.record.recordID)")
                    //                    completion(success: true, message: "successfully deleted entry", error: nil)
                }
            }
        }
    }
}