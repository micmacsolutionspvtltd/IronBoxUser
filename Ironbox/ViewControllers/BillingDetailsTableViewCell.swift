//
//  BillingDetailsTableViewCell.swift
//  Ironbox
//
//  Created by Gopalsamy A on 24/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class BillingDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var btnCategoryPlusMinus: UIButton!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblIsPackage: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblExample: UILabel!
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
