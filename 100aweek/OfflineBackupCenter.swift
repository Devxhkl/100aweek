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
        do {
            let results = try! managedObjectContext.executeFetchRequest(request) as! [Backup]
            
            if let _backup = results.first {
                print(_backup.active)
                backup = _backup
                print("Backup is available.")
                return true
            }
            else {
                print("No backup available.")
                return false
            }
        }
        
        
    }
    
    func getBackup() -> Backup {
        return backup!
    }
    
    func createBackup(startDate: NSDate, lastStartInterval: NSTimeInterval) {
        
        backup = Backup.createBackup(managedObjectContext, _startDate: startDate, _id: Formatter.dateToID(startDate), _lastStartInterval: lastStartInterval, _active: 1, _activeTime: 0, _pauseTime: 0)
        
        do {
            try! managedObjectContext.save()
        }
    }
    
    func updateBackup(lastStartInterval: NSTimeInterval, active: Bool, activeTime: NSTimeInterval, pauseTime: NSTimeInterval) {
        if backup != nil {
            backup!.lastStartInterval = lastStartInterval
            backup!.active = active
            backup!.activeTime = activeTime
            backup!.pauseTime = pauseTime
        }
        
        do {
            try! managedObjectContext.save()
        }
    }
    
    func delete() {
        managedObjectContext.deleteObject(backup!)
        
        do {
            try! managedObjectContext.save()
        }
    }
}
