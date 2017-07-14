//
//  ListRecordsTableViewController.swift
//  4114_Test1_Code
//
//  Created by moxDroid on 2017-07-13.
//  Copyright © 2017 moxDroid. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class ListRecordsTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {

    var progress: UIActivityIndicatorView!
    /// Text shown during loading data
    var loadingLabel : UILabel!
    /// View which contains the loading text and the spinner
    var loadingView : UIView!
    var usersList: [NSManagedObject] = []
    var appDelegate : AppDelegate!
    var currentUserSelected: User!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .singleLine
        //Add Fetch Button
        
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Fetch", style: UIBarButtonItemStyle.done, target: self, action: #selector(ListRecordsTableViewController.fetchRestService))
        self.title = "User Data List"
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        getDataFromDb()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usersList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

        // Configure the cell...
        let u = usersList[indexPath.row] as! User
        cell.textLabel?.text = u.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentUserSelected = usersList[indexPath.row] as! User
        let alert = UIAlertController(title: "Lucky User", message: "Please Choose", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: currentUserSelected.username, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: currentUserSelected.name, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: currentUserSelected.gender, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: currentUserSelected.dob, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: currentUserSelected.address, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: currentUserSelected.email, style: .default, handler: { (action) in
            print("EMAIL")
            self.sendEmail(email: self.currentUserSelected.email!)
        }))
        
        //Send SMS - Mobile Phone
        alert.addAction(UIAlertAction(title: currentUserSelected.cell, style: .default, handler: { (action) in
            print("SMS")
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = "Hello from iOS Programming"
                controller.recipients = [self.currentUserSelected.cell!]
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }))
        //Make phone call - Landline
        alert.addAction(UIAlertAction(title: currentUserSelected.phone, style: .default, handler: { (action) in
            print("CALL")
            if let phoneCallURL:URL = URL(string: "tel:\(String(describing: self.currentUserSelected.phone!))")
            {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    let alertController = UIAlertController(title: "Lambton", message: "Are you sure you want to call \n\(String(describing: self.currentUserSelected.phone!))?", preferredStyle: .alert)
                    let yesPressed = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        application.open(phoneCallURL)
                    })
                    let noPressed = UIAlertAction(title: "No", style: .default, handler: { (action) in
                        
                    })
                    alertController.addAction(yesPressed)
                    alertController.addAction(noPressed)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }))
        
        self.present(alert, animated: true)
    }
    
    func fetchRestService() {
        //REST CALL 
        let url = "https://api.randomuser.me/"
        self.setLoadingScreen()
        fetchUserData(myUrl: url)
        
        //self.dismiss(animated: true, completion: nil)
    }
    
    func fetchUserData(myUrl: String) {
        //self.progress.isHidden = false
        //self.progress.startAnimating()
        
        let session   = URLSession.shared
        let request   = NSURLRequest(url: NSURL(string: myUrl)! as URL)
        let task      = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            NSLog("Success")
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: \(data!)")
                return
            }
            
            let results =  parsedResult["results"] as! [AnyObject]
            let record = results[0] as! [String:AnyObject]
            self.save(jsonData: record)
            
            //self.progress.stopAnimating()
            //self.progress.isHidden = true
            //self.downloadImage(urlString: imageUrl)
            
        }
        task.resume()

    }
     func save(jsonData: [String:AnyObject]) {
        
        do{
            //Access JSON Data
            let username = jsonData["login"]?["username"] as! String
            let password = jsonData["login"]?["password"] as! String
            
            let title = jsonData["name"]?["title"] as! String
            let first = jsonData["name"]?["first"] as! String
            let last = jsonData["name"]?["last"] as! String
            let name = title + " " + first + " " + last
            
            let dob = jsonData["dob"] as! String
            let gender = jsonData["gender"] as! String
            let cell = jsonData["cell"] as! String
            let phone = jsonData["phone"] as! String
            let email = jsonData["email"] as! String
            
            let street = jsonData["location"]?["street"] as! String
            let city = jsonData["location"]?["city"] as! String
            let state = jsonData["location"]?["state"] as! String
            let postcode = jsonData["location"]?["postcode"] as! NSNumber
            var address = street + "," + city
                address += "," + state + "," + postcode.stringValue

            let imageUrl = jsonData["picture"]?["medium"] as! String;
            
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            let entity =
                NSEntityDescription.entity(forEntityName: "User",
                                           in: managedContext)!
            
            let user = NSManagedObject(entity: entity,
                                        insertInto: managedContext)
            
           
            user.setValue(username, forKeyPath: "username")
            user.setValue(password, forKeyPath: "password")
            user.setValue(name, forKeyPath: "name")
            user.setValue(dob, forKeyPath: "dob")
            user.setValue(gender, forKeyPath: "gender")
            user.setValue(email, forKeyPath: "email")
            user.setValue(cell, forKeyPath: "cell")
            user.setValue(phone, forKeyPath: "phone")
            user.setValue(address, forKeyPath: "address")
            user.setValue(imageUrl, forKeyPath: "photo")
            
            
            do {
                try managedContext.save()
                usersList.append(user)
                self.tableView.reloadData()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            }
        self.removeLoadingScreen()
    }
    
    func getDataFromDb()
    {
        let managedContext =
            appDelegate.persistentContainer.viewContext
    
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "User")
        
        do {
           usersList  = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        
        // Sets the view which contains the loading text and the spinner
        progress = UIActivityIndicatorView()
        loadingLabel = UILabel()
        loadingView = UIView()
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (self.tableView.frame.width / 2) - (width / 2)
        let y = (self.tableView.frame.height / 2) - (height / 2) - (self.navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        // Sets loading text
        self.loadingLabel.textColor = UIColor.gray
        self.loadingLabel.textAlignment = NSTextAlignment.center
        self.loadingLabel.text = "Loading..."
        self.loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        // Sets spinner
        self.progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.progress.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.progress.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(self.progress)
        loadingView.addSubview(self.loadingLabel)
        
        self.tableView.addSubview(loadingView)
        
    }
    
    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        
        // Hides and stops the text and the spinner
        self.progress.stopAnimating()
        self.loadingLabel.isHidden = true
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func sendEmail(email: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setMessageBody("<p>Write Your body content here</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
