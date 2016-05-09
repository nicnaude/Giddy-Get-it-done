import WatchKit
import Foundation
import CoreData
import GiddyKit
import WatchConnectivity

class AppleWatchInterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet var tableView: WKInterfaceTable!
    @IBOutlet var watchLabel: WKInterfaceLabel!
    
    var watchSession : WCSession?
    
    //    let moc = DataAccess.sharedInstance.managedObjectContext
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if(WCSession.isSupported()){
            watchSession = WCSession.defaultSession()
            // Add self as a delegate of the session so we can handle messages
            watchSession!.delegate = self
            watchSession!.activateSession()
        }
    }
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        let date: NSDate? = DataAccess.sharedInstance.getAppleWatchToDos()
        
        if date != nil {
            watchLabel.setText(date!.description)
        }
        watchLabel.setText("Hello")
        //        print(moc)
    }
    //
    
    func applicationWillResignActive() {
        DataAccess.sharedInstance.saveContext()
    }
    
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}
