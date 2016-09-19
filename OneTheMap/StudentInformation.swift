//
//  StudentInformation.swift
//  OneTheMap
//
//  Created by wealthyjalloh on 9/08/2016.
//  Copyright © 2016 CWJ. All rights reserved.
//
import Foundation

class StudentInformation {
    
    var studentInfos: [StudentInfo] = []
    
    static let sharedInstance = StudentInformation()
    
    private init() {}
}