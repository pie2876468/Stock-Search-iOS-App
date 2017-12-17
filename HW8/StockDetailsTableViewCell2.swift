//
//  StockDetailsTableViewCell2.swift
//  HW8
//
//  Created by 張任鋒 on 11/23/17.
//  Copyright © 2017 JFC. All rights reserved.
//

import UIKit

class StockDetailsTableViewCell2: UITableViewCell {

    @IBOutlet weak var topic: UILabel!
    
    @IBOutlet weak var content: UILabel!
    
    @IBOutlet weak var arrow: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
