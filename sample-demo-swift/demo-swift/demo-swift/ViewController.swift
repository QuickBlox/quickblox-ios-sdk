//
//  ViewController.swift
//  demo-swift
//
//  Created by Igor Khomenko on 6/11/14.
//  Copyright (c) 2014 Igor Khomenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet var topLabel: UILabel!
    @IBOutlet var topSublabel: UILabel!
    //
    @IBOutlet var logo: UIImageView!
    //
    @IBOutlet var questionsTableView: UITableView!
    //
    @IBOutlet var submitButton: UIButton!
    
    let questionAnswers = ["To integrate it to my app", "To integrate it to my client's app",
        "To use it for my personal purposes"]
    let lastSectionLabel = "How are you planning to use QuickBlox with Swift?"
    let source = "Swift demo"
    let topLabelText = "QuickBlox and Swift"
    let tobSublabelText = "Feedback form"
    
    var selectedAnswer = 0
                            
    override func viewDidLoad() {
        super.viewDidLoad()

        // set logo (by some reason it doesn't show a logo from Images.xcassets on device)
        let image = UIImage(named: "qmlogo2.png");
        logo.image = image
        
        self.navigationItem.title = "QuickBlox"
        
        
        // set top labels
        topLabel.text = topLabelText
        topSublabel.text = tobSublabelText

        // handle keyboard on iPhone
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone{
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow", name: UIKeyboardWillShowNotification, object: nil)
            //
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
        }
        
        // Login QuickBlox user
        //
        
        QBRequest.logInWithUserLogin("JohnDoe", password: "Hello123", successBlock: { (response: QBResponse!, user: QBUUser!) -> Void in
                self.submitButton.enabled = true
            }) { (response: QBResponse!) -> Void in
                NSLog("error: %@", response.error);
        }
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        
        // clear textfields by shake event
        if motion == UIEventSubtype.MotionShake{
            var firstNameTextField = questionsTableView.viewWithTag(100201) as! UITextField
            let lastNameTextField = questionsTableView.viewWithTag(100202) as! UITextField
            let companyTextField = questionsTableView.viewWithTag(100203) as! UITextField
            let phoneTextField = questionsTableView.viewWithTag(100204) as! UITextField
            let emailTextField = questionsTableView.viewWithTag(100205) as! UITextField
            //
            firstNameTextField.text = ""
            lastNameTextField.text = ""
            companyTextField.text = ""
            phoneTextField.text = ""
            emailTextField.text = ""
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        questionsTableView.flashScrollIndicators()
    }
    
    @IBAction func submitButtonTapped(AnyObject) {
        let object = QBCOCustomObject()
        object.className = "BetaTesters"
        //
        var firstNameTextField = questionsTableView.viewWithTag(100201) as! UITextField
        let lastNameTextField = questionsTableView.viewWithTag(100202) as! UITextField
        let companyTextField = questionsTableView.viewWithTag(100203) as! UITextField
        let phoneTextField = questionsTableView.viewWithTag(100204) as! UITextField
        let emailTextField = questionsTableView.viewWithTag(100205) as! UITextField
        
        var params = ["first_name": firstNameTextField.text,
                      "last_name": lastNameTextField.text,
                      "company": companyTextField.text,
                      "email_address": emailTextField.text,
                      "phone_number": phoneTextField.text,
                      "reason": questionAnswers[selectedAnswer],
                      "source": source] as NSMutableDictionary
        
        object.fields = params
        //
        QBRequest.createObject(object, successBlock: {
            (response: QBResponse!, object: QBCOCustomObject!) -> Void in
                NSLog("object: %@", object);
            
                let alert = UIAlertView()
                alert.title = "Thanks!"
                alert.message = "Your data was submited successfully"
                alert.addButtonWithTitle("Ok")
                alert.show()
            
            }, errorBlock: { (response: QBResponse!) -> Void in
                NSLog("error: %@", response.error);
            });
    }
    
    
    // UITextFieldDelegate
    //
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    
    // keyboard
    //
    func keyboardWillShow(){
        UIView.animateWithDuration(0.3, animations: {
            self.questionsTableView.transform = CGAffineTransformMakeTranslation(0, -145)
        })
    }
    
    func keyboardWillHide(){
        UIView.animateWithDuration(0.3, animations: {
            self.questionsTableView.transform = CGAffineTransformIdentity
        })
    }
    
    
    // UITableViewDelegate
    //
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        if indexPath.section == 2{
            // check
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            selectedAnswer = indexPath.row
            
            tableView.reloadData()
        }
    }
    
    
    // UITableViewDataSource
    //
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return section == 0 ? 2 : 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell: UITableViewCell
        

        if indexPath.section == 0{
            if indexPath.row == 0{
                cell = tableView.dequeueReusableCellWithIdentifier("FirstNameCellIdentifier") as! UITableViewCell
            }else{
                cell = tableView.dequeueReusableCellWithIdentifier("LastNameCellIdentifier") as! UITableViewCell
            }
        }else if indexPath.section == 1{
            if indexPath.row == 0{
                cell = tableView.dequeueReusableCellWithIdentifier("CompanyCellIdentifier") as! UITableViewCell
            }else if indexPath.row == 1{
                cell = tableView.dequeueReusableCellWithIdentifier("PhoneCellIdentifier") as! UITableViewCell
            }else {
                cell = tableView.dequeueReusableCellWithIdentifier("EmailCellIdentifier") as! UITableViewCell
            }
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("AnswerCellIdentifier") as! UITableViewCell
            
            let cellLabel = cell.viewWithTag(100200) as! UILabel
            cellLabel.text = questionAnswers[indexPath.row]
            
            if selectedAnswer == indexPath.row{
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }else{
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 2 ? lastSectionLabel : ""
    }
}

