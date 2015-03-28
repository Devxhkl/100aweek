//
//  WeeklyCustomTransition.swift
//  100aweek
//
//  Created by Zel Marko on 26/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class WeeklyCustomTransition: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
   
    let duration = 0.8
    var presenting = true
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        toView.backgroundColor = UIColor.blackColor()
        fromView.backgroundColor = UIColor.clearColor()
        
        let main = presenting ? transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as ViewController : transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as ViewController
        let history = presenting ? transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as HistoryViewController : transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as HistoryViewController
        
        let mainTimeLabel = main.timeLabel!
        let mainTLTransformer = presenting ? CGAffineTransformMakeTranslation(0, -(mainTimeLabel.frame.origin.y - 9)) : CGAffineTransformIdentity
        
        let pausedTimeLabel = main.pausedLabel!
        
        let todayMainLabel = main.todayLabel!
        let todayMLTransform = presenting ? CGAffineTransformMakeTranslation(-200, -200) : CGAffineTransformIdentity
        
        let todayPertageLabel = main.todayPertageLabel!
        let todatPLTransform = presenting ? CGAffineTransformMakeTranslation(-200, -200) : CGAffineTransformIdentity
        
        let weeklyMainLabel = main.weeklyLabel!
        let weeklyMLTransform = presenting ? CGAffineTransformMakeTranslation(200, -200) : CGAffineTransformIdentity
        
        let weeklyPertageLabel = main.weeklyPertageLabel!
        let weeklyPLTransform = presenting ? CGAffineTransformMakeTranslation(200, -200) : CGAffineTransformIdentity
        
        let pointy = main.pointy!
        let pointyTransformer = presenting ? CGAffineTransformMakeTranslation(0, -pointy.frame.origin.y * 2) : CGAffineTransformIdentity
        
        let progressView = main.progressView
        let progressVTransformation = presenting ? CGAffineTransformMakeTranslation(0, -progressView.bounds.origin.y * 2) : CGAffineTransformIdentity
        
        let historyTimeLabel = history.timerLabel!
        historyTimeLabel.hidden = true
        
        let startButton = main.startButton!
        let pauseButton = main.pauseButton!
        let stopButton = main.stopButton!
        let historyButton = main.historyButton!
        let settingsButton = main.settingsButton!
        
        let buttonLeftTransformation = presenting ? CGAffineTransformMakeTranslation(-startButton.frame.width, 0) : CGAffineTransformIdentity
        let buttonRightTransformation = presenting ? CGAffineTransformMakeTranslation(stopButton.frame.width, 0) : CGAffineTransformIdentity
        
        let weeklyTable = history.historyTable!
        let weeklyTTransformation = presenting ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, weeklyTable.frame.height)
        if presenting {
            weeklyTable.transform = CGAffineTransformMakeTranslation(0, weeklyTable.frame.height)
            weeklyTable.hidden = true
        }
        
        let xScaleFactor = presenting ? historyTimeLabel.frame.width / mainTimeLabel.frame.width : mainTimeLabel.frame.width / historyTimeLabel.frame.width
        let yScaleFactor = presenting ? historyTimeLabel.frame.height / mainTimeLabel.frame.height : mainTimeLabel.frame.height / historyTimeLabel.frame.height
        
        let scaleTransformer = CGAffineTransformScale(mainTLTransformer, xScaleFactor, yScaleFactor)
        
        
        
        container.addSubview(toView)
        container.addSubview(fromView)
        
        UIView.animateWithDuration(0.6, animations: {
            mainTimeLabel.transform = scaleTransformer
            mainTimeLabel.textColor = self.presenting ? UIColor.whiteColor() : UIColor.blackColor()
            
            todayMainLabel.transform = todayMLTransform
            todayPertageLabel.transform = todatPLTransform
            weeklyMainLabel.transform = weeklyMLTransform
            weeklyPertageLabel.transform = weeklyPLTransform
            
            pointy.transform = pointyTransformer
            pointy.alpha = self.presenting ? 0 : 1
            
            startButton.transform = buttonLeftTransformation
            pauseButton.transform = buttonLeftTransformation
            stopButton.transform = buttonRightTransformation
            historyButton.transform = buttonLeftTransformation
            settingsButton.transform = buttonRightTransformation
            
            if !self.presenting {
                var index = 0
                for sectionInfo in history.sectionInfoArray {
                    UIView.animateWithDuration(0.4, delay: 0.05 * Double(index), usingSpringWithDamping: 0.9, initialSpringVelocity: 20, options: nil, animations: {
                        sectionInfo.headerCell.transform = CGAffineTransformMakeTranslation(0, toView.bounds.height)
                        
                        }, completion: nil)
                    index++
                }
                weeklyTable.transform = weeklyTTransformation
            }
            
            }, completion: {_ in
                transitionContext.completeTransition(true)
                
                historyTimeLabel.hidden = false
                weeklyTable.hidden = true
                
                UIView.animateWithDuration(0.2, animations: {
                    weeklyTable.transform = weeklyTTransformation
                    weeklyTable.hidden = false

                })
                if self.presenting {
                    var index = 0
                    for sectionInfo in history.sectionInfoArray {
                        sectionInfo.headerCell.transform = CGAffineTransformMakeTranslation(0, toView.bounds.height)
                        sectionInfo.headerCell.hidden = true
                
                        UIView.animateWithDuration(0.4, delay: 0.05 * Double(index), usingSpringWithDamping: 0.9, initialSpringVelocity: 20, options: nil, animations: {
                            sectionInfo.headerCell.hidden = false
                            sectionInfo.headerCell.transform = CGAffineTransformMakeTranslation(0, 0)
                            }, completion: nil)
                        index++
                    }

                }
                
        })
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return duration
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.presenting = true
        
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.presenting = false
        
        return self
    }
    
    

    
    }
