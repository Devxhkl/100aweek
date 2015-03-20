//
//  HistoryViewController.swift
//  100aweek
//
//  Created by Zel Marko on 19/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var historyTable: UITableView!
    
    var timings = [TimeEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

            }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "TimeEntry")
        
        let fetchResults = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as? [TimeEntry]
        println(fetchResults)
        
        timings = fetchResults!

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as TimingViewCell
        
        let entry = timings[indexPath.row]
        
        cell.startTimeLabel.text = "\(entry.startTime)"
        cell.endTimeLabel.text = "\(entry.endTime)"
        cell.activeTimeLabel.text = entry.activeTime
        cell.pausedTimeLabel.text = entry.pausedTime
        cell.durationTimeLabel.text = entry.duration
        cell.pausesCountLabel.text = "\(entry.pauseCount)"
        
        return cell
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
