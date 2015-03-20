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
    var dif = NSTimeInterval()
    var timer = NSTimer()
    var pauseCount = 0
    var paused = false
    var resumed = false
    var stopped = false
    var state = State.Stopped

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func start(sender: AnyObject) {
        state = .Started
        println("Start")
        startTimer()
        stopButton.setTitle("stop", forState: .Normal)
        stopped = false
    }
    
    @IBAction func pause(sender: AnyObject) {
        switch state {
        case .Started, .Resumed:
            timer.invalidate()
            pauseCount++
            state = .Paused
            println("Paused")
            paused = true
            startTimer()
            
            pauseButton.setTitle("resume", forState: .Normal)
        case .Paused:
            timer.invalidate()
            state = .Resumed
            println("Resumed")
            startTimer()
            
            pauseButton.setTitle("pause", forState: .Normal)
        default:
            println()
        }
    }
    
    @IBAction func stop(sender: AnyObject) {
        state = .Stopped
        if stopped {
            timeLabel.text = "00 : 00 : 00 : 00"
            pausedLabel.text = "00 : 00 : 00 : 00"
            sender.setTitle("stop", forState: .Normal)
            stopped = false
        }
        else {
            timer.invalidate()
            endDate = NSDate()
            saveEntry()
            savedTime = 0
            dif = 0
            pauseCount = 0
            self.pauseButton.hidden = true
            self.startButton.hidden = false
            sender.setTitle("reset", forState: .Normal)
            paused = false
            stopped = true
        }
                
    }
    
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
            println()
        }
    }
    
    func updateTime() {
        
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime: NSTimeInterval = currentTime - startTime
        duration = elapsedTime
        
        elapsedTime -= dif
        //println("Elapsed: \(elapsedTime), Saved: \(savedTime)")
        if paused {
            paused = false
            let difera = elapsedTime - savedTime
            dif += difera
            elapsedTime -= dif
            println(dif)
        }
        savedTime = elapsedTime
        
        timeLabel.text = updateLabel(elapsedTime)
    }
    
    func updatePausedTime() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime: NSTimeInterval = currentTime - pauseTime
        
        elapsedTime += dif
        
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
        
        let strHours = hours > 9 ? String(hours) : "0" + String(hours)
        let strMinutes = minutes > 9 ? String(minutes) : "0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds) : "0" + String(seconds)
        let strFraction = fraction > 9 ? String(fraction) : "0" + String(fraction)
        
        let time = "\(strHours) : \(strMinutes) : \(strSeconds) : \(strFraction)"
        return time
    }
    
    func saveEntry() {
        let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        let startDateForm = startDate
        let endDateForm = endDate
        let durationTime = updateLabel(duration)
        let timeActive = timeLabel.text
        let timePaused = pausedLabel.text
        let countOfPause = NSNumber(integer: pauseCount)
        
        let ret = TimeEntry.createInManagedObjectContext(managedObjectContext!, _startTime: startDateForm, _endTime: endDateForm, _duration: durationTime, _activeTime: timeActive!, _pausedTime: timePaused!, _pauseCount: countOfPause)
        println(ret)
        
        var error: NSError?
        if (managedObjectContext?.save(&error) != nil) {
            println(error?.localizedDescription)
        }
    }
    
    enum State {
        case Started
        case Paused
        case Resumed
        case Stopped
    }

    @IBAction func historyTapped(sender: UIButton) {
    }
    
    @IBAction func settingsTapped(sender: UIButton) {
    }
    
    @IBAction func unwindToTimer(segue: UIStoryboardSegue) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

