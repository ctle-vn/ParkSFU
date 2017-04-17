//
//  decisionModule.swift
//  CMPT275
//
//  Created and written by Greyson Wang on 11/3/16.
//  Copyright © 2016 Christopher Le. All rights reserved.
//  This file is the preliminary code for deciding whether the user has parked their car
//  The top and bottom edge of a row of parking stalls is modelled using a linear relationship. 
//  If the user's x coordinate is within the row of parking stalls, we use the linear relationship to compute
//  the y coordinate of the edge of the parking stall, and if the user's y coordinate is between those 2 values, the user is inside the parking stall.
//  We define the vector parkingDirection as the direction that the user should be moving right before they are parking their car.
//  If the angle between parkingDirection vector and the actual vector of the user's movement direction is > 20 degrees, then the user is probably not parking their car.

import Foundation

// These numbers are placeholders
let stallTopLeft = (49.276630, -122.912885)
let stallTopRight = (49.276194, -122.910062)
let stallBottomLeft = (49.276548, -122.912909)
let stallBottomRight = (49.276115, -122.910083)
let parkingDirection = (90, 90)  // vector of direction that user should be moving when they are parking

// Takes current user coordinates, returns the stat of the user
func userState(xCoord: Double, yCoord: Double ) -> String {
    var state = "driving"
    var userSpeed = 0
    var userDirection = (0, 0) //vector, direction user was moving before they parked
    
    userSpeed = getUserSpeed()
    
    if userInParkingLot() == true
    {
        userDirection = getUserDirection()
        
            if userSpeed == 0
            {
                if userInStall(xCoord, userYCoord: yCoord) == true && angle(userDirection) < 25
                {
                    state = "parked"
                }
            }
        
    }
    
    return state
}


// Determines if the user is in stall
func userInStall(userXCoord: Double, userYCoord: Double) -> Bool {
    var userInStall = false
    var topSlope = 0.0
    var bottomSlope = 0.0
    var stallTopEdge = 0.0
    var stallBottomEdge = 0.0
    // calculate the 2 linear lines for the top and bottom edge of the row of parking stalls
    topSlope = (stallTopRight.1 - stallTopLeft.1)/(stallTopRight.0 - stallTopLeft.0)
    bottomSlope = (stallBottomRight.1 - stallBottomLeft.1)/(stallBottomRight.0 - stallBottomLeft.0)
    
    if userXCoord > stallTopLeft.0 && userXCoord < stallTopRight.0 {
        stallTopEdge = stallTopLeft.1 + (topSlope * (userXCoord - stallTopLeft.0))
        stallBottomEdge = stallBottomLeft.1 + (bottomSlope * (userXCoord - stallBottomLeft.0))
        
        if userYCoord < stallTopEdge && userYCoord > stallBottomEdge {
            userInStall = true
        }
    }
    
    return userInStall
}

// returns angle between 2 vectors
// stab function, to be implemented later
func angle(userDirection: (Int, Int)) -> Int {
    return 11
    
}

// Returns direction that user was moving in before they parked
func getUserDirection() -> (Int, Int) {
    
    return (27, 27)
}

// This is a stab function
func getUserSpeed() -> Int {
    return 45
}

// stub function
func userInParkingLot() -> Bool {
    
 return true
}
