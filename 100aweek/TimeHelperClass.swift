//
//  TimeHelperClass.swift
//  100aweek
//
//  Created by Zel Marko on 28/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class TimeHelperClass: NSObject {
   
    func getWeekOfYear(date: NSDate) -> String {
        let calendar = NSCalendar.currentCalendar()
        calendar.firstWeekday = 2
        let components = calendar.components(.WeekOfYearCalendarUnit, fromDate: date)
        return "\(components.weekOfYear)"
    }
    
    func getSummedTimes(timingsArr: [TimeEntry]) -> [String] {
        var activeHours = 0
        var activeMin = 0
        var activeSec = 0
        
        var pausedHours = 0
        var pausedMin = 0
        var pausedSec = 0
        
        var pausesTot = 0
        
        for entry in timingsArr {
            let active = entry.activeTime.componentsSeparatedByString(" : ")
            activeHours += active[0].toInt()!
            activeMin += active[1].toInt()!
            activeSec += active[2].toInt()!
            
            let paused = entry.pausedTime.componentsSeparatedByString(" : ")
            pausedHours += paused[0].toInt()!
            pausedMin += paused[1].toInt()!
            pausedSec += paused[2].toInt()!
            
            pausesTot += Int(entry.pauseCount)
        }
        
        if activeSec >= 60 {
            let sorter = getTimeValues(activeSec)
            activeMin += sorter.overflow
            activeSec -= sorter.rest
        }
        if activeMin >= 60 {
            let sorter = getTimeValues(activeMin)
            activeHours += sorter.overflow
            activeMin -= sorter.rest
        }
        
        if pausedSec >= 60 {
            let sorter = getTimeValues(pausedSec)
            pausedMin += sorter.overflow
            pausedSec -= sorter.rest
        }
        if pausedMin >= 60 {
            let sorter = getTimeValues(pausedMin)
            pausedHours += sorter.overflow
            pausedMin -= sorter.rest
        }
        
        let activeSecStr = activeSec > 9 ? "\(activeSec)" : "0\(activeSec)"
        let activeMinStr = activeMin > 9 ? "\(activeMin)" : "0\(activeMin)"
        
        let pausedSecStr = pausedSec > 9 ? "\(pausedSec)" : "0\(pausedSec)"
        let pausedMinStr = pausedMin > 9 ? "\(pausedMin)" : "0\(pausedMin)"
        
        return ["\(activeHours) : \(activeMinStr) : \(activeSecStr)", "\(pausedHours) : \(pausedMinStr) : \(pausedSecStr)", "\(pausesTot)"]
    }
    
    func getTimeValues(amount: Int) -> (rest: Int, overflow: Int) {
        let overflow = amount / 60
        let rest = overflow * 60
        
        return (rest, overflow)
    }

    func removeDuplicateElements(arr: [String]) -> [String] {
        var array = arr

        var filter = Dictionary<String,Int>()
        var len = array.count
        for var index = 0; index < len  ;++index {
            var value = "\(array[index])"
            if filter[value] != nil {
                array.removeAtIndex(index--)
                len--
            }else{
                filter[value] = 1
            }
        }
        return array
    }
    
    func mergeDaysMechanism(timings: [[TimeEntry]]) -> [TimeEntry] {
        
        var merged = [TimeEntry]()
        
        
        for day in timings {
            let summed = getSummedTimes(day)
                        
            let sDate = day[0].startDate
            let sTime = day[0].startTime
            let eTime = day[(day.count - 1)].endTime
            let aTime = summed[0]
            let pTime = summed[1]
            let pCount = summed[2].toInt()!
            
            let entry = TimeEntry.createWithoutManagedObject(sDate, _startTime: sTime, _endTime: eTime, _duration: "", _activeTime: aTime, _pausedTime: pTime, _pauseCount: pCount)
            
            
            merged.append(entry)
        }
        
        return merged
    }

}
