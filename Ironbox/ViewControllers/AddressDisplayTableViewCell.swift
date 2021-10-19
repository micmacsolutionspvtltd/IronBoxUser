//
//  AddressDisplayTableViewCell.swift
//  Ironbox
//
//  Created by Gopalsamy A on 31/03/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class AddressDisplayTableViewCell: UITableViewCell {

    @IBOutlet weak var lblAddressType: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblLandmark: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var viewDot: UIView!
    override func awakeFromNib() {
        super.awakeFromNib() 
        // Initialization code
    }

    override func layoutSubviews()
    {
        viewDot.layer.cornerRadius = viewDot.frame.size.height/2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
