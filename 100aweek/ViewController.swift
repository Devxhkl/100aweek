//
//  ViewController.swift
//  100aweek
//
//  Created by Zel Marko on 18/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pausedLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - Actions
    
    @IBAction func start(sender: AnyObject) {
        state = .Started
        stopped = false
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
            timeLabel.text = "0 : 00 : 00 : 00"
            pausedLabel.text = "0 : 00 : 00 : 00"
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
    
    @IBAction func historyTapped(sender: UIButton) {
    }
    
    @IBAction func settingsTapped(sender: UIButton) {
    }
    
    @IBAction func unwindToTimer(segue: UIStoryboardSegue) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Timers
    
    func startTimer() {
        switch state {
        case .Started:
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
            
            startTime = NSDate.timeIntervalSinceReferenceDate()
            startDate = NSDate()
            
            startButton.hidden = true
            pauseButton.hidden = false
        case .Paused:
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("updatePausedTime"), userInfo: nil, repeats: true)
            
            pauseTime = NSDate.timeIntervalSinceReferenceDate()
        case .Resumed:
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
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
        
        let fraction = Int(interval * 100)
        
        let strHours = hours > 9 ? String(hours) : String(hours)
        let strMinutes = minutes > 9 ? String(minutes) : "0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds) : "0" + String(seconds)
        let strFraction = fraction > 9 ? String(fraction) : "0" + String(fraction)
        
        let time = "\(strHours) : \(strMinutes) : \(strSeconds) : \(strFraction)"
        return time
    }
    
    enum State {
        case Started
        case Paused
        case Resumed
        case Stopped
    }

    
    // MARK: CoreData
    
    func saveEntry() {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        
        // Date Format
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "EEE d MMM, yy"
        
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
        
        let ret = TimeEntry.createInManagedObjectContext(managedObjectContext!, _startDate: startDateF, _startTime: startTimeF, _endTime: endTimeF, _duration: durationTime, _activeTime: timeActive!, _pausedTime: timePaused!, _pauseCount: countOfPause)
        
        var error: NSError?
        if (managedObjectContext?.save(&error) != nil) {
            println(error?.localizedDescription)
        }
    }
}

