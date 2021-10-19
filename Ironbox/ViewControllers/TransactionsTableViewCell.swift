//
//  TransactionsTableViewCell.swift
//  Ironbox
//
//  Created by Gopalsamy A on 31/05/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class TransactionsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblOrderFor: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewType: GradientView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews()
    {
        viewBG.layer.cornerRadius = 5
        viewBG.clipsToBounds = true
        viewBG.layer.borderColor  =  UIColor.lightGray.cgColor
        viewBG.layer.borderWidth = 0.3
        viewBG.layer.shadowOpacity = 0.8
        viewBG.layer.shadowColor =  UIColor.darkGray.cgColor
        viewBG.layer.shadowRadius = 3.0
        viewBG.layer.shadowOffset = CGSize(width:0, height: 2)
        viewBG.layer.masksToBounds = false
        
        viewType.roundCorners([.topLeft, .bottomLeft], radius: 5)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure view for the selected View

       
    }
    
}
