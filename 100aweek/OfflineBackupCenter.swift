//
//  OfflineBackupCenter.swift
//  TimerHelp100
//
//  Created by Zel Marko on 22/05/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit
import CoreData

class OfflineBackupManager {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    var backup: Backup?

}

extension OfflineBackupManager {
    
    func requestBackup() -> Bool {
        let request = NSFetchRequest(entityName: "Backup")
        let results = managedObjectContext.executeFetchRequest(request, error: nil) as! [Backup]
        
        if let _backup = results.first {
            backup = _backup
            println("Backup is available.")
            return true
        }
        else {
            println("No backup available.")
            return false
        }
        
    }
    
    func getBackup() -> Backup {
        return backup!
    }
    
    func createBackup(startDate: NSDate, lastStartInterval: NSTimeInterval) {
        
        let backup = Backup.createBackup(managedObjectContext, _id: Formatter.dateToID(startDate), _lastStartInterval: lastStartInterval, _active: 1, _activeTime: 0, _pauseTime: 0)
        
//        var error: NSError?
//        if (managedObjectContext.save(&error)) {
//            println("Initial backup created.")
//        }
//        else {
//            println(error?.localizedDescription)
//        }
    }
    
    func updateBackup(lastStartInterval: NSTimeInterval, active: Bool, activeTime: NSTimeInterval, pauseTime: NSTimeInterval) {
        if let _backup = backup {
            _backup.lastStartInterval = lastStartInterval
            _backup.active = active
            _backup.activeTime = activeTime
            _backup.pauseTime = pauseTime
        }
        
        var error: NSError?
        if managedObjectContext.save(&error) {
            println("Backup updated.")
        }
        else {
            println(error?.localizedDescription)
        }
    }
}
