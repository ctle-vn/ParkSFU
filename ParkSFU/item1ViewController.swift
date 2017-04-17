//
//  item1ViewController.swift
//  CMPT275
//
//  Created and written by Christopher Le and Greyson Wang on 11/3/16. All revision done on 11/3/16
//  Copyright © 2016 Christopher Le. All rights reserved.
//  Implements all the mapping functionality on the item1 page
//  This page shows the user where they parked their car and can display the user's current location
/*
 item1ViewController:
 Nov 3 - Added google maps, and a button to display where the user parked
 Nov 4 - Added popup to request user to give permission for the app to track their location
 Nov 5 - Added the current location button, popup to warn user that the app has been denied permission to track user location and the button to switch maps
*/


/*
 Version 2: adding account information fetched from the database, determining the parking spot
 will detect if user is inside of the parking lot via geofencing
 implementation of motion detection (determining if user is stationary or not)
 Author: Christopher Le, Greyson Wang
 CMPT 275
 GROUP 7
 TEAM SEMAPHORE
 CODING STANDARD: Camel Case variable names, use coding guide for Cocoa:
 https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html
 */

/*Version 3:
1.Error: This app has crashed because it attempted to access privacy-sensitive data without a usage description.  The app's Info.plist must contain an NSMotionUsageDescription key with a string value explaining to the user how the app uses this data
1. FIXED by changing info plist

2. Error: not detecting car parked, alwyas prints false


*/

import GoogleMaps
import UIKit
import CoreLocation
import CoreMotion
import Foundation
import Firebase




class item1ViewController: UIViewController,CLLocationManagerDelegate {

    //FIREBASE; USED TO STORE DATA
    var ref: FIRDatabaseReference!
    let userID = FIRAuth.auth()?.currentUser?.uid

// initialize maps and locationManager

    @IBOutlet var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    let activityManager = CMMotionActivityManager()
    var parkingLot: CLCircularRegion!
    var userIsParked = false
    var userMayBeLeaving = false
    var parkedCoordinate:CLLocationCoordinate2D!

    //var parkedTime: NSDate!

    //(y,x)
    let stallTopLeft = (49.276630, -122.912885)
    let stallTopRight = (49.276194, -122.910062)
    let stallBottomLeft = (49.276548, -122.912909)
    let stallBottomRight = (49.276115, -122.910083)

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()



        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the coordinates at zoom 18

        let camera = GMSCameraPosition.cameraWithLatitude(49.276915, longitude: -122.911991, zoom: 18.0)
        var time: Int
        let userID = FIRAuth.auth()?.currentUser?.uid
        var ref : FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        var parkLatitude = 0.0
        var parkLongitude = 0.0
        ref.child("users").child((userID!)).observeSingleEventOfType(.Value, withBlock: { snapshot in

            // check if ParkedCoordLatitude exists
            if snapshot.hasChild("ParkedCoordLatitude"){
                parkLatitude = (snapshot.value!["ParkedCoordLatitude"] as! Double)
                print("ParkedCoordLatitude does exist \(parkLatitude)")


            }else{
                parkLatitude = 49.276915
                print("ParkedCoordLatitude has not yet been assigned")
            }


        })
        ref.child("users").child((userID!)).observeSingleEventOfType(.Value, withBlock: { snapshot in

            // check if ParkedCoordLatitude exists
            if snapshot.hasChild("ParkedCoordLongitude"){
                parkLongitude = (snapshot.value!["ParkedCoordLongitude"] as! Double)
                print("ParkedCoordLongitude does exist \(parkLongitude)")


            }else{
                parkLongitude = -122.911991
                print("ParkedCoordLongitude has not yet been assigned")
            }


        })

        mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
        //mapView.myLocationEnabled = true

        view = mapView

