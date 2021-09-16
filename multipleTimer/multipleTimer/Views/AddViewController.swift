//
//  AddViewController.swift
//  multipleTimer
//
//  Created by 유준용 on 2021/09/15.
//

import UIKit

class AddViewController: UIViewController {

    let datamanager = DataManager.shared
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButton(_ sender: Any){
        if addTextfiled.text?.count == 0 {
            datamanager.addTimeBox("무제")
        }else{datamanager.addTimeBox(addTextfiled.text!)}
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var addTextfiled: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
