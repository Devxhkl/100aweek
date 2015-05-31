//
//  InitialViewController.swift
//  100aweek
//
//  Created by Zel Marko on 24/05/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var activeTimeLabel: UILabel!
    @IBOutlet weak var pausedTimeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var summaryTextViewPlaceholder: UILabel!
    @IBOutlet weak var summaryViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var todayPercentageLabel: UILabel!
    @IBOutlet weak var weeklyPercentageLabel: UILabel!
    
    let timers = Timers()
    let customTransitionManager = WeeklyCustomTransition()
    
    var fresh = true
    var locked = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if fresh {
            timers.backup()
            fresh = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "updateActiveTimeLabel:", name: "activeTimeLabelNotificationKey", object: nil)
        notificationCenter.addObserver(self, selector: "updatePauseTimeLabel:", name: "pauseTimeLabelNotificationKey", object: nil)
        notificationCenter.addObserver(self, selector: "updatePercentageLabel:", name: "percentageLabelNotificationKey", object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        summaryTextView.delegate = self
        summaryTextView.returnKeyType = .Done
        summaryViewBottomConstraint.constant = 0.0
    }
    
    @IBAction func start(sender: AnyObject) {
        timers.start()
        
        pauseButton.hidden = false
        locked = true
        lockMechanism(locked)
    }
    
    @IBAction func pause(sender: AnyObject) {
        timers.pause()
        
        pauseButton.hidden = true
        resumeButton.hidden = false
    }
    
    @IBAction func resume(sender: AnyObject) {
        timers.resume()
        
        pauseButton.hidden = false
    }
    
    @IBAction func stop(sender: AnyObject) {
        timers.stop()
        summaryView.hidden = false
    }
    
    @IBAction func lockUnlock(sender: AnyObject) {
        locked = !locked
        lockMechanism(locked)
    }
    
    @IBAction func done(sender: AnyObject) {
        timers.save(summaryTextView.text)
        
        startButton.hidden = false
        resumeButton.hidden = true
        pauseButton.hidden = true
        self.view.endEditing(true)
        summaryView.hidden = true
        summaryTextViewPlaceholder.hidden = false
    }
    
    @IBAction func unwindToTimer(segue: UIStoryboardSegue) {
    }
}

extension InitialViewController {
    
    func updateActiveTimeLabel(notification: NSNotification) {
        activeTimeLabel.text = notification.userInfo!["activeTime"] as? String
        
        if let changeTitle = notification.userInfo!["changeTitle"] as? Bool {
            startButton.hidden = true
            resumeButton.hidden = false
            locked = true
            lockMechanism(locked)
        }
    }
    
    func updatePauseTimeLabel(notification: NSNotification) {
        pausedTimeLabel.text = notification.userInfo!["pauseTime"] as? String
        
        if let changeTitle = notification.userInfo!["changeTitle"] as? Bool {
            startButton.hidden = true
            pauseButton.hidden = false
            locked = true
            lockMechanism(locked)
        }
    }
    
    func updatePercentageLabel(notification: NSNotification) {
        if let today = notification.userInfo!["today"] as? String {
            todayPercentageLabel.text = today
        }
        
        if let weekly = notification.userInfo!["weekly"] as? String {
            weeklyPercentageLabel.text = weekly
        }
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

    // MARK: - TO BE CLEANED!!!!
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        summaryViewBottomConstraint.constant = 0.0
        
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
            summaryViewBottomConstraint.constant = 0.0
            
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
                summaryViewBottomConstraint.constant = keyboardHeight
                UIView.animateWithDuration(0.25, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let weekly = segue.destinationViewController as! HistoryViewController
//        weekly.todaily = self
//        weekly.transitioningDelegate = customTransitionManager
    }

}
