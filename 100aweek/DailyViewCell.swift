//
//  DailyViewCell.swift
//  100aweek
//
//  Created by Zel Marko on 21/03/15.
//  Copyright (c) 2015 Zel Marko. All rights reserved.
//

import UIKit

class DailyViewCell: UITableViewCell {

    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var pausedLabel: UILabel!
    @IBOutlet weak var pausesLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
