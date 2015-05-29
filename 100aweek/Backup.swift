//
//  Backup.swift
//  TimerHelp100
//
//  Created by Zel Marko on 23/05/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import Foundation
import CoreData

class Backup: NSManagedObject {
    
    @NSManaged var startDate: NSDate
    @NSManaged var active: NSNumber
    @NSManaged var activeTime: NSNumber
    @NSManaged var id: String
    @NSManaged var lastStartInterval: NSNumber
    @NSManaged var pauseTime: NSNumber
    
    class func createBackup(managedObjectContext: NSManagedObjectContext, _startDate: NSDate, _id: String, _lastStartInterval: NSNumber, _active: NSNumber, _activeTime: NSNumber, _pauseTime: NSNumber) -> Backup {
        
        let backup = NSEntityDescription.insertNewObjectForEntityForName("Backup", inManagedObjectContext: managedObjectContext) as! Backup
        
        backup.startDate = _startDate
        backup.id = _id
        backup.lastStartInterval = _lastStartInterval
        backup.activeTime = _activeTime
        backup.pauseTime = _pauseTime
        backup.active = _active
        
        return backup
    }

}
