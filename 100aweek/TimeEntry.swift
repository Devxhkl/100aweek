//
//  TimeEntry.swift
//  100aweek
//
//  Created by Zel Marko on 19/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import Foundation
import CoreData

class TimeEntry: NSManagedObject {

    @NSManaged var activeTime: String
    @NSManaged var duration: String
    @NSManaged var endTime: NSDate
    @NSManaged var pauseCount: NSNumber
    @NSManaged var pausedTime: String
    @NSManaged var startTime: NSDate

    class func createInManagedObjectContext(moc: NSManagedObjectContext, _startTime: NSDate, _endTime: NSDate, _duration: String, _activeTime: String, _pausedTime: String, _pauseCount: NSNumber) -> TimeEntry {
        
        let newEntry = NSEntityDescription.insertNewObjectForEntityForName("TimeEntry", inManagedObjectContext: moc) as TimeEntry
        
        newEntry.startTime = _startTime
        newEntry.endTime = _endTime
        newEntry.duration = _duration
        newEntry.activeTime = _activeTime
        newEntry.pausedTime = _pausedTime
        newEntry.pauseCount = _pauseCount
        
        return newEntry
    }

}
