import WatchKit
import Foundation
import CoreData
import GiddyKit

class AppleWatchInterfaceController: WKInterfaceController {
    @IBOutlet var tableView: WKInterfaceTable!
    @IBOutlet var watchLabel: WKInterfaceLabel!
    
//    let moc = DataAccess.sharedInstance.managedObjectContext
    
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
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}
