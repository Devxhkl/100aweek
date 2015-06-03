//
//  Timers.swift
//  TimerHelp100
//
//  Created by Zel Marko on 21/05/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit
import CoreData

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
    var dailyPercentage = 0
    var weeklyPercentage = 0
    var weekEntries = [TimeEntry]()
    var active = true
        
    let notificationCenter = NSNotificationCenter.defaultCenter()
    let backupManager = OfflineBackupManager()
}

extension Timers {
    
//    MARK: - Backup
    
    func backup() {
        if backupManager.requestBackup() {
            let _backup = backupManager.getBackup()
//            println("_backup lastStartInterval: \(_backup.lastStartInterval), active: \(_backup.active)")
            
            activeTime = _backup.activeTime.doubleValue
            pauseTime = _backup.pauseTime.doubleValue
            active = _backup.active.boolValue
            startDate = _backup.startDate
//            println("Active: \(activeTime), Pause: \(pauseTime), a/p: \(active), sinta: \(lastActiveInterval), pintra: \(lastPauseInterval)")

            if _backup.active.boolValue {
                activeStartInterval = _backup.lastStartInterval.doubleValue
                updateActiveTime()
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateActiveTime", userInfo: nil, repeats: true)
                
                notificationCenter.postNotificationName("pauseTimeLabelNotificationKey", object: nil, userInfo: ["pauseTime": "\(Formatter.formatIntervalToString(round(pauseTime)))", "changeTitle": true])
                println("activeStartInterval == lastStartInterval == \(activeStartInterval)")
            }
            else {
                pauseStartInterval = _backup.lastStartInterval.doubleValue
                updatePauseTime()
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updatePauseTime", userInfo: nil, repeats: true)
                
                notificationCenter.postNotificationName("activeTimeLabelNotificationKey", object: nil, userInfo: ["activeTime": "\(Formatter.formatIntervalToString(round(activeTime)))", "changeTitle": true])
                println("pauseStartInterval == lastStartInterval == \(pauseStartInterval)")
            }
        }
        percentage()
    }
    
//    MARK: - Actions
    
    func start() {
        println("start")
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateActiveTime", userInfo: nil, repeats: true)
        activeStartInterval = NSDate.timeIntervalSinceReferenceDate()
        startDate = NSDate()
        
        backupManager.createBackup(startDate, lastStartInterval: activeStartInterval)
        active = true
    }
    
