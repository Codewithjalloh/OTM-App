//
//  StudentInfo.swift
//  OneTheMap
//
//  Created by wealthyjalloh on 14/07/2016.
//  Copyright © 2016 CWJ. All rights reserved.
//  Completed
//

import Foundation

struct StudentInfo {
    
    //Properties
    let firstName: String
    let lastName: String
    let linkUrl: String
    let latitude: Double
    let longitude: Double
    
    // init 
    init(dict: [String: AnyObject]) {
        firstName = dict["firstName"] as! String
        lastName = dict["lastName"] as! String
        linkUrl = dict["linkUrl"] as! String
        latitude = dict["latitude"] as! Double
        longitude = dict["longitude"] as! Double
    }
    
    func fullName() -> String {
        return firstName + " " + lastName
    }
}