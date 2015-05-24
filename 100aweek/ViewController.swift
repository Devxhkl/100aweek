//
//  ViewController.swift
//  100aweek
//
//  Created by Zel Marko on 18/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit
import CoreData

// MARK: - TimerRefreshDelegate

protocol TimerRefreshDelegate {
    func refreshLabel(time: String)
}

class ViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Layout Constrains
    
    @IBOutlet weak var summaryViewButtomConstraint: NSLayoutConstraint!
    
    // MARK: - Label outlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pausedLabel: UILabel!
    @IBOutlet weak var pointy: UIImageView!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var todayPertageLabel: UILabel!
    @IBOutlet weak var weeklyLabel: UILabel!
    @IBOutlet weak var weeklyPertageLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var summaryTextViewPlaceholder: UILabel!

    // MARK: - Button outlets
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    
    // MARK: - Main Timer properties
    
//    var timer = NSTimer()
//    var startDate: NSDate!
//    var startTime = NSTimeInterval()
//    var pauseTime = NSTimeInterval()
//    var pausedTime = NSTimeInterval()
//    var pauseCount = 0
   
    // MARK: - Timer helpers
    
//    var savedTime = NSTimeInterval()
//    var endDate = NSDate()
//    var duration = NSTimeInterval()
//    var paused = false
//    var stopped = false
//    var state = State.Stopped
    var locked = false
    var killed = true
//    let intra = Reachability.isConnectedToNetwork()
    
    // MARK: - Delegates, Managers, Contexts,...
    
    let timers = Timers()
    
    let customTransitionManager = WeeklyCustomTransition()
    var delegate: TimerRefreshDelegate?
//    var backupManager = BackupManager()
//    var offlineBackupManager = OfflineBackupManager()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // MARK: - ViewController functions
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        summaryView.hidden = true
        
        if killed {
            timers.backup()
            killed = false
        }
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "updateActiveTimeLabel:", name: "activeTimeLabelNotificationKey", object: nil)
        notificationCenter.addObserver(self, selector: "updatePauseTimeLabel:", name: "pauseTimeLabelNotificationKey", object: nil)

//        if killed {
//            
//            timers.backup()
//            killed = false
//            
//            self.offlineBackupManager = self.offlineBackupManager.getBackupManager()
//            
//            if self.offlineBackupManager.date != nil {
//                let idFormat = NSDateFormatter()
//                idFormat.dateFormat = "yyyyMMdd"
//                
//                let today = NSDate()
//                let todayID = idFormat.stringFromDate(today)
//                let backupID = idFormat.stringFromDate(offlineBackupManager.date)
//                
//                if todayID == backupID {
//                    self.startDate = self.offlineBackupManager.date
//                    self.startTime = self.offlineBackupManager.start
//                    self.pausedTime = self.offlineBackupManager.paused
//                    self.pauseCount = self.offlineBackupManager.pauses
//                    self.pauseTime = self.offlineBackupManager.pauseTime
//                    println("ViewController, offlineBackupManager pause: \(self.offlineBackupManager.pause)")
//                    
//                    if self.offlineBackupManager.pause == true {
//                        self.updatePausedTime()
//                        self.updateTime()
//
//                        state = .Paused
//                        paused = true
//                        pauseButton.setTitle("resume", forState: .Normal)
////                        println("pausedTime: \(self.pausedTime)")
//                        
//                        startTimer()
//                    }
//                    else {
//                        self.updateTime()
//                        self.pausedLabel.text = updateLabel(self.pausedTime)
//                    }
//
//                }
//            }
//        }
        
