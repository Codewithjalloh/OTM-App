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
            pinV?.canShowCallout = true
            pinV?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
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
    
    
    func addAnnotations() {
        var annotations = [MKPointAnnotation]()
        for studentBio in MapModel.shareInstance().studentInfos {
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: studentBio.latitude, longitude: studentBio.longitude)
            annotation.title = studentBio.fullName()
            annotation.subtitle = studentBio.linkUrl
            
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    
    
    func removeAllAnnotations() {
        let annotationToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
        mapView.removeAnnotations(annotationToRemove)
    }
    
    
    func loadMapDataAndDisplay() {
        MapModel.shareInstance().loadStudentInfos { (success, errorString) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.removeAllAnnotations()
                    self.addAnnotations()
                } else {
                    let alert = UIAlertController(title: "error", message: errorString, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }

    func submitNewPin() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    
    @IBAction func logOutBtnPressed(sender: AnyObject) {
        MapModel.shareInstance().logOut()
        let loginC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(loginC, animated: true, completion: nil)
    }
    
    
    @IBAction func refreshBtnPushed(sender: AnyObject) {
        loadMapDataAndDisplay()
    }

}
