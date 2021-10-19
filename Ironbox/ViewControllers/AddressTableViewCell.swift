//
//  AddressTableViewCell.swift
//  Ironbox
//
//  Created by Gopalsamy A on 28/03/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {

    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblLandmark: UILabel!
    @IBOutlet weak var lblCountru: UILabel!
    
    @IBOutlet weak var imgRadio: UIImageView!
    @IBOutlet weak var viewLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
