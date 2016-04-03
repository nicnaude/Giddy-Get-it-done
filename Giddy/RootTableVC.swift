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
    var db: CKDatabase!
    let privateDB = CKContainer.defaultContainer().publicCloudDatabase //.privateCloudDatabase
    var iCloudStatus = Bool()
    var newToDo = ToDoItem()
//    var currentToDo: CKRecord
    var toDo = ToDoItem()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.currentToDo = CKRecord(String)
        self.newToDo = ToDoItem()
        self.toDo = ToDoItem()
        
        self.tableView.tableFooterView = UIView()
        
        navigationController?.navigationBar.barTintColor = UIColor(red:0.98, green:0.68, blue:0.09, alpha:1.0)
        
        //UI setup
        db = CKContainer.defaultContainer().publicCloudDatabase //privateCloudDatabase
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        //Refresh control
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: #selector(RootTableVC.loadData), forControlEvents: .ValueChanged)
        self.tableView.addSubview(refresh)
        
        loadData()
        isICloudContainerAvailable()
    }
    
    // START
    //    func loadData() {
    //        let pred = NSPredicate(value: true)
    //        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
    //        let query = CKQuery(recordType: "ToDos", predicate: pred) //Whistles
    //        query.sortDescriptors = [sort]
    //
    //        let operation = CKQueryOperation(query: query)
    //        operation.desiredKeys = ["content", "doneStatus"]
    //        // operation.resultsLimit = 50
    //        var newToDos = [ToDo]()
    //
    //        operation.recordFetchedBlock = { (record) in
    //            //            let toDo = ToDo()
    //            toDo.recordID = record.recordID
    //            //            self.toDo.giddyRecordID = record["giddyRecordID"] as! CKRecordID
    //            self.toDo.content = record["Content"] as! String
    //            self.toDo.doneStatus = record["No"] as! String
    //            newToDos.append(self.toDo)
    //        }
    //
    //        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
    //            dispatch_async(dispatch_get_main_queue()) {
    //                if error == nil {
    //                    self.toDos = newToDos
    //                    self.tableView.reloadData()
    //                } else {
    //                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of whistles; please try again: \(error!.localizedDescription)", preferredStyle: .Alert)
    //                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
    //                    self.presentViewController(ac, animated: true, completion: nil)
    //                }
    //            }
    //        }
    //    }
    // END
    
    // START
    func loadData () {
        var toDoRecords = [CKRecord]()
        
        let publicData = CKContainer.defaultContainer().publicCloudDatabase
        let query = CKQuery(recordType: "Sweet", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        publicData.performQuery(query, inZoneWithID: nil) { (results:[CKRecord]?, error:NSError?) -> Void in
            if let singleToDo = results {
                toDoRecords = singleToDo
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    self.refresh.endRefreshing()
                })
            }
        }
    }
    // END
    
    
    func isICloudContainerAvailable() -> Bool {
        if let currentToken = NSFileManager.defaultManager().ubiquityIdentityToken {
            print(currentToken)
            print("iCloud is signed in")
            iCloudStatus = true
            return true
        }
        else {
            let alertController = UIAlertController(title: "iCloud Unavailable", message:
                "Giddy uses iCloud to save your todos. Please sign into iCloud in the Settings app and restart Giddy.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            print("NOT signed into iCloud")
            iCloudStatus = false
            return false
        }
    }
    
    func howToAddRecordsToDB () {
        let itemRecord:CKRecord = CKRecord(recordType: "ToDo")
        itemRecord.setObject("theObjectSendingTheData", forKey: "The Key")
        db.saveRecord(itemRecord) { (record:CKRecord?, error:NSError?) -> Void in
            if error == nil {
                print("Saved successfully")
                NSOperationQueue.mainQueue().addOperationWithBlock({() -> Void in
                    print("Update the UI here.")
                })
            }
        }
    }
    
    
    @IBAction func saveToDo(sender: AnyObject) {
        
        if iCloudStatus == true {
            
            let alert = UIAlertController(title: "Get it done", message: "Add a new todo", preferredStyle: .Alert)
            
            alert.view.tintColor = UIColor(red:0.98, green:0.68, blue:0.09, alpha:1.0)
            alert.addTextFieldWithConfigurationHandler { (textField:UITextField) -> Void in
                textField.placeholder = "Buy milk"
            }
            
            alert.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (action:UIAlertAction) -> Void in
                let textField = alert.textFields?.first
                if textField!.text != "" {
                    
                    // var recordID = CKRecordID(recordName: userRecordID.recordName)
                    //                    let random = Int(arc4random_uniform(999999))
                    //                    let date = NSDate()
                    //
                    //                    let recordID = CKRecordID(recordName: "\(date)\(random)")
                    //                    let content = textField!.text
                    //                    let doneStatus = "No"
                    
                    //                    self.newToDo.createNewToDo(recordID, content: content!, doneStatus: doneStatus) //content!, doneStatus: doneStatus)
                    //                    var currentToDo = self.newToDo
                    
                    let currentToDo = CKRecord(recordType: "ToDo")
                    currentToDo["content"] = textField!.text
                    currentToDo["doneStatus"] = "No"
                    
                    
                    self.privateDB.saveRecord(currentToDo, completionHandler: { (record:CKRecord?, error:NSError?) -> Void in
                        
                        if error == nil {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.tableView.beginUpdates()
                                self.toDos.insert(currentToDo, atIndex: 0)
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
                "Giddy uses iCloud to save your todos. Please sign into iCloud in the Settings app and restart Giddy.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    // number of cells in tableView
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDos.count
    }
    
    
    // tableView data source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        if toDos.count == 0 {
            return cell
        } else {
            
            let toDo = toDos[indexPath.row]
            
            let selectectedToDoContent = toDo["content"] as? String
            cell.textLabel?.text = selectectedToDoContent
            // if let toDosContent = toDo["content"] as? String {
            // cell.textLabel?.text = toDosContent
            
            if let toDoContent = toDo["content"] as? String {
                let dateFormat = NSDateFormatter()
                dateFormat.dateFormat = "MM/dd/yyyy"
                
                cell.textLabel?.text = toDoContent
            }
            
            let selectedToDoRecordID = self.toDos[indexPath.row]
            
            let selectedToDo = self.toDos[indexPath.row].recordID
            print("selectedToDo: \(selectedToDo)")
            
            // need an if statement here to determine checked.
            let image : UIImage = UIImage(named: "checked")!
            
            cell.imageView!.image = image
            
            return cell
        }
    }
    
    
    // Can edit tableView
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // commit editing style
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            
            let container = CKContainer.defaultContainer()
            let privateData = container.privateCloudDatabase //privateCloudDatabase
            
            let selectedToDo = self.toDos[indexPath.row].recordID
            print("selectedToDo: \(selectedToDo)")
            
            let query = CKQuery(recordType: "toDo", predicate: NSPredicate(format: "(content == %@)", argumentArray: [selectedToDo]))
            print("query: \(query)")
            
            privateData.deleteRecordWithID(selectedToDo) { record, error in
                if error != nil
                {
                    self.loadData()
                    self.tableView.reloadData()
                }
                else
                {
                    self.loadData()
                }
            }
        }
    }
}