//
//  item2ViewController.swift
//  CMPT275
//
//  Created and written by Greyson Wang on 11/3/16. All revision added on 11/3/16
//  Copyright © 2016 Christopher Le. All rights reserved.
//  Implements all the mapping functionality on the item2 page
//  This page shows the user the location of a potentially available spot (real data will be retrieved from database later)

/*
 Version 2: adding account information fetched from the database, determining if user is leaving parking lot and their parking spot
 Author: Christopher Le, Greyson Wang
 CMPT 275
 GROUP 7
 TEAM SEMAPHORE
 CODING STANDARD: Camel Case variable names, use coding guide for Cocoa:
 https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html
 */

import GoogleMaps
import UIKit
import Firebase



class item2ViewController: UIViewController {
    

    let locationManager = CLLocationManager()
    var parkedCoordLong = 0.0
    var parkedCoordLat = 0.0
    

    
    @IBOutlet var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //firebase
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        
        
        let camera = GMSCameraPosition.cameraWithLatitude(49.276915, longitude: -122.911991, zoom: 18.0)
        var time: Double

        //time = getParkedTime()
        mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
        //mapView.myLocationEnabled = true
        view = mapView
        
    
        //retrieves long/lat coordinates from db
 
        // Creates a marker in the center of the map.
      
      
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Parked Location", style: .Plain, target: self, action: "parkLocation")
        
        if CLLocationManager.locationServicesEnabled()
            && CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways {
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
            self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            
        }
        
        
        
        
    }
    // Display action sheet that allows the user to switch maps when clicking on the switch map button
    @IBAction func changeMapType(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Map Types", message: "Select map type:", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let normalMapTypeAction = UIAlertAction(title: "Normal", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.mapView.mapType = kGMSTypeNormal
        }
        
        let terrainMapTypeAction = UIAlertAction(title: "Terrain", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.mapView.mapType = kGMSTypeTerrain
        }
        
        let hybridMapTypeAction = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.mapView.mapType = kGMSTypeHybrid
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        actionSheet.addAction(normalMapTypeAction)
        actionSheet.addAction(terrainMapTypeAction)
        actionSheet.addAction(hybridMapTypeAction)
        actionSheet.addAction(cancelAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)

    }
    
    
    // stub function, to be retrieved from db later
    func getParkedTime() -> Double {
        var ref : FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        let userID = (FIRAuth.auth()?.currentUser?.uid)
        var parkTime = 0.0
        //read parkedTime from database
        //must do it like this, for some reason xcode wont autocorrect format lmao ay
        //retrieves long/lat coordinates from db
        ref.child("users").child((userID)!).observeSingleEventOfType(.Value, withBlock: { snapshot in
            // check if ParkedTime exists
            if snapshot.hasChild("ParkedTime"){
                parkTime = snapshot.value!["ParkedTime"] as! Double
                print("ParkedTime does exist \(parkTime)")
                
            }else{
                
                print("ParkedTime does not exist")
            }
        })
        
        
        return parkTime
    }
    
    // Action for clicking on the parked location button, map will display the coordinates of the
    // user's parked location
    func parkLocation() {
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        var ref : FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        
        ref.child("users").child((userID!)).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // check if ParkedCoordLongitude exists
            if snapshot.hasChild("ParkedCoordLongitude"){
                self.parkedCoordLong = snapshot.value!["ParkedCoordLongitude"] as! Double
                print("ParkedCoordLongitude does exist \(self.parkedCoordLong)")
                
            }else{
                
                print("ParkedCoordLongitude has not yet been assigned")
            }
            
        })
        
        //retrieves long/lat coordinates from db
        ref.child("users").child((userID!)).observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            // check if ParkedCoordLatitude exists
            if snapshot.hasChild("ParkedCoordLatitude"){
                self.parkedCoordLat = snapshot.value!["ParkedCoordLatitude"] as! Double
                print("ParkedCoordLatitude does exist \(self.parkedCoordLat)")
                
            }else{
                
                print("ParkedCoordLatitude has not yet been assigned")
            }
            
        })
        
        if (self.parkedCoordLat != 0.0 && self.parkedCoordLong != 0.0)
        {
            print("\nprint: entered here")
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: self.parkedCoordLat, longitude: self.parkedCoordLong)
            marker.title = "You parked here"
            //marker.snippet = "at \(time)"
            marker.map = mapView
        }
        
          print("print: \(self.parkedCoordLat) \(self.parkedCoordLong)")
        if (parkedCoordLat != 0.0 && parkedCoordLong != 0.0) {
            
            let myLoc = CLLocationCoordinate2D(latitude: parkedCoordLat, longitude: parkedCoordLong) // these values will be retrieved from database later
            
            // Scroll view to parked location, and set this scrolling duration to 2 seconds
            CATransaction.begin()
            mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(myLoc.latitude, longitude: myLoc.longitude, zoom: 18.0))
            CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
            CATransaction.commit()
        }
        else {
            // location data not available on device
            let alertController4 = UIAlertController(
                title: "Uh oh!",
                message: "We have not detected that you already parked!",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "ok", style: .Cancel, handler: nil)
            alertController4.addAction(cancelAction)
            self.presentViewController(alertController4, animated: true, completion: nil)
            
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - CLLocationManagerDelegate


    
