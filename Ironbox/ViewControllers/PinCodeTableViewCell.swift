//
//  PinCodeTableViewCell.swift
//  Ironbox
//
//  Created by Gopalsamy A on 18/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class PinCodeTableViewCell: UITableViewCell {

    @IBOutlet weak var lblPincode: UILabel!
    @IBOutlet weak var imgRadio: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
