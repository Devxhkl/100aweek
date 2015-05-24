//
//  InitialViewController.swift
//  100aweek
//
//  Created by Zel Marko on 24/05/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var activeTimeLabel: UILabel!
    @IBOutlet weak var pausedTimeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var summaryView: UIView!
    
    let timers = Timers()
    
    var fresh = true
    
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
    }
    
    @IBAction func start(sender: AnyObject) {
        timers.start()
        
        pauseButton.hidden = false
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
//        timers.stop()
        
    }
}

extension InitialViewController {
    
    func updateActiveTimeLabel(notification: NSNotification) {
        activeTimeLabel.text = notification.userInfo!["activeTime"] as? String
        
        if let changeTitle = notification.userInfo!["changeTitle"] as? Bool {
            startButton.hidden = true
            resumeButton.hidden = false
        }
    }
    
    func updatePauseTimeLabel(notification: NSNotification) {
        pausedTimeLabel.text = notification.userInfo!["pauseTime"] as? String
        
        if let changeTitle = notification.userInfo!["changeTitle"] as? Bool {
            startButton.hidden = true
            pauseButton.hidden = false
        }
    }

}