    func pause() {
        println("pause")
        if timer != nil {
            timer?.invalidate()
            lastActiveInterval = 0
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updatePauseTime", userInfo: nil, repeats: true)
        pauseStartInterval = NSDate.timeIntervalSinceReferenceDate()
        active = false
        
        backupManager.updateBackup(pauseStartInterval, active: active, activeTime: activeTime, pauseTime: pauseTime)
    }
    
    func resume() {
        println("resume")
        if timer != nil {
            timer?.invalidate()
            lastPauseInterval = 0
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateActiveTime", userInfo: nil, repeats: true)
        activeStartInterval = NSDate.timeIntervalSinceReferenceDate()
        active = true
        
        backupManager.updateBackup(activeStartInterval, active: active, activeTime: activeTime, pauseTime: pauseTime)
    }
    
    func stop() {
        if timer != nil {
            timer?.invalidate()
        }
        
        endDate = NSDate()
    }
    
//    MARK: - Updating center
    
    func updateActiveTime() {
        let nowInterval = NSDate.timeIntervalSinceReferenceDate()
        let currentActiveInterval = (nowInterval - activeStartInterval)
        
        activeTime += (currentActiveInterval - lastActiveInterval)
        lastActiveInterval = currentActiveInterval
        
        notificationCenter.postNotificationName("activeTimeLabelNotificationKey", object: nil, userInfo: ["activeTime":"\(Formatter.formatIntervalToString(round(activeTime)))"])
        percentage()
    }
    
    func updatePauseTime() {
        let nowInterval = NSDate.timeIntervalSinceReferenceDate()
        let curentPauseInterval = nowInterval - pauseStartInterval
        
        pauseTime += (curentPauseInterval - lastPauseInterval)
        lastPauseInterval = curentPauseInterval
        
        notificationCenter.postNotificationName("pauseTimeLabelNotificationKey", object: nil, userInfo: ["pauseTime":"\(Formatter.formatIntervalToString(round(pauseTime)))"])
    }
    
    func percentage() {
        let daily: CGFloat = (100 * 3600) / 7
        let intra = CGFloat(activeTime)
        let percentage = Int((intra / daily) * 100)
        
        if percentage > dailyPercentage {
            notificationCenter.postNotificationName("percentageLabelNotificationKey", object: nil, userInfo: ["today": "\(percentage) %"])
            dailyPercentage = percentage
        }
        
        let helper = TimeHelperClass()
        if weekEntries.isEmpty {
            let fetchRequest = NSFetchRequest(entityName: "TimeEntry")
            let fetchResults = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as! [TimeEntry]
            
            
            let today = NSDate()
            var thisWeek = "0"
            if let lastDay = fetchResults.last {
                thisWeek = helper.getWeekOfYear(lastDay.startDate)
            }
            
            for entry in fetchResults {
                if helper.getWeekOfYear(entry.startDate) == thisWeek && helper.getWeekOfYear(today) == thisWeek {
                    weekEntries.append(entry)
                }
            }
        }
        
        var newWeek = true
        var weeklyToday = [String]()
        if  !weekEntries.isEmpty {
            let times = helper.getSummedTimes(weekEntries)
            let activeHoursArr = times[0].componentsSeparatedByString(" : ")
            newWeek = false
            
            let hours = Double(activeHoursArr[0].toInt()! * 3600)
            let minutes = Double(activeHoursArr[1].toInt()! * 60)
            let seconds = Double(activeHoursArr[2].toInt()!)
            
            weeklyToday = Formatter.formatIntervalToString(hours + minutes + seconds + activeTime).componentsSeparatedByString(" : ")
            
            if weeklyToday[0].toInt() > weeklyPercentage {
                notificationCenter.postNotificationName("percentageLabelNotificationKey", object: nil, userInfo: ["weekly": "\(weeklyToday[0]) %"])
            }
        }
        
        if newWeek {
            let mondayHours = Formatter.formatIntervalToString(activeTime).componentsSeparatedByString(" : ")
            notificationCenter.postNotificationName("percentageLabelNotificationKey", object: nil, userInfo: ["weekly": "\(mondayHours[0]) %"])
        }
        
//        if !newWeek && weeklyToday[0].toInt() >= 100 {
//            weeklyPertageLabel.textColor = UIColor.yellowColor()
//            weeklyLabel.textColor = UIColor.yellowColor()
//        }
        
        
    }
    
//    MARK: - TO BE CLEANED!!
    
    func save(summary: String) {
        
        let timeFormat = NSDateFormatter()
        timeFormat.dateFormat = "H:mm:ss"
        
        let startTime = timeFormat.stringFromDate(startDate)
        let endTime = timeFormat.stringFromDate(endDate)
        
        TimeEntry.createInManagedObjectContext((UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!, _startDate: startDate, _startTime: startTime, _endTime: endTime, _activeTime: Formatter.formatIntervalToString(activeTime), _pausedTime: Formatter.formatIntervalToString(pauseTime), _pauseCount: 0, _summary: summary)
        
        var error: NSError?
        if (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext?.save(&error) != nil {
            println("Saved")
            
            activeStartInterval = 0
            pauseStartInterval = 0
            activeTime = 0
            lastActiveInterval = 0
            pauseTime = 0
            lastPauseInterval = 0
            dailyPercentage = 0
            weeklyPercentage = 0
            weekEntries = [TimeEntry]()
            active = false
            percentage()
            
            notificationCenter.postNotificationName("activeTimeLabelNotificationKey", object: nil, userInfo: ["activeTime":"\(Formatter.formatIntervalToString(round(activeTime)))"])
            notificationCenter.postNotificationName("pauseTimeLabelNotificationKey", object: nil, userInfo: ["pauseTime":"\(Formatter.formatIntervalToString(round(pauseTime)))"])
            notificationCenter.postNotificationName("percentageLabelNotificationKey", object: nil, userInfo: ["today": "0 %"])
            
            backupManager.delete()
        }
    }
}

