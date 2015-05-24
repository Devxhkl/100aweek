//
//  Timers.swift
//  TimerHelp100
//
//  Created by Zel Marko on 21/05/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class Timers: NSObject {
    
    var timer: NSTimer?
    var startDate: NSDate!
    var endDate: NSDate!
    var activeStartInterval = NSTimeInterval()
    var pauseStartInterval = NSTimeInterval()
    var activeTime = NSTimeInterval()
    var lastActiveInterval = NSTimeInterval()
    var pauseTime = NSTimeInterval()
    var lastPauseInterval = NSTimeInterval()
    var active = true
        
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let backupManager = OfflineBackupManager()
}

extension Timers {
    
    func backup() {
        if backupManager.requestBackup() {
            let _backup = backupManager.getBackup()
            println("_backup lastStartInterval: \(_backup.lastStartInterval), active: \(_backup.active)")
            
            activeTime = _backup.activeTime.doubleValue
            pauseTime = _backup.pauseTime.doubleValue
            active = _backup.active.boolValue

            if _backup.active.boolValue {
                activeStartInterval = _backup.lastStartInterval.doubleValue
                
                println("activeStartInterval == lastStartInterval == \(activeStartInterval)")
                updateActiveTime()
                
                notificationCenter.postNotificationName("pauseTimeLabelNotificationKey", object: nil, userInfo: ["pauseTime": "\(Formatter.formatIntervalToString(round(pauseTime)))", "changeTitle": true])
            }
            else {
                pauseStartInterval = _backup.lastStartInterval.doubleValue
                
                println("pauseStartInterval == lastStartInterval == \(pauseStartInterval)")
                updatePauseTime()
                
                notificationCenter.postNotificationName("activeTimeLabelNotificationKey", object: nil, userInfo: ["activeTime": "\(Formatter.formatIntervalToString(round(activeTime)))", "changeTitle": true])
            }
        }
        
    }
    
    func start() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateActiveTime", userInfo: nil, repeats: true)
        activeStartInterval = NSDate.timeIntervalSinceReferenceDate()
        startDate = NSDate()
        
        backupManager.createBackup(startDate, lastStartInterval: activeStartInterval)
        active = true
    }
    
    func pause() {
        if timer != nil {
            timer?.invalidate()
            lastActiveInterval = 0
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updatePauseTime", userInfo: nil, repeats: true)
        pauseStartInterval = NSDate.timeIntervalSinceReferenceDate()
        active = false
        
        backupManager.updateBackup(pauseStartInterval, active: false, activeTime: activeTime, pauseTime: pauseTime)
    }
    
    func resume() {
        if timer != nil {
            timer?.invalidate()
            lastPauseInterval = 0
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateActiveTime", userInfo: nil, repeats: true)
        activeStartInterval = NSDate.timeIntervalSinceReferenceDate()
        active = true
        
        backupManager.updateBackup(activeStartInterval, active: true, activeTime: activeTime, pauseTime: pauseTime)
    }
    
    func stop() {
        if timer != nil {
            timer?.invalidate()
        }
        
        endDate = NSDate()
        save()
    }
    
    func updateActiveTime() {
        let nowInterval = NSDate.timeIntervalSinceReferenceDate()
        let currentActiveInterval = (nowInterval - activeStartInterval)
        
        activeTime += (currentActiveInterval - lastActiveInterval)
        lastActiveInterval = currentActiveInterval
        
        notificationCenter.postNotificationName("activeTimeLabelNotificationKey", object: nil, userInfo: ["activeTime":"\(Formatter.formatIntervalToString(round(activeTime)))"])
    }
    
    func updatePauseTime() {
        let nowInterval = NSDate.timeIntervalSinceReferenceDate()
        let curentPauseInterval = nowInterval - pauseStartInterval
        
        pauseTime += (curentPauseInterval - lastPauseInterval)
        lastPauseInterval = curentPauseInterval
        
        notificationCenter.postNotificationName("pauseTimeLabelNotificationKey", object: nil, userInfo: ["pauseTime":"\(Formatter.formatIntervalToString(round(pauseTime)))"])
    }
    
    func save() {
        
        let timeFormat = NSDateFormatter()
        timeFormat.dateFormat = "H:mm:ss"
        
        let startTime = timeFormat.stringFromDate(startDate)
        let endTime = timeFormat.stringFromDate(endDate)
        
        TimeEntry.createInManagedObjectContext((UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!, _startDate: startDate, _startTime: startTime, _endTime: endTime, _activeTime: Formatter.formatIntervalToString(activeTime), _pausedTime: Formatter.formatIntervalToString(pauseTime), _pauseCount: 0, _summary: "Placeholder")
        
        var error: NSError?
        if (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext?.save(&error) != nil {
            println("Saved")
        }
    }
}

