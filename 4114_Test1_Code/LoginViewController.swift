//
//  ViewController.swift
//  4114_Test1_Code
//
//  Created by moxDroid on 2017-07-13.
//  Copyright © 2017 moxDroid. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var txtUserName: UITextField!

    @IBOutlet weak var txtPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor.blue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnLoginClick(_ sender: Any) {
        if self.txtUserName.text == "" || self.txtPassword.text == "" {
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an User Id and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            if self.txtUserName.text == "admin" && self.txtPassword.text == "admin" {
                
                self.txtUserName.text = ""
                self.txtPassword.text = ""
            let studentDetailsView =  self.storyboard?.instantiateViewController(withIdentifier: "recordsTable") as! ListRecordsTableViewController
            self.navigationController?.pushViewController(studentDetailsView, animated: true)
            }
            else{
                let alertController = UIAlertController(title: "Error", message: "Please enter valid User Id and password.", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

}

