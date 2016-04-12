//
//  TableViewExtension.swift
//  Pods
//
//  Created by Nicholas Naudé on 12/04/2016.
//
//

import Foundation
import UIKit

extension UITableView {
    func indexPathForView (view : UIView) -> NSIndexPath? {
        let location = view.convertPoint(CGPointZero, toView:self)
        return indexPathForRowAtPoint(location)
    }
}