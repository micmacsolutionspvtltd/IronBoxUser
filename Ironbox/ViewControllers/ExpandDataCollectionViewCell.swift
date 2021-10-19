//
//  ExpandDataCollectionViewCell.swift
//  HawkerBells
//
//  Created by Mac on 14/06/17.
//  Copyright © 2017 Pyramidions Solution. All rights reserved.
//

import UIKit

class ExpandDataCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var viewDot: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func layoutSubviews()
    {
        viewDot.layer.cornerRadius = viewDot.frame.size.height/2
    }
    
    
}
