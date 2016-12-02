//
//  CustomCell.swift
//  Diederick-Calkoen-pset5
//
//  Created by Diederick Calkoen on 29/11/16.
//  Copyright © 2016 Diederick Calkoen. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var detialToDoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
