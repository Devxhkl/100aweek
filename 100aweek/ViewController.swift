//
//  ViewController.swift
//  100aweek
//
//  Created by Zel Marko on 18/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit
import CoreData

protocol TimerRefreshDelegate {
    func refreshLabel(time: String)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pausedLabel: UILabel!
    @IBOutlet weak var pointy: UIImageView!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var historyButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var todayPertageLabel: UILabel!
    @IBOutlet weak var weeklyLabel: UILabel!
    @IBOutlet weak var weeklyPertageLabel: UILabel!
    
    let customTransitionManager = WeeklyCustomTransition()
    var delegate: TimerRefreshDelegate?
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    var startDate = NSDate()
    var endDate = NSDate()
    var duration = NSTimeInterval()
    var startTime = NSTimeInterval()
    var pauseTime = NSTimeInterval()
    var savedTime = NSTimeInterval()
    var pausedTime = NSTimeInterval()
    var timer = NSTimer()
    var pauseCount = 0
    var paused = false
    var stopped = false
    var state = State.Stopped
    var locked = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
       updateWeeklyPercentageLabel(0)
    }

    // MARK: - Actions
    
    @IBAction func start(sender: AnyObject) {
        state = .Started
        stopped = false
        locked = true
        lockMechanism(locked)
        stopButton.setTitle("stop", forState: .Normal)
        
        startTimer()
    }
    
    @IBAction func pause(sender: AnyObject) {
        switch state {
        case .Started, .Resumed:
            timer.invalidate()
            pauseCount++
            
            state = .Paused
            paused = true
            pauseButton.setTitle("resume", forState: .Normal)
            
            startTimer()
        case .Paused:
            timer.invalidate()
            state = .Resumed
            pauseButton.setTitle("pause", forState: .Normal)
            
            startTimer()
        default:
            break
        }
    }
    
    @IBAction func stop(sender: AnyObject) {
        state = .Stopped
        if stopped {
            resetLabels()
            sender.setTitle("stop", forState: .Normal)
            stopped = false
        }
        else {
            timer.invalidate()
            endDate = NSDate()
            saveEntry()
            
            self.pauseButton.hidden = true
            self.startButton.hidden = false
            sender.setTitle("reset", forState: .Normal)
            
            paused = false
            stopped = true
            
            savedTime = 0
            pausedTime = 0
            pauseCount = 0
        }
    }
    
    @IBAction func lockUnlock(sender: AnyObject) {
        locked = !locked
        lockMechanism(locked)
    }
    
    func lockMechanism(lock: Bool) {
        if locked {
            stopButton.enabled = false
            lockButton.setTitle("unlock", forState: .Normal)
            lockButton.backgroundColor = UIColor.blackColor()
            lockButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }
        else {
            stopButton.enabled = true
            lockButton.setTitle("lock", forState: .Normal)
            lockButton.backgroundColor = UIColor.whiteColor()
            lockButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        }
    }
    
    @IBAction func historyTapped(sender: UIButton) {
    }
    
    @IBAction func settingsTapped(sender: UIButton) {
    }
    
    @IBAction func unwindToTimer(segue: UIStoryboardSegue) {
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let weekly = segue.destinationViewController as HistoryViewController
        weekly.todaily = self
        weekly.transitioningDelegate = customTransitionManager
    }

    // MARK: - Timers
    
    func startTimer() {
        switch state {
        case .Started:
            timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
            
            startTime = NSDate.timeIntervalSinceReferenceDate()
            startDate = NSDate()
            
            startButton.hidden = true
            pauseButton.hidden = false
        case .Paused:
            timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: Selector("updatePausedTime"), userInfo: nil, repeats: true)
            
            pauseTime = NSDate.timeIntervalSinceReferenceDate()
        case .Resumed:
            timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
        default:
            break
        }
    }
    
    func updateTime() {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime: NSTimeInterval = currentTime - startTime
        duration = elapsedTime
        
        elapsedTime -= pausedTime
        
        if paused {
            let dif = elapsedTime - savedTime
            pausedTime += dif
            elapsedTime -= pausedTime
            
            paused = false
        }
        savedTime = elapsedTime
        
        updatePercentageLabel(elapsedTime)
        updateWeeklyPercentageLabel(elapsedTime)
        
        if let dely = delegate {
            delegate?.refreshLabel(updateLabel(elapsedTime))
        }
        
        timeLabel.text = updateLabel(elapsedTime)
    }
    
    func updatePausedTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime: NSTimeInterval = currentTime - pauseTime
        
        elapsedTime += pausedTime
        
        pausedLabel.text = updateLabel(elapsedTime)
    }
    
    func updateLabel(tInterval: NSTimeInterval) -> String {
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
    
    func updatePercentageLabel(interval: NSTimeInterval) {
        let daily: CGFloat = (100 * 3600) / 7
        let intra = CGFloat(interval)
        let percentage = Int((intra / daily) * 100)
        if percentage >= 100 {
            todayPertageLabel.textColor = UIColor.yellowColor()
            todayLabel.textColor = UIColor.yellowColor()
        }
        
        todayPertageLabel.text = "\(percentage) %"
    }
    
    func updateWeeklyPercentageLabel(currentInterval: NSTimeInterval) {
        let fetchRequest = NSFetchRequest(entityName: "TimeEntry")
        let fetchResults = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as [TimeEntry]
        let helper = TimeHelperClass()
        
        let today = NSDate()
        var thisWeek = "0"
        if let lastDay = fetchResults.last {
            thisWeek = helper.getWeekOfYear(lastDay.startDate)
        }
        var weeksEntries = [TimeEntry]()
        for entry in fetchResults {
            if helper.getWeekOfYear(entry.startDate) == thisWeek && helper.getWeekOfYear(today) == thisWeek {
                weeksEntries.append(entry)
            }
        }
        var newWeek = true
        var weeklyToday = [String]()
        if weeksEntries.count > 0 {
            let times = helper.getSummedTimes(weeksEntries)
            let activeHoursArr = times[0].componentsSeparatedByString(" : ")
            newWeek = false
            
            let hours = Double(activeHoursArr[0].toInt()! * 3600)
            let minutes = Double(activeHoursArr[1].toInt()! * 60)
            let seconds = Double(activeHoursArr[2].toInt()!)
        
            weeklyToday = updateLabel(hours + minutes + seconds + currentInterval).componentsSeparatedByString(" : ")
        }
        
                
        if !newWeek && weeklyToday[0].toInt() >= 100 {
            weeklyPertageLabel.textColor = UIColor.yellowColor()
            weeklyLabel.textColor = UIColor.yellowColor()
        }
                
        weeklyPertageLabel.text = !newWeek ? "\(weeklyToday[0]) %" : "0 %"
    }
    
    func resetLabels() {
        let zero = "0 : 00 : 00"
        timeLabel.text = zero
        pausedLabel.text = zero
        
        let white = UIColor.whiteColor()
        todayLabel.textColor = white
        todayPertageLabel.textColor = white
        todayPertageLabel.text = "0 %"
    }
    
    enum State {
        case Started
        case Paused
        case Resumed
        case Stopped
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    
    // MARK: CoreData
    
    func saveEntry() {
        
        
        // Date Format
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "EEE d MMM"
        
        // Time Format
        let timeFormat = NSDateFormatter()
        timeFormat.dateFormat = "H:mm:ss"
        
        let startDateF = dateFormat.stringFromDate(startDate)
        let startTimeF = timeFormat.stringFromDate(startDate)
        let endTimeF = timeFormat.stringFromDate(endDate)
        
        let durationTime = updateLabel(duration)
        let timeActive = timeLabel.text
        let timePaused = pausedLabel.text
        let countOfPause = NSNumber(integer: pauseCount)
        
        if timeActive != "0 : 00 : 00" || timePaused != "0 : 00 : 00" {
            let ret = TimeEntry.createInManagedObjectContext(managedObjectContext!, _startDate: startDate, _startTime: startTimeF, _endTime: endTimeF, _duration: durationTime, _activeTime: timeActive!, _pausedTime: timePaused!, _pauseCount: countOfPause)
        
            var error: NSError?
            if (managedObjectContext?.save(&error) != nil) {
                println(error?.localizedDescription)

            }
        }
    }
}

