//
//  ApplyOffersTableViewCell.swift
//  Ironbox
//
//  Created by Gopalsamy A on 04/06/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class ApplyOffersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgOffer: UIImageView!
    @IBOutlet weak var lblOfferName: UILabel!
    @IBOutlet weak var lblOfferCode: UILabel!
    @IBOutlet weak var lblOfferValidity: UILabel!
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var btnApply: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews()
    {
        viewCard.layer.cornerRadius = 5
        viewCard.clipsToBounds = true
        
        btnApply.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnApply.backgroundColor = UIColor.white
        btnApply.layer.borderWidth = 1
        btnApply.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnApply.layer.masksToBounds = false
        btnApply.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnApply.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnApply.layer.shadowOpacity = 0.2
        btnApply.layer.cornerRadius = 4
        btnApply.clipsToBounds = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state

       
    }
    
}
