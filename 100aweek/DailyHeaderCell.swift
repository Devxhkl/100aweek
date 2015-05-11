//
//  DailyHeaderCell.swift
//  100aweek
//
//  Created by Zel Marko on 21/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

protocol DailyHeadDelegate {
    func openSection(sectionHeaderCell: DailyHeaderCell, section: Int)
    func closeSection(sectionHeaderCell: DailyHeaderCell, section: Int)
}

class DailyHeaderCell: UITableViewCell, UIGestureRecognizerDelegate {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    
    var isOpen = false
    var delegate: DailyHeadDelegate?
    var section: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let openCloseGesture = UITapGestureRecognizer(target: self, action: Selector("openCloseSection:"))
        openCloseGesture.delegate = self
        
        self.addGestureRecognizer(openCloseGesture)
    }
    
    func openCloseSection(opened: Bool) {
        if isOpen {
            delegate?.closeSection(self, section: section)
            isOpen = !isOpen
        }
        else {
            delegate?.openSection(self, section: section)
            isOpen = !isOpen
        }
    }
}
