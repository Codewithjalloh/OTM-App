//
//  LoginViewController.swift
//  OneTheMap
//
//  Created by wealthyjalloh on 14/07/2016.
//  Copyright © 2016 CWJ. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    //MARK: Outlets 
    @IBOutlet weak var emailTxtField: UITextView!
    @IBOutlet weak var passwrdTxtField: UITextView!
    
    
    //MARK: Action
    @IBAction func loginBtnPressed(sender: AnyObject) {
        // email and password are not empty.
        guard (!emailTxtField.text.isEmpty && !passwrdTxtField.text.isEmpty) else {
            let alert = UIAlertController(title: "Error", message: "Email and/or password field is empty.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        MapModel.shareInstance().login(emailTxtField.text!, password: passwrdTxtField.text!) { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "error", message: errorString, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "click", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
        
        })
        return
        
            }
            dispatch_async(dispatch_get_main_queue(), {
                let tabBC = self.storyboard!.instantiateViewControllerWithIdentifier("TabBC") as! UITabBarController
                self.presentViewController(tabBC, animated: true, completion: nil)
            })
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }



}
