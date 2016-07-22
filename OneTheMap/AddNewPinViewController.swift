//
//  AddNewPinViewController.swift
//  OneTheMap
//
//  Created by wealthyjalloh on 18/07/2016.
//  Copyright © 2016 CWJ. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class AddNewPinViewController: UIViewController {
    
    // MARK: Outle and Properties
    @IBOutlet weak var locationTxtField: UITextField!
    @IBOutlet weak var linkTxtField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var placemark: MKPlacemark!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.enabled = false
    }
    
    // MARK: ACTION FUNCTIONS
    // cancel button pressed function
    @IBAction func cancelBtnPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // find button pressed function
    @IBAction func findBtnPressed(sender: AnyObject) {
        guard locationTxtField.text != "" else {
            let alert = UIAlertController(title: "error", message: "must enter a location ", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        activityIndicator.startAnimating()
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationTxtField.text!) { (placemarks, error) -> Void in
        
            guard error == nil else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "error", message: error?.localizedDescription, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                return
            }
            
            guard placemarks!.count > 0 else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "error", message: "no match found.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicator.stopAnimating()
                self.placemark = MKPlacemark(placemark: placemarks![0])
                self.mapView.addAnnotation(self.placemark)
                let region = MKCoordinateRegionMakeWithDistance(self.placemark.coordinate, 100000, 100000)
                self.mapView.setRegion(region, animated: true)
                self.submitBtn.enabled = true
            })
        }
    
    }
    
    // preview button pressed function
    @IBAction func prvBtnPressed(sender: AnyObject) {
        guard linkTxtField.text != "" else {
            let alert = UIAlertController(title: "error", message: "you must a link", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        let app = UIApplication.sharedApplication()
        let url = NSURL(string: linkTxtField.text!)!
        if app.canOpenURL(url) {
            app.openURL(url)
        } else {
            let alert = UIAlertController(title: "error", message: "cannot open link", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func submitBtnPressed(sender: AnyObject) {
        guard linkTxtField.text != "" else {
        
            let alert = UIAlertController(title: "error", message: "you need to enter a link.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        MapModel.shareInstance().newStudentDetailsAndSubmit(locationTxtField.text!, mediaURL: linkTxtField.text!, placemark: self.placemark) { (success, errorString) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if (success) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                } else {
                    let alert = UIAlertController(title: "error", message: errorString!, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "dismiss", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }
    

}
