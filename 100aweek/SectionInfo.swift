//
//  SectionInfo.swift
//  100aweek
//
//  Created by Zel Marko on 20/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class SectionInfo: NSObject {
   
    var isOpen = false
    var timings = [TimeEntry]()
    var headerCell = HeaderViewCell()
    
    func getStartEndOFWeek(date: NSDate) -> String {
        var start: NSDate?
        var end: NSDate?
        var interval = NSTimeInterval()
        let calendar = NSCalendar.currentCalendar()
        let second: NSTimeInterval = 1
        
        calendar.firstWeekday = 2
        calendar.rangeOfUnit(.CalendarUnitWeekOfYear, startDate: &start, interval: &interval, forDate: date)
        end = start?.dateByAddingTimeInterval(interval - second)
        
        let startDateFormat = NSDateFormatter()
        startDateFormat.dateFormat = "d"
        let endDateFormat = NSDateFormatter()
        endDateFormat.dateFormat = "d MMM"
        
        let weekStart = startDateFormat.stringFromDate(start!)
        let weekEnd = endDateFormat.stringFromDate(end!)
        
        return "\(weekStart) - \(weekEnd.lowercaseString)"
    }
    
    func getSuccessfullTimings(timingsArr: [TimeEntry]) -> String {
        var successTimings = 0
        for entry in timingsArr {
            let time = entry.activeTime.componentsSeparatedByString(" : ")
                
            if time[0].toInt() > 14 {
                successTimings++
            }
            else if time[0].toInt() == 14 {
                if time[1].toInt() > 17 {
                    successTimings++
                }
                else if time[1].toInt() == 17 {
                    if time[2].toInt() >= 8 {
                        successTimings++
                    }
                }
            }
        }
        
        return "\(successTimings) / \(timingsArr.count)"
    }
    
        
    
}
