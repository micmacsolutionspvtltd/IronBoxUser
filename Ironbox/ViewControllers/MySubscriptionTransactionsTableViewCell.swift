//
//  MySubscriptionTransactionsTableViewCell.swift
//  Ironbox
//
//  Created by Gopalsamy A on 22/06/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class MySubscriptionTransactionsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblBookingID: UILabel!
    @IBOutlet weak var lblTotalClothes: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
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
