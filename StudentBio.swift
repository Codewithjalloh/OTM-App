//
//  StudentBio.swift
//  OneTheMap
//
//  Created by wealthyjalloh on 14/07/2016.
//  Copyright © 2016 CWJ. All rights reserved.
//

import Foundation

struct StudentBio {
    
    var firstName: String
    var lastName: String
    var linkUrl: String
    var latitude: Double
    var longitude: Double
    
    
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