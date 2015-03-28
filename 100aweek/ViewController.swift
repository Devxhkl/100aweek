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
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var todayPertageLabel: UILabel!
    @IBOutlet weak var weeklyLabel: UILabel!
    @IBOutlet weak var weeklyPertageLabel: UILabel!
    
    let customTransitionManager = WeeklyCustomTransition()
    var delegate: TimerRefreshDelegate?
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
    var progressView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.transitioningDelegate = customTransitionManager
        progressView = UIImageView(frame: CGRect(x: 0, y: 271, width: self.view.frame.width, height: 0))
        progressView.contentMode = .Bottom
        progressView.image = UIImage(named: "progress")
        progressView.clipsToBounds = true
    
        view.insertSubview(progressView, atIndex: 2)
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
            timeLabel.text = "0 : 00 : 00"
            pausedLabel.text = "0 : 00 : 00"
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
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
            
            startTime = NSDate.timeIntervalSinceReferenceDate()
            startDate = NSDate()
            
            startButton.hidden = true
            pauseButton.hidden = false
        case .Paused:
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updatePausedTime"), userInfo: nil, repeats: true)
            
            pauseTime = NSDate.timeIntervalSinceReferenceDate()
        case .Resumed:
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
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
        updateProgressView(elapsedTime)
        
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
            todayPertageLabel.textColor = UIColor.greenColor()
        }
        
        todayPertageLabel.text = "\(percentage) %"
    }
    
    func updateProgressView(time: NSTimeInterval) {
        let height = CGFloat(time) * 315 / (100 * 3600 / 7)
        
        progressView.frame = CGRect(x: 0, y: 271 - height, width: view.frame.width, height: height)
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
        
        let ret = TimeEntry.createInManagedObjectContext(managedObjectContext!, _startDate: startDate, _startTime: startTimeF, _endTime: endTimeF, _duration: durationTime, _activeTime: timeActive!, _pausedTime: timePaused!, _pauseCount: countOfPause)
        
        var error: NSError?
        if (managedObjectContext?.save(&error) != nil) {
            println(error?.localizedDescription)
        }
    }
}

