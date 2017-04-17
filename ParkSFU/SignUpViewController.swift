//
//  SignUpViewController.swift
//  CMPT275
//
//  Created by Christopher Le, Mohammed Shakoory, Aaron Guo on 2016-10-30. UI done by Caitlin Finnigan
//  Copyright © 2016 Christopher Le. All rights reserved.
//
/*
 Version 1: adding register function with FireBaseAPI
 Authors: Christopher Le, Mohammed Shakoory, Aaron Guo. UI done by Caitlin Finnigan
 CMPT 275
 GROUP 7
 TEAM SEMAPHORE
 CODING STANDARD: Camel Case variable names, use coding guide for Cocoa:
 https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html
 */

import Foundation
import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    //FIREBASE; USED TO STORE DATA  
    var ref: FIRDatabaseReference!
    //Input text fields from SignUpViewController
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var emailField: UITextField!
    
    override func viewDidLoad() {
        firstName.autocorrectionType = UITextAutocorrectionType.No
        lastName.autocorrectionType = UITextAutocorrectionType.No
        passwordField.autocorrectionType = UITextAutocorrectionType.No
        emailField.autocorrectionType = UITextAutocorrectionType.No
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
    }
    

    
    /*
     Register Function
     Input: First name, last name, Email and password
     Output: Segue to home tab bar controller
     UI: Connects to the "Create Account" button on the ViewController.swift
     */
    @IBAction func createAccount(sender: AnyObject) {
        
        if self.emailField.text == "" || self.passwordField == ""
        {
            //email and password field are empty
            let alertController = UIAlertController(title: "Oops!", message: "Please enter email and password", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            //credentials are not empty
            //calls Firebase API to create an account and add to database
            FIRAuth.auth()?.createUserWithEmail(self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
                if error == nil{
                    //no error
                    self.ref.child("users").child(user!.uid).setValue(["Email": self.emailField.text!, "Password":self.passwordField.text!, "FirstName":self.firstName.text!, "LastName": self.lastName.text!,  "ParkedCoordLatitude": 0, "ParkedCoordLongitude": 0, "ParkedTime":0, "Points":0])
                    print("Successful creating user account")
                    self.performSegueWithIdentifier("fromRegisterToTab", sender: self)
                    
                }else{
                    //was error
                    //no segue, display popup for error message
                    print("Fail creating user account")
                    let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }
            })
        }
    }
   
}
