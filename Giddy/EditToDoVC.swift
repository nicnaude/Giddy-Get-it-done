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
    @IBOutlet weak var testLabel: UILabel!
    var selectedGiddy = GiddyToDo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testLabel.text = selectedGiddy.content
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        saveButton.layer.cornerRadius = 23
        saveButton.layer.borderWidth = 0
        
        markAsDoneButton.layer.cornerRadius = 23
        markAsDoneButton.layer.borderWidth = 0
    }
    
    @IBAction func onSaveButtonTapped(sender: UIButton) {
        print("Save tapped")
    }
    
    @IBAction func onMarkAsDoneTapped(sender: UIButton) {
        print("Done tapped")
    }
}
