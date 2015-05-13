//
//  BackupManager.swift
//  100aweek
//
//  Created by Zel Marko on 03/04/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class BackupManager: NSObject {
    
    var date: NSDate!
    var time: NSTimeInterval!
    var pauseTime: NSTimeInterval!
    var pausedCount: Int!
    var ended: Bool!
    let intra = Reachability.isConnectedToNetwork()
    
    func getBackupFromBase() -> BackupManager {
        let backupMan = BackupManager()
        if intra {
            
        
            let url = NSURL(string: "http://disobeythesystem.com/timer_backdown.php")
            if let data = NSData(contentsOfURL: url!) {
            

                var error: NSError?
                let json = JSON(data: data)
                let lastBackupIndex = json.count - 1
                let dateFormat = NSDateFormatter()
                dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let rawDate = json[lastBackupIndex]["date"].string {
                    backupMan.date = dateFormat.dateFromString(rawDate)
                }
                backupMan.time = json[0]["start"].doubleValue
                backupMan.pauseTime = json[0]["paused"].doubleValue
                backupMan.pausedCount = json[0]["pauses"].intValue
                backupMan.ended = json[0]["pause"].boolValue
            }
        }
        return backupMan
    }
    
    func createInitialBackup(start: NSDate) {
        if intra {
            let idFormat = NSDateFormatter()
            idFormat.dateFormat = "yyyyMMdd"
        
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormat.timeZone = NSTimeZone.localTimeZone()
        
            let id = idFormat.stringFromDate(start).toInt()!
            let startDate = dateFormat.stringFromDate(start)
            let startTime = start.timeIntervalSinceReferenceDate
            let data = "ID=\(id)&date=\(startDate)&start=\(startTime)&pause=0"
        
            pushData(data)
        }
    }
    
    func updateBackupFromPause(startTime: NSDate, pausedTime: NSTimeInterval, pauseCount: Int) {
        if intra {
            let idFormat = NSDateFormatter()
            idFormat.dateFormat = "yyyyMMdd"
        
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormat.timeZone = NSTimeZone.localTimeZone()

            let startDate = dateFormat.stringFromDate(startTime)
        
            let id = idFormat.stringFromDate(startTime).toInt()!
            let data = "ID=\(id)&date=\(startDate)&paused=\(pausedTime)&pauses=\(pauseCount)"
        
       
            pushData(data)
        }
    }
    
    func pushData(pusherData: String) {
        let url = NSURL(string: "http://disobeythesystem.com/timer_backup.php")
        
        let requestData = (pusherData as String).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let data = pusherData
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.HTTPBody = requestData
        
        let queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { response, data, error in
            let returned = NSString(data: data, encoding: NSUTF8StringEncoding)!
            println(returned)
        })
        
    }
    
    func deleteBackup() {
        let url = NSURL(string: "http://disobeythesystem.com/timer_delete.php")
        
        let request = NSMutableURLRequest(URL: url!)
        
        let queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { response, data, error in
            let returned = NSString(data: data, encoding: NSUTF8StringEncoding)!
            println(returned)
        })

    }
   
}