        /*--------- RETRIEVE AVAILABLE SPOTS FROM DB -----------*/
        // Creates a marker in the center of the map for the user's parked location
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: parkLatitude, longitude: parkLongitude)
        marker.title = "Parked Location"
        marker.snippet = "vacated 2 hours ago"
        marker.map = mapView

        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Parked Location", style: .Plain, target: self, action: "parkLocation")

        if CLLocationManager.locationServicesEnabled()
            && CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways {
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
            self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            locationManager.startUpdatingLocation()

        }

        monitorRegion()

    } //end of loadView
    // Display action sheet that allows the user to switch maps when clicking on the switch map button

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined:
            manager.requestAlwaysAuthorization()
        case .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to display directions, please open settings andenable location access.",
                preferredStyle: .Alert)

            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)

            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)

            self.presentViewController(alertController, animated: true, completion: nil)
        default:
            break
        }
        // if user gives permission to access their location, display the my location button that shows the user's location on the map
        if status == .AuthorizedAlways {
            // start tracking user location, and display a "my location" button that centers map on user location and draws a blue dot
            //locationManager.startUpdatingLocation()

            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
            self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)


            }
    }




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



    // Mark: Geofencing
    // setup region for monitoring
    func monitorRegion()  {
        print("print monitor region")
        if CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion.self) {

        let center = CLLocationCoordinate2D(latitude: 49.276869, longitude: -122.911236)
        let radius: CLLocationDistance = 135.0
        let identifier: String = "Parking Lot"
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        locationManager.startMonitoringForRegion(region)

        //draw circule
        let circ = GMSCircle(position: center, radius: 140)
        circ.map = mapView
        }
        else {
            let alertController2 = UIAlertController(
                title: "Error",
                message: "Geofencing not supported on this device!!!",
                preferredStyle: .Alert)

            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController2.addAction(cancelAction)
            self.presentViewController(alertController2, animated: true, completion: nil)
        }

    }

    // 1. user enters parking lot
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("print location managaer")
        let didEnter = UIAlertController(
            title: "You entered the parking lot",
            message: "so yeah",
            preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: "ok", style: .Cancel, handler: nil)
        didEnter.addAction(cancelAction)
        self.presentViewController(didEnter, animated: true, completion: nil)

        if (CMMotionActivityManager.isActivityAvailable()) {
            print("print INSIDE")


            self.activityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue()) { data in
                if let data = data {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {

                        if (self.userIsParked == false)
                        {
                            // Track user movement and determine where and when they parked
                            //var parkedTime = NSDate()

                            if(data.stationary == true){
                                self.parkedCoordinate = (manager.location?.coordinate)!  // get user coordinate to check if it is in stall
                                if (self.userInStall(self.parkedCoordinate.longitude, userYCoord: self.parkedCoordinate.latitude)) {
                                    // store this value to db
                                    self.userIsParked = true
                                    var parkedTime = self.getTime()


                                    //stores parked time, and longitude and latitude coordinates in database
                                    self.ref.child("users/\(self.userID!)").updateChildValues(["ParkedTime":parkedTime])
                                    self.ref.child("users/\(self.userID!)/ParkedCoordLongitude").updateChildValues(["ParkedCoordLongitude":self.parkedCoordinate.longitude])
                                    self.ref.child("users/\(self.userID!)").updateChildValues(["ParkedCoordLatitude":self.parkedCoordinate.latitude])
                                    /*
                                    //temp
                                    let testingValues = UIAlertController(
                                        title: "Users parking information",
                                        message: "ParkedTime: \(21) ParkedCoordLongitude: \(self.parkedCoordinate.longitude) ParkedCoordLatitude: \(self.parkedCoordinate.latitude)",
                                        preferredStyle: .Alert)
                                    */
                                    let testingValues = UIAlertController(
                                        title: "Users parking information",
                                        message: "ParkedTime: \(parkedTime) ParkedCoordLongitude: \(self.parkedCoordinate.longitude) ParkedCoordLatitude: \(self.parkedCoordinate.latitude)",
                                        preferredStyle: .Alert)

                                let cancelAction = UIAlertAction(title: "ok", style: .Cancel, handler: nil)
                                    testingValues.addAction(cancelAction)
                                    self.presentViewController(testingValues, animated: true, completion: nil)
                                } // end if userInStall

                            } // end if data.stationary
                        } // end if userIsParked
                        else {
                            // user is parked but re-enters parking lot
                            self.userMayBeLeaving = true
                        } // end else

                    } // end dispatch_async
                } // end if let data = data
            } // end activity manager closure


        }
        else {
            // delete later
            print("print OUTSIDE")
            self.parkedCoordinate = (manager.location?.coordinate)!
            if (self.userInStall(self.parkedCoordinate.longitude, userYCoord: self.parkedCoordinate.latitude)) {
                print("print: user is in stall")
                // store this value to db
                self.userIsParked = true
                var parkedTime = self.getTime()
                self.parkedCoordinate = (manager.location?.coordinate)!  // store parkedCoordinate to dataBase - may need to decompose this to longitude and latitude (both are double typeAlias - aka typedef in C

                //stores parked time, and longitude and latitude coordinates in database
                self.ref.child("users/\(self.userID!)/ParkedTime").setValue(parkedTime)
                self.ref.child("users/\(self.userID!)/ParkedCoordLongitude").setValue(self.parkedCoordinate.longitude)
                self.ref.child("users/\(self.userID!)/ParkedCoordLatitude").setValue(self.parkedCoordinate.latitude)
                let testingValues = UIAlertController(
                    title: "Users parking information",
                    message: "ParkedCoordLongitude: \(self.parkedCoordinate.longitude) ParkedCoordLatitude: \(self.parkedCoordinate.latitude)",
                    preferredStyle: .Alert)

                let cancelAction = UIAlertAction(title: "ok", style: .Cancel, handler: nil)
                testingValues.addAction(cancelAction)
                self.presentViewController(testingValues, animated: true, completion: nil)
            } // end if userInStall
            // delete later
            /*
            // location data not available on device
            let alertController3 = UIAlertController(
                title: "Error",
                message: "Motion data is not available on your device",
                preferredStyle: .Alert)

            let cancelAction = UIAlertAction(title: "ok", style: .Cancel, handler: nil)
            alertController3.addAction(cancelAction)
            self.presentViewController(alertController3, animated: true, completion: nil)
 */
        }

    }

    // 2. user exit region
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("print: user left ")


        if (CMMotionActivityManager.isActivityAvailable()) {
            // stop the previous cmmotion handler and start the new one
            activityManager.stopActivityUpdates()

            self.activityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue()) { data in
                if let data = data {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {

                        if (self.userMayBeLeaving == true)
                        {
                            if(data.automotive == true){
                                // user has left their spot, remove the stored parked location in the database

                                /*------TAKE USERS SPOT AND PLACE INTO POTENTIALLY AVAILABLE SPOT*/
                                // store that value under potentially available spots


                                /*----M&A start*/
                                var date = self.getTime()
                                self.ref.child("AvailableSpot/\(date)/ParkedCoordLatitude").setValue(self.fetchParkedLatitude());
                                self.ref.child("AvailableSpot/\(date)/ParkedCoordLongitude").setValue(self.fetchParkedLongitude());
                                /*----M&A end*/

                                self.userIsParked = false
                                self.userMayBeLeaving = false
                                self.activityManager.stopActivityUpdates()
                            } // end if data.automotive
                        } // end if userIsParked

                    } // end dispatch_async
                } // end if let data = data
            } // end activity manager closure

        } else {//SHOULD DELETE THIS ELSE, TEMP FOR SIM TESTING
            var date = self.getTime()
            self.ref.child("AvailableSpot/\(date)").updateChildValues(["ParkedCoordLatitude":self.fetchParkedLatitude()]);
            self.ref.child("AvailableSpot/\(date)").updateChildValues(["ParkedCoordLongitude":self.fetchParkedLongitude()]);
        }




    }


    // Determines if the user is in row of parking stalls
    func userInStall(userXCoord: Double, userYCoord: Double) -> Bool {
        var userInStall = false
        var topSlope = 0.0
        var bottomSlope = 0.0
        var stallTopEdge = 0.0
        var stallBottomEdge = 0.0

        // calculate the 2 linear lines for the top and bottom edge of the row of parking stalls
        topSlope = (stallTopRight.0 - stallTopLeft.0)/(stallTopRight.1 - stallTopLeft.1)
        bottomSlope = (stallBottomRight.0 - stallBottomLeft.0)/(stallBottomRight.1 - stallBottomLeft.1)

        if userXCoord > stallTopLeft.1 && userXCoord < stallTopRight.1 {
            stallTopEdge = stallTopLeft.0 + (topSlope * (userXCoord - stallTopLeft.1))
            stallBottomEdge = stallBottomLeft.0 + (bottomSlope * (userXCoord - stallBottomLeft.1))
            print("print TRUEstalltoedge: \(stallTopEdge) stallbottomedge:: \(stallBottomEdge)")

            if userYCoord < stallTopEdge && userYCoord > stallBottomEdge {
                print("print: true")
                userInStall = true
            }
        }
        print("print: user is in parking stall: \(userInStall)")
        print("print: stalltoedge: \(stallTopEdge) stallbottomedge:: \(stallBottomEdge)")
        print("print: usercoordy: \(userYCoord) userXCoord:: \(userXCoord)")
        return userInStall
    }

    /*--------M&A START-----*/

    //from AccountSeetingsViewController.swif. 2:37pm 30
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
    //2:37 pm 30 refrenced from: http://stackoverflow.com/questions/24070450/how-to-get-the-current-time-as-datetime
    func getTime() -> (Int) {
        let currentDateTime = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour,.Minute,.Second], fromDate: currentDateTime)
        let hour = Int(components.hour)
        let min = Int(components.minute)
        let sec = Int(components.second)
        let date = hour*3600 + min*60 + sec
        return date
    }

    /*--------M&A END-----*/


}

// MARK: - CLLocationManagerDelegate
// Location manager - Requests permission from the user to get their location
//extension item1ViewController: CLLocationManagerDelegate {
    // This function is called when user grant/revokes permission, allow them to go to settings.
     /*
    // This function is called when the location manager receives new location data
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {

            // Display camera at new user location
            mapView?.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)

            // 8
            locationManager.stopUpdatingLocation()
        }

    } */
//}
