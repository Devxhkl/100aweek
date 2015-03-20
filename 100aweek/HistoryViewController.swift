//
//  HistoryViewController.swift
//  100aweek
//
//  Created by Zel Marko on 19/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HeaderCellDelegate {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var historyTable: UITableView!
    
    var sectionInfoArray = [SectionInfo]()
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if sectionInfoArray.count == 0 || sectionInfoArray.count != self.numberOfSectionsInTableView(historyTable) {
            let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        
            let fetchRequest = NSFetchRequest(entityName: "TimeEntry")
            let fetchResults = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as? [TimeEntry]
        
            let fetched = fetchResults!
            
            var startDates = [String]()
            for entry in fetched {
                let date = entry.startDate
                startDates.append(date)
            }
            for date in startDates {
                var filter = Dictionary<String, Int>()
                var len = startDates.count
                for var index = 0; index < len; ++index {
                    var value = startDates[index]
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
                let sectionInfo = SectionInfo()
                sectionInfo.isOpen = false
                
                for entry in fetched {
                    if entry.startDate == date {
                        sectionInfo.timings.append(entry)
                    }
                }
                sectionInfoArray.append(sectionInfo)
            }
        }
        
    }
    
    // MARK: - TableView Stuff
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionInfoArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = sectionInfoArray[section]
        let entryCount = sectionInfo.timings.count
        
        return sectionInfo.isOpen ? entryCount : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as TimingViewCell
        
        let sectionInfo = sectionInfoArray[indexPath.section]
        let entry = sectionInfo.timings[indexPath.row]
        
        cell.startTimeLabel.text = "\(entry.startTime)"
        cell.endTimeLabel.text = "\(entry.endTime)"
        cell.activeTimeLabel.text = entry.activeTime
        cell.pausedTimeLabel.text = entry.pausedTime
        cell.durationTimeLabel.text = entry.duration
        cell.pausesCountLabel.text = "\(entry.pauseCount)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCellWithIdentifier("Header") as HeaderViewCell
        header.frame = CGRect(x: header.frame.origin.x, y: header.frame.origin.y, width: historyTable.frame.width, height: header.frame.height)
        
        header.delegate = self
        
        let sectionInfo = sectionInfoArray[section]
        sectionInfo.headerCell = header
        
        header.dateLabel.text = sectionInfo.timings[0].startDate
        header.durationLabel.text = sectionInfo.timings[0].duration
        header.section = section
        
        let view = UIView(frame: header.frame)
        view.addSubview(header)
        
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func openSection(sectionHeaderCell: HeaderViewCell, section: Int) {
        let sectionInfo = sectionInfoArray[section]
        sectionInfo.isOpen = true
        
        let entryCount = sectionInfo.timings.count
        var indexPathsToInsert = [NSIndexPath]()
        for var index = 0; index < entryCount; index++ {
            let indexPath = NSIndexPath(forRow: index, inSection: section)
            indexPathsToInsert.append(indexPath)
        }
        
        historyTable.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: .Top)
    }
    
    func closeSection(sectionHeaderCell: HeaderViewCell, section: Int) {
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
    }
}
