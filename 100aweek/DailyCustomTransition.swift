//
//  DailyCustomTransition.swift
//  100aweek
//
//  Created by Zel Marko on 28/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class DailyCustomTransition: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
   
    let duration = 0.8
    var presenting = true
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        let weekly = presenting ? transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as HistoryViewController : transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as HistoryViewController
        let daily = presenting ? transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as DailyTableViewController : transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as DailyTableViewController
        
        let weeklyTable = weekly.historyTable!
        let weeklyTimeLabel = weekly.timerLabel!
        let weeklyBackButton = weekly.toMainButton!
        let wSelectedCell = weekly.selectedCell
        let expansionView = UIView(frame: CGRect(x: 0, y: weeklyBackButton.bounds.height + wSelectedCell.frame.origin.y, width: wSelectedCell.bounds.width, height: wSelectedCell.bounds.height))
        expansionView.backgroundColor = UIColor.whiteColor()
        if presenting {
            fromView.addSubview(expansionView)
        }
        

        let xScale = presenting ? fromView.bounds.width / expansionView.bounds.width : expansionView.bounds.width / fromView.bounds.width
        let yScale = presenting ? fromView.bounds.height / expansionView.bounds.height : expansionView.bounds.height / fromView.bounds.height
        let expansionTransform = presenting ? CGAffineTransformMakeScale(xScale, yScale) : CGAffineTransformIdentity
        
        let dailyTable = daily.dailyTable!
        let dailyTimer = daily.timerLabel!
        let dailyBack = daily.backButton!
        
        let dailyTableTransform = presenting ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, dailyTable.bounds.height)
        
        container.addSubview(toView)
        container.addSubview(fromView)
        
        UIView.animateWithDuration(duration, delay: 0, options: nil, animations: {
            expansionView.transform = expansionTransform
            expansionView.center = fromView.center
            
            
            }, completion: {_ in
                transitionContext.completeTransition(true)
                
                expansionView.removeFromSuperview()
                
                UIView.animateWithDuration(0.2, animations: {
                    //dailyTable.transform = dailyTableTransform
                    //dailyTable.hidden = false
                    
                })
                if self.presenting {
                    var index = 0
                    for sectionInfo in daily.dayInfoArray {
                        
                            sectionInfo.headerCell.transform = CGAffineTransformMakeTranslation(0, dailyTable.bounds.height)
                            sectionInfo.headerCell.hidden = true
                        
                        
                        UIView.animateWithDuration(0.4, delay: 0.05 * Double(index), usingSpringWithDamping: 0.9, initialSpringVelocity: 20, options: nil, animations: {
                            sectionInfo.headerCell.hidden = false
                            sectionInfo.headerCell.transform = self.presenting ? CGAffineTransformMakeTranslation(0, 0) : CGAffineTransformMakeTranslation(0, dailyTable.bounds.height)
                            }, completion: nil)
                        index++
                    }
                }
        })
        
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: nil, animations: {
            weeklyBackButton.transform = self.presenting ? CGAffineTransformMakeTranslation(0, -fromView.bounds.height) : CGAffineTransformIdentity
            weeklyTimeLabel.transform = self.presenting ? CGAffineTransformMakeTranslation(0, -fromView.bounds.height) : CGAffineTransformIdentity
            }, completion: nil)
       
        
            var hindex = 0
            for sectionInfo in weekly.sectionInfoArray {
                UIView.animateWithDuration(self.duration, delay: 0.05 * Double(hindex), usingSpringWithDamping: 0.9, initialSpringVelocity: 0.6, options: nil, animations: {
                    let head = sectionInfo.headerCell
                    //println(head.visibleView.frame)
                    if head.visibleView.frame.origin.y < wSelectedCell.frame.origin.y {
                        sectionInfo.headerCell.transform = self.presenting ? CGAffineTransformMakeTranslation(0, -(head.visibleView.bounds.height + head.visibleView.frame.origin.y + weeklyBackButton.bounds.height)) : CGAffineTransformIdentity
                        
                    }
                    else {
                        sectionInfo.headerCell.transform = self.presenting ? CGAffineTransformMakeTranslation(0, fromView.bounds.height - (weeklyBackButton.bounds.height + head.visibleView.frame.origin.y)) : CGAffineTransformIdentity
                    }
                    }, completion: nil)
                hindex++
            }
        
            var cindex = 0
            for c in weeklyTable.visibleCells() {
                let cell = c as TimingViewCell
                //println(cell.frame)
                
                
                UIView.animateWithDuration(self.duration, delay: 0.05 * Double(cindex), usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3, options: nil, animations: {
                    if cell.frame.origin.y < wSelectedCell.frame.origin.y && cell != wSelectedCell {
                        cell.transform = CGAffineTransformMakeTranslation(0, -(cell.bounds.height + cell.frame.origin.y + weeklyBackButton.bounds.height))
                    }
                    else if cell.frame.origin.y > wSelectedCell.frame.origin.y && cell != wSelectedCell {
                        cell.transform = CGAffineTransformMakeTranslation(0, weeklyTable.bounds.height - cell.frame.origin.y - cell.frame.height)
                        //println(fromView.bounds.height - weeklyBackButton.bounds.height + cell.frame.height)
                    }
                    
                }, completion: nil)
                cindex++
                //println(cell.frame)
            
            }/*
*/

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
