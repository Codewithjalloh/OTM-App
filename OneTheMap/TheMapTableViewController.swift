//
//  TheMapTableViewController.swift
//  OneTheMap
//
//  Created by wealthyjalloh on 14/07/2016.
//  Copyright © 2016 CWJ. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class TheMapTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    @IBAction func logoutBtnPressed(sender: AnyObject) {
        MapModel.shareInstance().logOut()
        let loginC = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(loginC, animated: true, completion: nil)
        
    }
    
    @IBAction func refreshBtnPressed(sender: AnyObject) {
        MapModel.shareInstance().loadStudentInfos {(success, errorString) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.tableView.reloadData()
                } else {
                    let alert = UIAlertController(title: "error", message: errorString, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "diss", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return MapModel.shareInstance().studentBios.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pinMapCell", forIndexPath: indexPath)
        let studentInfo = MapModel.shareInstance().studentBios[indexPath.row]
        cell.textLabel?.text = studentInfo.fullName()
        cell.detailTextLabel?.text = studentInfo.linkUrl

        return cell
    }


    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentInfo = MapModel.shareInstance().studentBios[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: studentInfo.linkUrl)!)
    }
    
   

}
