//
//  Formatter.swift
//  TimerHelp100
//
//  Created by Zel Marko on 22/05/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class Formatter: NSObject {
    
    class func dateToID(date: NSDate) -> String {
        let format = NSDateFormatter()
        format.dateFormat = "yyyyMMdd"
        
        return format.stringFromDate(date)
    }
    
    class func formatIntervalToString(tInterval: NSTimeInterval) -> String {
        var interval = tInterval
        
        let hours = Int(interval / 3600.0)
        interval -= NSTimeInterval(hours) * 3600
        
        let minutes = Int(interval / 60.0)
        interval -= NSTimeInterval(minutes) * 60
        
        let seconds = Int(interval)
        interval -= NSTimeInterval(seconds)
        
        let strMinutes = minutes > 9 ? String(minutes) : "0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds) : "0" + String(seconds)
        
        let time = "\(hours) : \(strMinutes) : \(strSeconds)"
        return time
    }

}
