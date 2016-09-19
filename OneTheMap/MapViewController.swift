//
//  MapViewController.swift
//  OneTheMap
//
//  Created by wealthyjalloh on 18/07/2016.
//  Copyright © 2016 CWJ. All rights reserved.
//


import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate  {
    
    // Outlet
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        removeAllAnnotations()
        addAnnotations()
        
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var pinV = mapView.dequeueReusableAnnotationViewWithIdentifier("pinpoint") as? MKPinAnnotationView
        
        if pinV == nil {
            pinV = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinpoint")
            pinV!.canShowCallout = true
            pinV!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinV?.annotation = annotation
        }
        return pinV
    }

    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
    // remove All Annotations function
    func removeAllAnnotations() {
        let annotationToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(annotationToRemove)
    }
    
    // add annotation function
    func addAnnotations() {
        var annotations = [MKPointAnnotation]()
        for studentInfo in StudentInformation.sharedInstance.studentInfos {
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: studentInfo.latitude, longitude: studentInfo.longitude)
            annotation.title = studentInfo.fullName()
            annotation.subtitle = studentInfo.linkUrl
            
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    
    
    
    // load the Map Data And Display function 
    func loadMapDataAndDisplay() {
        MapModel.shareInstance().loadStudentInfos { (success, errorString) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.removeAllAnnotations()
                    self.addAnnotations()
                } else {
                    let alert = UIAlertController(title: "Error", message: "No Internet Connection, Please connect to the Internet", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }

    

    // MARK: Action 
    // logout button pressed
    @IBAction func logOutBtnPressed(sender: AnyObject) {
        MapModel.shareInstance().logOut()
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // submit new pin function
    func submitNewPin() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 40.0, \"longitude\": -100.0}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard error == nil else {
                print("error returned by request", error)
                return
            }
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        }
        task.resume()
        
    }

    
    // refresh button pressed
    @IBAction func refreshBtnPushed(sender: AnyObject) {
        loadMapDataAndDisplay()
    }

}