//        if killed && intra {
//            self.backupManager = self.backupManager.getBackupFromBase()
//            
//            if self.backupManager.date != nil {
//                let idFormat = NSDateFormatter()
//                idFormat.dateFormat = "yyyyMMdd"
//            
//                let today = NSDate()
//                
//                let todayID = idFormat.stringFromDate(today)
//                let backupID = idFormat.stringFromDate(self.backupManager.date)
//            
//                if todayID == backupID {
//                    self.startDate = self.backupManager.date
//                    self.startTime = self.backupManager.time
//                    self.pausedTime = self.backupManager.pauseTime
//                    self.pauseCount = self.backupManager.pausedCount
//                    
//                    self.updateTime()
//                    self.pausedLabel.text = updateLabel(self.pausedTime)
//                }
//            }
//        }
//        updateWeeklyPercentageLabel(0)
        summaryTextView.delegate = self
        summaryTextView.returnKeyType = .Done
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        summaryViewButtomConstraint.constant = 0.0
    }

    // MARK: - Actions
    
    @IBAction func start(sender: AnyObject) {
        timers.start()
//        state = .Started
//        if stopped {
//            resetLabels()
//        }
//        stopped = false
//        locked = true
//        lockMechanism(locked)
//        stopButton.setTitle("stop", forState: .Normal)
//        
//        startTimer()
    }
    
    @IBAction func pause(sender: AnyObject) {
        timers.pause()
//        switch state {
//        case .Started, .Resumed:
//            timer.invalidate()
//            pauseCount++
//            
//            state = .Paused
//            paused = true
//            pauseButton.setTitle("resume", forState: .Normal)
//            
//            startTimer()
//            
//            
//        case .Paused:
//            timer.invalidate()
//            state = .Resumed
//            pauseButton.setTitle("pause", forState: .Normal)
//            
//            startTimer()
//        default:
//            break
//        }
    }
    
    @IBAction func stop(sender: AnyObject) {
//        state = .Stopped
//        if stopped {
//            resetLabels()
//            sender.setTitle("stop", forState: .Normal)
//            stopped = false
//        }
//        else {
//            summaryView.hidden = false
//            timer.invalidate()
//            endDate = NSDate()
//            
//            
//            self.pauseButton.hidden = true
//            self.startButton.hidden = false
//            sender.setTitle("reset", forState: .Normal)
//            pauseButton.setTitle("pause", forState: .Normal)
//            
//            paused = false
//            stopped = true
//            
//            savedTime = 0
//            pausedTime = 0
//            pauseCount = 0
//        }
    }
    
    @IBAction func dailySummaryDone(sender: AnyObject) {
        saveEntry()
        
        self.view.endEditing(true)
        summaryView.hidden = true
        summaryTextViewPlaceholder.hidden = false
    }
    
    @IBAction func lockUnlock(sender: AnyObject) {
        locked = !locked
        lockMechanism(locked)
    }
    
    func lockMechanism(lock: Bool) {
        if locked {
            stopButton.enabled = false
            lockButton.setTitle("u/lock", forState: .Normal)
            lockButton.backgroundColor = UIColor.blackColor()
            lockButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }
        else {
            stopButton.enabled = true
            lockButton.setTitle("|lock", forState: .Normal)
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
    
    func updateActiveTimeLabel(notification: NSNotification) {
        timeLabel.text = notification.userInfo!["activeTime"] as? String
    }
    
    func updatePauseTimeLabel(notification: NSNotification) {
        pausedLabel.text = notification.userInfo!["pauseTime"] as? String
    }


    // MARK: - Timers
    
//    func startTimer() {
//        switch state {
//        case .Started:
//            timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
//            
//            // If startTime is nil, we set the startTime to now, otherwise startTime is set from backup.
//            if startTime == 0 {
//                startTime = NSDate.timeIntervalSinceReferenceDate()
//                startDate = NSDate()
////                if intra {
////                    backupManager.createInitialBackup(startDate)
////                }
//                offlineBackupManager.createInitialBackup(startDate)
//            }
//            
//            startButton.hidden = true
//            pauseButton.hidden = false
//        case .Paused:
//            timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: Selector("updatePausedTime"), userInfo: nil, repeats: true)
//            
//            pauseTime = NSDate.timeIntervalSinceReferenceDate()
//            offlineBackupManager.updateBackupFromActive(startDate, pauseTime: pauseTime)
//            
//        case .Resumed:
//            timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
//        default:
//            break
//        }
//    }
//    
//    func updateTime() {
//        // Get current time and subtract it from startTime to get the time difference.
//        var currentTime = NSDate.timeIntervalSinceReferenceDate()
//        var elapsedTime: NSTimeInterval = currentTime - startTime
//        duration = elapsedTime
//        
//        elapsedTime -= pausedTime
//        
//        if paused {
//            let dif = elapsedTime - savedTime
//            pausedTime += dif
//            elapsedTime = savedTime
//            
////            if intra {
////                backupManager.updateBackupFromPause(startDate, pausedTime: pausedTime, pauseCount: pauseCount)
////            }
//            offlineBackupManager.updateBackupFromPause(startDate, pausedTime: pausedTime, pauseCount: pauseCount)
//            
//            paused = false
//        }
//        savedTime = elapsedTime
//        
//        updatePercentageLabel(elapsedTime)
//        updateWeeklyPercentageLabel(elapsedTime)
//        
//        if let dely = delegate {
//            delegate?.refreshLabel(updateLabel(elapsedTime))
//        }
//        
//        timeLabel.text = updateLabel(elapsedTime)
//    }
//    
//    func updatePausedTime() {
////        println("updatePausedTime, PAUSED: \(paused)")
//        let currentTime = NSDate.timeIntervalSinceReferenceDate()
//        var elapsedTime: NSTimeInterval = currentTime - pauseTime
//        
//        elapsedTime += pausedTime
//        
//        pausedLabel.text = updateLabel(elapsedTime)
//    }
//    
//    func updateLabel(tInterval: NSTimeInterval) -> String {
//        var interval = tInterval
//        
//        let hours = Int(interval / 3600.0)
//        interval -= NSTimeInterval(hours) * 3600
//        
//        let minutes = Int(interval / 60.0)
//        interval -= NSTimeInterval(minutes) * 60
//        
//        let seconds = Int(interval)
//        interval -= NSTimeInterval(seconds)
//        
//        let strMinutes = minutes > 9 ? String(minutes) : "0" + String(minutes)
//        let strSeconds = seconds > 9 ? String(seconds) : "0" + String(seconds)
//        
//        let time = "\(hours) : \(strMinutes) : \(strSeconds)"
//        return time
//    }
//    
//    func updatePercentageLabel(interval: NSTimeInterval) {
//        let daily: CGFloat = (100 * 3600) / 7
//        let intra = CGFloat(interval)
//        let percentage = Int((intra / daily) * 100)
//        if percentage >= 100 {
//            todayPertageLabel.textColor = UIColor.yellowColor()
//            todayLabel.textColor = UIColor.yellowColor()
//        }
//        
//        todayPertageLabel.text = "\(percentage) %"
//    }
//    
//    func updateWeeklyPercentageLabel(currentInterval: NSTimeInterval) {
//        let fetchRequest = NSFetchRequest(entityName: "TimeEntry")
//        let fetchResults = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as! [TimeEntry]
//        let helper = TimeHelperClass()
//        
//        let today = NSDate()
//        var thisWeek = "0"
//        if let lastDay = fetchResults.last {
//            thisWeek = helper.getWeekOfYear(lastDay.startDate)
//        }
//        var weeksEntries = [TimeEntry]()
//        for entry in fetchResults {
//            if helper.getWeekOfYear(entry.startDate) == thisWeek && helper.getWeekOfYear(today) == thisWeek {
//                weeksEntries.append(entry)
//            }
//        }
//        var newWeek = true
//        var weeklyToday = [String]()
//        if weeksEntries.count > 0 {
//            let times = helper.getSummedTimes(weeksEntries)
//            let activeHoursArr = times[0].componentsSeparatedByString(" : ")
//            newWeek = false
//            
//            let hours = Double(activeHoursArr[0].toInt()! * 3600)
//            let minutes = Double(activeHoursArr[1].toInt()! * 60)
//            let seconds = Double(activeHoursArr[2].toInt()!)
//        
//            weeklyToday = updateLabel(hours + minutes + seconds + currentInterval).componentsSeparatedByString(" : ")
//        }
//        
//                
//        if !newWeek && weeklyToday[0].toInt() >= 100 {
//            weeklyPertageLabel.textColor = UIColor.yellowColor()
//            weeklyLabel.textColor = UIColor.yellowColor()
//        }
//                
//        weeklyPertageLabel.text = !newWeek ? "\(weeklyToday[0]) %" : "0 %"
//    }
//    
//    func resetLabels() {
//        let zero = "0 : 00 : 00"
//        timeLabel.text = zero
//        pausedLabel.text = zero
//        
//        let white = UIColor.whiteColor()
//        todayLabel.textColor = white
//        todayPertageLabel.textColor = white
//        todayPertageLabel.text = "0 %"
//    }
//    
//    enum State {
//        case Started
//        case Paused
//        case Resumed
//        case Stopped
//    }
    
    // MARK: - Settings
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let weekly = segue.destinationViewController as! HistoryViewController
        weekly.todaily = self
        weekly.transitioningDelegate = customTransitionManager
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        summaryViewButtomConstraint.constant = 0.0
        
        UIView.animateWithDuration(0.25, animations: {
            self.view.layoutIfNeeded()
        })
        
        if summaryTextView.text == "" {
            summaryTextViewPlaceholder.hidden = false
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            summaryViewButtomConstraint.constant = 0.0
            
            UIView.animateWithDuration(0.25, animations: {
                self.view.layoutIfNeeded()
            })
            
            if textView.text == "" {
                summaryTextViewPlaceholder.hidden = false
            }
        }
        
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        summaryTextViewPlaceholder.hidden = true
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                summaryViewButtomConstraint.constant = keyboardHeight
                UIView.animateWithDuration(0.25, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    // MARK: - CoreData
    
    func saveEntry() {
        
//        let timeActive = timeLabel.text
//        let timePaused = pausedLabel.text
//        
//        if /*timeActive != "0 : 00 : 00" || timePaused != "0 : 00 : 00"*/ startDate != nil {
//            //summaryView.hidden = false
//            // Date Format
//            let dateFormat = NSDateFormatter()
//            dateFormat.dateFormat = "EEE d MMM"
//        
//            // Time Format
//            let timeFormat = NSDateFormatter()
//            timeFormat.dateFormat = "H:mm:ss"
//        
//            let startDateF = dateFormat.stringFromDate(startDate)
//            let startTimeF = timeFormat.stringFromDate(startDate)
//            let endTimeF = timeFormat.stringFromDate(endDate)
//        
//            let durationTime = updateLabel(duration)
//        
//            let countOfPause = NSNumber(integer: pauseCount)
//            let summary = summaryTextView.text
////            println(summary)
//        
//        
//            let ret = TimeEntry.createInManagedObjectContext(managedObjectContext!, _startDate: startDate, _startTime: startTimeF, _endTime: endTimeF, _activeTime: timeActive!, _pausedTime: timePaused!, _pauseCount: countOfPause, _summary: summary)
//        
//            var error: NSError?
//            if (managedObjectContext?.save(&error) != nil) {
//                println(error?.localizedDescription)
//
//            }
//        }
//        else {
//            let alert = UIAlertView(title: "No entry to save", message: "You have to start a session to save it", delegate: self, cancelButtonTitle: "Alright")
//            alert.show()
//        }
//        if intra {
////            backupManager.deleteBackup()
//        }
//        
//        backupManager = BackupManager()
//        startDate = nil
//        startTime = 0
//        pauseTime = 0
        
    }
}

