//
//  DailyTableViewController.swift
//  100aweek
//
//  Created by Zel Marko on 21/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class DailyTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DailyHeadDelegate, TimerRefreshDelegate {

    @IBOutlet weak var dailyTable: UITableView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    var weekInfo = SectionInfo()
    var dayInfoArray = [DayInfo]()
    var todaily: ViewController?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let vc = todaily {
            vc.delegate = self
        }

        if dayInfoArray.count == 0 || dayInfoArray.count != self.numberOfSectionsInTableView(dailyTable) {
            
            var startDates = [String]()
            for entry in weekInfo.timings {
                let date = entry.startDate
                
                let dateFormat = NSDateFormatter()
                dateFormat.dateFormat = "EEE d MMM"
                let str = dateFormat.stringFromDate(date)
                startDates.append(str)
            }
            
            for date in startDates {
                var filter = Dictionary<String, Int>()
                var len = startDates.count
                for var index = 0; index < len; ++index {
                    var value = "\(startDates[index])"
                    if filter[value] != nil {
                        startDates.removeAtIndex(index--)
                        len--
                    }
                    else {
                        filter[value] = 1
                    }
                }
            }
            
            for date in startDates {
                let dayInfo = DayInfo()
                dayInfo.isOpen = false
                
                for entry in weekInfo.timings {
                    let day = entry.startDate
                    let str = getDay(day)
                    
                    if str == date {
                        dayInfo.timings.append(entry)
                    }
                }
                dayInfoArray.append(dayInfo)
            }

        }
    }
    
    // MARK: - TableView Stuff
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dayInfoArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dayInfo = dayInfoArray[section]
        let entryCount = dayInfo.timings.count
        
        return dayInfo.isOpen ? entryCount : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as DailyViewCell
        
        let dayInfo = dayInfoArray[indexPath.section]
        let entry = dayInfo.timings[indexPath.row]
        
        cell.activeLabel.text = entry.activeTime
        cell.pausedLabel.text = entry.pausedTime
        cell.pausesLabel.text = "\(entry.pauseCount)"
        let startEndIndex = "\(entry.startTime.endIndex)"
        cell.startLabel.text = entry.startTime.substringToIndex(advance(entry.startTime.startIndex, startEndIndex.toInt()! - 3))
        let endEndIndex = "\(entry.endTime.endIndex)"
        cell.endLabel.text = entry.endTime.substringToIndex(advance(entry.endTime.startIndex, endEndIndex.toInt()! - 3))
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCellWithIdentifier("Header") as DailyHeaderCell
        header.frame = CGRect(x: header.frame.origin.x, y: header.frame.origin.y, width: dailyTable.frame.width, height: header.frame.height)
        header.delegate = self
        
        let dayInfo = dayInfoArray[section]
        
        header.dayLabel.text = getDay(dayInfo.timings[0].startDate).lowercaseString
        let active = dayInfo.timings[0].activeTime
        let activeArr = active.componentsSeparatedByString(" : ")
        let dailySuccess = dayInfo.getPercentage(dayInfo.timings[0].activeTime)
        header.rateLabel.text = dailySuccess.percentage
        if dailySuccess.over {
            header.rateLabel.textColor = UIColor.greenColor()
        }
        else if dailySuccess.percentage.toInt() >= 80 && dailySuccess.percentage.toInt() < 100 {
            header.rateLabel.textColor = UIColor.yellowColor()
        }
        else {
            header.rateLabel.textColor = UIColor.redColor()
        }
        
        header.section = section
        dayInfo.headerCell = header
        
        let view = UIView(frame: header.frame)
        view.addSubview(header)
        
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func openSection(sectionHeaderCell: DailyHeaderCell, section: Int) {
        let dayInfo = dayInfoArray[section]
        dayInfo.isOpen = true
        
        let entryCount = dayInfo.timings.count
        var indexPathsToInsert = [NSIndexPath]()
        for var index = 0; index < entryCount; index++ {
            let indexPath = NSIndexPath(forRow: index, inSection: section)
            indexPathsToInsert.append(indexPath)
        }
        
        dailyTable.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: .Top)
    }
    
    func closeSection(sectionHeaderCell: DailyHeaderCell, section: Int) {
        let dayInfo = dayInfoArray[section]
        dayInfo.isOpen = false
        
        let entryCount = dayInfo.timings.count
        if entryCount > 0 {
            var indexPathsToDelete = [NSIndexPath]()
            for var index = 0; index < entryCount; index++ {
                let indexPath = NSIndexPath(forRow: index, inSection: section)
                indexPathsToDelete.append(indexPath)
            }
            dailyTable.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: .Top)
        }
    }
    
    // MARK: - Actions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let weekly = segue.destinationViewController as HistoryViewController
        weekly.todaily = todaily
        todaily?.delegate = nil
    }
    
    // MARK: - TimerRefreshDelegate
    
    func refreshLabel(time: String) {
        timerLabel.text = time
    }
    
    // MARK: - Helper

    func getDay(date: NSDate) -> String {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "EEE d MMM"
        let str = dateFormat.stringFromDate(date)
        
        return str
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
