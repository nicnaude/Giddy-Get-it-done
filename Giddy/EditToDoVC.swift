//
//  EditToDoVC.swift
//  Giddy
//
//  Created by Nicholas Naudé on 04/04/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit

class EditToDoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSaveButtonTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
}
