//
//  DailyTableViewController.swift
//  100aweek
//
//  Created by Zel Marko on 21/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class DailyTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DailyHeadDelegate {

    @IBOutlet weak var dailyTable: UITableView!
    
    var weekInfo = SectionInfo()
    var dayInfoArray = [DayInfo]()
    
    override func viewWillAppear(animated: Bool) {
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
        cell.startLabel.text = entry.startTime
        cell.endLabel.text = entry.endTime
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCellWithIdentifier("Header") as DailyHeaderCell
        header.frame = CGRect(x: header.frame.origin.x, y: header.frame.origin.y, width: dailyTable.frame.width, height: header.frame.height)
        header.delegate = self
        
        let dayInfo = dayInfoArray[section]
        
        header.dayLabel.text = getDay(dayInfo.timings[0].startDate)
        let active = dayInfo.timings[0].activeTime
        let activeArr = active.componentsSeparatedByString(" : ")
        header.rateLabel.text = dayInfo.getPercentage(dayInfo.timings[0].activeTime)
        header.section = section
        
        let view = UIView(frame: header.frame)
        view.addSubview(header)
        
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func openSection(sectionHeaderCell: DailyHeaderCell, section: Int) {
        
/*
        let entryCount = sectionInfo.timings.count
        var indexPathsToInsert = [NSIndexPath]()
        for var index = 0; index < entryCount; index++ {
            let indexPath = NSIndexPath(forRow: index, inSection: section)
            indexPathsToInsert.append(indexPath)
        }
        
        historyTable.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: .Top)*/
    }
    
    func closeSection(sectionHeaderCell: DailyHeaderCell, section: Int) {
        /*
        let sectionInfo = sectionInfoArray[section]
        sectionInfo.isOpen = false
        
        let entryCount = sectionInfo.timings.count
        if entryCount > 0 {
            var indexPathsToDelete = [NSIndexPath]()
            for var index = 0; index < entryCount; index++ {
                let indexPath = NSIndexPath(forRow: index, inSection: section)
                indexPathsToDelete.append(indexPath)
            }
            historyTable.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: .Top)
        }
*/
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Helper

    func getDay(date: NSDate) -> String {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "EEE d MMM"
        let str = dateFormat.stringFromDate(date)
        
        return str
    }

}
