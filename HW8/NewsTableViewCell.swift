//
//  NewsTableViewCell.swift
//  HW8
//
//  Created by 張任鋒 on 11/21/17.
//  Copyright © 2017 JFC. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var Title: UILabel!
    @IBOutlet weak var Author: UILabel!
    @IBOutlet weak var Date: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //print(Title?.text)
        // Configure the view for the selected state
    }

}
