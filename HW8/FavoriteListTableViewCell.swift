//
//  FavoriteListTableViewCell.swift
//  HW8
//
//  Created by 張任鋒 on 11/22/17.
//  Copyright © 2017 JFC. All rights reserved.
//

import UIKit

class FavoriteListTableViewCell: UITableViewCell {
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var change: UILabel!
    //favoriteListCellPro
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
