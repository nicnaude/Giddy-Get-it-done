//
//  EditToDoVC.swift
//  Giddy
//
//  Created by Nicholas Naudé on 04/04/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit

class EditToDoVC: UIViewController {
    
    
    @IBOutlet weak var editTextField: UITextField!
    @IBOutlet weak var markAsDoneButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSaveButtonTapped(sender: UIButton) {
        print("Save tapped")
    }
    
    @IBAction func onMarkAsDoneTapped(sender: UIButton) {
        print("Done tapped")
    }
}
