//
//  PayInfoTableViewCell.swift
//  fespay
//
//  Created by KakimotoShizuka on 2017/04/29.
//  Copyright © 2017年 KakimotoShizuka. All rights reserved.
//

import UIKit

class PayInfoTableViewCell: UITableViewCell {

    //MARK: Properties
    
    @IBOutlet weak var paidAtLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var payerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
