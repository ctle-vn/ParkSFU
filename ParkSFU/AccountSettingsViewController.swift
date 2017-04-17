//
//  AccountSettingsViewController.swift
//  CMPT275
//
//  Created by Christopher Le on 2016-11-06.
//  Copyright © 2016 Christopher Le. All rights reserved.
//
/*
 Version 1: adding logout function with FireBaseAPI
 CMPT 275
 GROUP 7
 TEAM SEMAPHORE
 CODING STANDARD: Camel Case variable names, use coding guide for Cocoa:
 https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html
 */

/*
 Version 2: adding account information fetched from the database
 Author: Christopher Le, Caitlin Finnigan
 CMPT 275
 GROUP 7
 TEAM SEMAPHORE
 CODING STANDARD: Camel Case variable names, use coding guide for Cocoa:
 https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html
 */

import Foundation
import UIKit
import Firebase


class AccountSettingsViewController: UIViewController {
    
    
    @IBOutlet var email: UILabel!
    
    @IBOutlet var firstName: UILabel!
    
    @IBOutlet var lastName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email.text = fetchEmail()
        firstName.text = fetchFirstName()
        lastName.text = fetchLastName()
        self.view.addSubview(email)
        self.view.addSubview(firstName)
        self.view.addSubview(lastName)
        
        //testing purposes, will display on UI later
        fetchFirstName()
        fetchLastName()
        fetchEmail()
        fetchParkedTime()
        fetchParkedLatitude()
        fetchParkedLongitude()
    }
    
    /*
     Logout Function
     UI: Connects to the "Logout" button on the ViewController.swift and segue to ViewController.swift
     */
    @IBAction func userLogout(sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
    }
    
    
    
/*-------------------------------USE THESE FUNCTIONS TO PULL USER INFO FROM DATABASE -----------------------------------*/
    
    //pulls the first name from the database
    func fetchFirstName() -> String {
        let userID = FIRAuth.auth()?.currentUser?.uid
        var ref : FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        var firstName = ""
        
        ref.child("users").child((userID!)).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // check if ParkedTime exists
            if snapshot.hasChild("FirstName"){
                firstName = (snapshot.value!["FirstName"] as! String)
                print("firstName does exist \(firstName)")
                
                
            }else{
                
                print("firstName has not yet been assigned")
            }
            
            
        })
        return firstName
    }
    
    //pulls the last name from the database
    func fetchLastName() -> String {
        let userID = FIRAuth.auth()?.currentUser?.uid
        var ref : FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        var lastName = ""
        
        ref.child("users").child((userID!)).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // check if ParkedTime exists
            if snapshot.hasChild("LastName"){
                lastName = (snapshot.value!["LastName"] as! String)
                print("LastName does exist \(lastName)")
                
                
            }else{
                
                print("LastName has not yet been assigned")
            }
            
            
        })
        return lastName
    }
    
    //pulls the park time from the database
    func fetchParkedTime() -> Double {
        let userID = FIRAuth.auth()?.currentUser?.uid
        var ref : FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        var parkTime = 0.0
        
        ref.child("users").child((userID!)).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // check if ParkedTime exists
            if snapshot.hasChild("ParkedTime"){
                parkTime = (snapshot.value!["ParkedTime"] as! Double)
                print("parkTime does exist \(parkTime)")
                
                
            }else{
                
                print("parkTime has not yet been assigned")
            }
            
            
        })
        return parkTime
    }

    //pulls the email from the database
    func fetchEmail() -> String {
        let userID = FIRAuth.auth()?.currentUser?.uid
        var ref : FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        var email = ""
        
        ref.child("users").child((userID!)).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // check if ParkedTime exists
            if snapshot.hasChild("Email"){
                email = (snapshot.value!["Email"] as! String)
                print("Email does exist \(email)")
                
                
            }else{
                
                print("Email has not yet been assigned")
            }
            
            
        })
        return email
    }
    
    //pulls the parked spot latitude from the database
    func fetchParkedLatitude() -> Double {
        let userID = FIRAuth.auth()?.currentUser?.uid
        var ref : FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        var parkLatitude = 0.0
        
        ref.child("users").child((userID!)).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // check if ParkedCoordLatitude exists
            if snapshot.hasChild("ParkedCoordLatitude"){
                parkLatitude = (snapshot.value!["ParkedCoordLatitude"] as! Double)
                print("ParkedCoordLatitude does exist \(parkLatitude)")
                
                
            }else{
                
                print("ParkedCoordLatitude has not yet been assigned")
            }
            
            
        })
        return parkLatitude
    }
    
    //pulls the parked spot longitude from the database
    func fetchParkedLongitude() -> Double {
        let userID = FIRAuth.auth()?.currentUser?.uid
        var ref : FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        var parkLongitude = 0.0
        
        ref.child("users").child((userID!)).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // check if ParkedCoordLatitude exists
            if snapshot.hasChild("ParkedCoordLongitude"){
                parkLongitude = (snapshot.value!["ParkedCoordLongitude"] as! Double)
                print("ParkedCoordLongitude does exist \(parkLongitude)")
                
                
            }else{
                
                print("ParkedCoordLongitude has not yet been assigned")
            }
            
            
        })
        return parkLongitude
    }
}
