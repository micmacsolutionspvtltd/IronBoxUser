//
//  MySubscriptionsTableViewCell.swift
//  Ironbox
//
//  Created by Gopalsamy A on 21/06/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class MySubscriptionsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblRatePerCloth: UILabel!
    @IBOutlet weak var lblTotalClothes: UILabel!
    @IBOutlet weak var lblBalanceClothes: UILabel!
    @IBOutlet weak var lblOriginalRate: UILabel!
    @IBOutlet weak var lblPackageDetail: UILabel!
    @IBOutlet weak var lblExpiry: UILabel!
    @IBOutlet weak var viewBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews()
    {
        viewBG.layer.cornerRadius = 2
        viewBG.clipsToBounds = true
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
