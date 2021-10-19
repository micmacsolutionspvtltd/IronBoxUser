//
//  OffersTableViewCell.swift
//  Ironbox
//
//  Created by Gopalsamy A on 15/05/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class OffersTableViewCell: UITableViewCell {

    @IBOutlet weak var imgOffer: UIImageView!
    @IBOutlet weak var lblOfferName: UILabel!
    @IBOutlet weak var lblOfferCode: UILabel!
    @IBOutlet weak var lblOfferValidity: UILabel!
    @IBOutlet weak var viewCard: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews()
    {
        viewCard.layer.cornerRadius = 5
        viewCard.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
