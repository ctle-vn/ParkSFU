//
//  ViewController.swift
//  CMPT275
//
//  Created by Christopher Le, Mohammed Shakoory, Aaron Guo on 2016-10-30. UI done by Caitlin Finnigan
//  Copyright © 2016 Christopher Le. All rights reserved.
//
/*
 Version 1: adding login function with FireBaseAPI
 Authors: Christopher Le, Mohammed Shakoory, Aaron Guo. UI done by Caitlin Finnigan
 */
/*
 CMPT 275
 GROUP 7
 TEAM SEMAPHORE
 CODING STANDARD: Camel Case variable names, use coding guide for Cocoa:
 https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html
 */

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController{

    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        emailField.autocorrectionType = UITextAutocorrectionType.No
        passwordField.autocorrectionType = UITextAutocorrectionType.No
        super.viewDidLoad()
        
    }
    

    
    
  

    

    /*
    Login Function
    Input: Email and password
    Output: Segue to home tab bar controller
    UI: Connects to the "Login" button on the ViewController.swift
    */
    @IBAction func didTapSignIn(sender: AnyObject) {
        
        //checks if email/password field are empty
        if self.emailField.text == "" || self.passwordField == ""
        {
            //if empty, display pop up with message
            let alertController = UIAlertController(title: "Oops!", message: "Please enter email and password", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            //not empty
            //call Firebase api to login with credentials
            FIRAuth.auth()?.signInWithEmail(self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
                if error == nil{
                    print("login pass")
                    //no error
                    self.emailField.text = ""
                    self.passwordField.text = ""
                    //segue to the home tab bar controller
                    self.performSegueWithIdentifier("fromLoginToTab", sender: self)
                    
                }else{
                    //was error
                    //no segue occurs, display pop up with error message to user
                    print("login fail")
                    let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }
            })
        }

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    


}


