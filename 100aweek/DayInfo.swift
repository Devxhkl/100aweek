//
//  DayInfo.swift
//  100aweek
//
//  Created by Zel Marko on 21/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class DayInfo: NSObject {
    
    var isOpen = false
    var timing: TimeEntry!
    var headerCell = DailyHeaderCell()
    
    func getPercentage(time: String) -> (percentage: String, over: Bool) {
        var interval: CGFloat = 0.0
        let timeArr = time.componentsSeparatedByString(" : ")
    
        let daily: CGFloat = (100 * 3600) / 7
    
        interval += CGFloat(Int(timeArr[0])! * 3600)
        interval += CGFloat(Int(timeArr[1])! * 60)
        interval += CGFloat(Int(timeArr[2])!)
    
        let percentage = Int((interval / daily) * 100)
        var over = false
        if percentage >= 100 {
            over = true
        }
    
        return ("\(percentage) %", over)
    }
}

