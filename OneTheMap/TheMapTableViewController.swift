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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    
    // MARK: - Table view data source
    //numberOfRowsInSection
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInformation.sharedInstance.studentInfos.count
        
    }
    //cellForRowAtIndexPath
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pinMapCell")!
        let studentInfo = StudentInformation.sharedInstance.studentInfos[indexPath.row]
        cell.textLabel?.text = studentInfo.fullName()
        cell.detailTextLabel?.text = studentInfo.linkUrl
        
        return cell
    }
    
    //didSelectRowAtIndexPath
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let studentInfo = StudentInformation.sharedInstance.studentInfos[indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: studentInfo.linkUrl)!)
    }

    //MARK: Action 
    // logout Button pressed function
    @IBAction func logoutBtnPressed(sender: AnyObject) {
        MapModel.shareInstance().logOut()
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    // refresh button pressed
    @IBAction func refreshBtnPressed(sender: AnyObject) {
        MapModel.shareInstance().loadStudentInfos {(success, errorString) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.tableView.reloadData()
                } else {
                    let alert = UIAlertController(title: "error", message: "No Internet Connection, Please connect to the Internet", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "diss", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
    }

    
}

