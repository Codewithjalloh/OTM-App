//
//  MapModel.swift
//  OneTheMap
//
//  Created by wealthyjalloh on 14/07/2016.
//  Copyright © 2016 CWJ. All rights reserved.
//

import Foundation
import MapKit


class MapModel: NSObject {
    
    // Properties
    var userFirstName: String?
    var userLastName: String?
    
    var sessionId: String?
    var accountKey: String?
    
    
    func login(email: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        // Create a request object.
        let urlString = "https://www.udacity.com/api/session"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSString(format: "{\"udacity\": {\"username\": \"%@\", \"password\":\"%@\"}}", email, password).dataUsingEncoding(NSUTF8StringEncoding)
        // Submit the request with a session.
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            // Error checking of response.
            guard error == nil else {
                completionHandler(success: false, errorString: error?.localizedDescription)
                return
            }
            guard let data = data else {
                completionHandler(success: false, errorString: "No data was returned by the request!")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length-5))
            // Parse the returned data.
            let parsedResult = try! NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            // any error to user, because of the false credentials.
            guard parsedResult.objectForKey("error") == nil else {
                completionHandler(success: false, errorString: (parsedResult.objectForKey("error")! as! String))
                return
            }
            //successfully logged in
            let accountKey = ((parsedResult["account"] as! [String: AnyObject])["key"] as! String)
            self.sessionId = ((parsedResult["session"] as! [String: AnyObject])["id"] as! String)
            self.getUserData(accountKey, completionHandler: { (success, errorString) -> Void in
                if (success) {
                    self.loadStudentInfos({ (success, errorString) -> Void in
                        completionHandler(success: success, errorString: errorString)
                    })
                } else {
                    completionHandler(success: false, errorString: errorString)
                }
            })
        }
        task.resume()
        
    }
    
    // get user data function
    func getUserData(accountKey: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: NSString(format: "https://www.udacity.com/api/users/%@", accountKey) as String)!)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {data, response, error in guard error == nil else {
            completionHandler(success: false, errorString: error?.localizedDescription)
            return
            
            }
            guard let data = data else {
                completionHandler(success: false, errorString: "No data was returned by the request!")
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            let parsedResult = try! NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            
            self.userFirstName = ((parsedResult["user"] as! [String: AnyObject]) ["first_name"] as! String)
            self.userLastName = ((parsedResult["user"] as! [String: AnyObject]) ["last_name"] as! String)
            self.accountKey = accountKey
            completionHandler(success: true, errorString: nil)
        }
        task.resume()
        
    }
    
    func logOut() {
        accountKey = nil
        userFirstName = nil
        userLastName = nil
        sessionId = nil
    }
    
    // load student info functions
    func loadStudentInfos(completionHandler: (success: Bool, errorString: String?) -> Void) {
        // retrive student loc data
        let parameters = ["order": "-updatedAt"]
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation" + MapModel.escapeParameters(parameters))!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in guard error == nil else {
            completionHandler(success: false, errorString: error?.description)
            return
            }
            
            guard let data = data else {
                completionHandler(success: false, errorString: "No data was returned by request!")
                return
            }
            let parseResult: AnyObject!
            do {
                parseResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                completionHandler(success: false, errorString: "Not able to parse result from server!")
                return
            }
            
            let resultsArray = parseResult.objectForKey("results") as? [NSDictionary]
            guard resultsArray != nil else {
                completionHandler(success: false, errorString: "Server error: unparseable results array.")
                return
            }
            
            StudentInformation.sharedInstance.studentInfos.removeAll()
            for dict in resultsArray! {
                
                
                var latitude: AnyObject = 0.0
                var longitude: AnyObject = 0.0
                var firstName: AnyObject = ""
                var lastName: AnyObject = ""
                var linkUrl: AnyObject = ""
                
                if let aLatitude = dict.objectForKey("latitude") as? Double {
                    latitude = CLLocationDegrees(aLatitude)
                }
                if let aLongitude = dict.objectForKey("longitude") as? Double {
                    longitude = CLLocationDegrees(aLongitude)
                }
                if let fName = dict.objectForKey("firstName") as? String {
                    firstName = fName
                }
                if let lName = dict.objectForKey("lastName") as? String {
                    lastName = lName
                }
                if let url = dict.objectForKey("mediaURL") as? String {
                    linkUrl = url
                }
                
                StudentInformation.sharedInstance.studentInfos.append(StudentInfo(dict: ["firstName": firstName, "lastName": lastName, "linkUrl": linkUrl, "latitude": latitude, "longitude": longitude]))
            }
            completionHandler(success: true, errorString: nil)
        }
        task.resume()
    }

    // add new student info and submit function
    func newStudentDetailsAndSubmit(mapString: String, mediaURL: String, placemark: MKPlacemark, completionHandler: (success: Bool, errorString: String?) -> Void ){
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = NSString(format: "{\"uniqueKey\": \"%@\", \"firstName\": \"%@\", \"lastName\": \"%@\",\"mapString\": \"%@\", \"mediaURL\": \"%@\",\"latitude\": %f, \"longitude\": %f}", accountKey!, userFirstName!, userLastName!, mapString, mediaURL, placemark.coordinate.latitude, placemark.coordinate.longitude).dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {data, response, error in
        
            guard error == nil else {
                completionHandler(success: false, errorString: error?.description)
                return
            }
            let studentInfo = StudentInfo(dict: ["firstName": self.userFirstName!, "lastName": self.userLastName!, "linkUrl": mediaURL, "latitude": placemark.coordinate.latitude, "longitude": placemark.coordinate.longitude])
            StudentInformation.sharedInstance.studentInfos.insert(studentInfo, atIndex: 0)
            completionHandler(success: true, errorString: nil)
        }
        task.resume()
    }
    
    
    
    class func shareInstance() -> MapModel {
        struct Singleton {
            static var shareInstance = MapModel()
        }
        return Singleton.shareInstance
    }
    
    class func escapeParameters(parameters: [String: AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            let strValue = "\(value)"
            
            // escape
            let escapeValue = strValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // append
            urlVars += [key + "=" + "\(escapeValue!)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
  
    
}
