//
//  ProjectsHeaderTableViewCell.swift
//  Swifty companion
//
//  Created by Mac Developer on 3/16/19.
//  Copyright © 2019 Viktoriia LIKHOTKINA. All rights reserved.
//

import UIKit

class ProjectsHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var projectSectionName: UILabel!
    
    func setExpanded() {
        statusButton.setImage(UIImage(named: "icons8-sort-down-filled-30"), for: .normal)
        statusButton.tintColor = #colorLiteral(red: 0.3236978054, green: 0.1063579395, blue: 0.574860394, alpha: 1)
    }
    
    func setCollapsed() {
        statusButton.setImage(UIImage(named: "icons8-sort-up-filled-30"), for: .normal)
        statusButton.tintColor = #colorLiteral(red: 0.3236978054, green: 0.1063579395, blue: 0.574860394, alpha: 1)
    }
}
