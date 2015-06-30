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
        
        dailyTable.estimatedRowHeight = 118.0
        dailyTable.rowHeight = UITableViewAutomaticDimension
        
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
            // Filter startDates to have only one of each day in the week
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
            // Sort dates Descending to show the latest day on the top
            startDates.sort({ $0.componentsSeparatedByString(" ")[1].toInt() > $1.componentsSeparatedByString(" ")[1].toInt() })
            
            for date in startDates {
                let dayInfo = DayInfo()
                dayInfo.isOpen = false
                
                for entry in weekInfo.timings {
                    let day = entry.startDate
                    let str = getDay(day)
                    
                    if str == date {
                        dayInfo.timing = entry
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
        
        return dayInfo.isOpen ? 1 : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! DailyViewCell

        let dayInfo = dayInfoArray[indexPath.section]
        let entry = dayInfo.timing
        
        cell.activeLabel.text = entry.activeTime
        cell.pausedLabel.text = entry.pausedTime
        cell.pausesLabel.text = "\(entry.pauseCount)"
        let startEndIndex = "\(entry.startTime.endIndex)"
        cell.startLabel.text = entry.startTime.substringToIndex(advance(entry.startTime.startIndex, startEndIndex.toInt()! - 3))
        let endEndIndex = "\(entry.endTime.endIndex)"
        cell.endLabel.text = entry.endTime.substringToIndex(advance(entry.endTime.startIndex, endEndIndex.toInt()! - 3))
        if let summaryText = entry.summary {
            cell.summaryLabel.text = summaryText
        }
        else {
            cell.summaryLabel.text = ""
            cell.summaryLabelButtomContraint.constant = 0.0
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCellWithIdentifier("Header") as! DailyHeaderCell
        header.frame = CGRect(x: header.frame.origin.x, y: header.frame.origin.y, width: dailyTable.frame.width, height: 85)
        header.delegate = self

        let dayInfo = dayInfoArray[section]
        
        let dayArr = getDay(dayInfo.timing.startDate).componentsSeparatedByString(" ")
        header.dayLabel.text = dayArr[0].lowercaseString
        header.dateLabel.text = dayArr[1] + " " + dayArr[2].lowercaseString
        let active = dayInfo.timing.activeTime
        let activeArr = active.componentsSeparatedByString(" : ")
        let dailySuccess = dayInfo.getPercentage(dayInfo.timing.activeTime)
        header.rateLabel.text = dailySuccess.percentage
        let succArr = dailySuccess.percentage.componentsSeparatedByString(" ")
        if dailySuccess.over {
            header.rateLabel.textColor = UIColor.greenColor()
        }
        else if succArr[0].toInt() >= 80 && succArr[0].toInt() < 100 {
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
        return 85
    }
    
    func openSection(sectionHeaderCell: DailyHeaderCell, section: Int) {
        let dayInfo = dayInfoArray[section]
        dayInfo.isOpen = true
        
        var indexPathsToInsert = [NSIndexPath]()
        
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        indexPathsToInsert.append(indexPath)
        
        dailyTable.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: .Top)
    }
    
    func closeSection(sectionHeaderCell: DailyHeaderCell, section: Int) {
        let dayInfo = dayInfoArray[section]
        dayInfo.isOpen = false
        
        var indexPathsToDelete = [NSIndexPath]()
        
        let indexPath = NSIndexPath(forRow: 0, inSection: section)
        indexPathsToDelete.append(indexPath)

        dailyTable.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: .Top)
    }
    
    // MARK: - Actions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let weekly = segue.destinationViewController as! HistoryViewController
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
