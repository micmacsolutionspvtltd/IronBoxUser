//
//  OffersTableViewCell.swift
//  Ironbox
//
//  Created by Gopalsamy A on 15/05/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class ReferlistTableviewcell: UITableViewCell {

    @IBOutlet weak var imgReferimage: UIImageView!
    @IBOutlet weak var lblRefername: UILabel!
    @IBOutlet weak var lblReferdate: UILabel!
    @IBOutlet weak var lblReferused: UILabel!
    @IBOutlet weak var lblReferreceived: UILabel!
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
