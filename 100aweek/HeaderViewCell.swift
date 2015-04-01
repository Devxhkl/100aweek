//
//  HeaderViewCell.swift
//  100aweek
//
//  Created by Zel Marko on 20/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

protocol HeaderCellDelegate {
    func openSection(sectionHeaderCell: HeaderViewCell, section: Int)
    func closeSection(sectionHeaderCell: HeaderViewCell, section: Int)
}

class HeaderViewCell: UITableViewCell, UIGestureRecognizerDelegate {

    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
   
    var isOpen = false
    var delegate: HeaderCellDelegate?
    var visibleView: UIView!
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
