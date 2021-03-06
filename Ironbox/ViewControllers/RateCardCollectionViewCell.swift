//
//  RateCardCollectionViewCell.swift
//  Ironbox
//
//  Created by Gopalsamy A on 19/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class RateCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var btnPlusMinus: UIButton!
    @IBOutlet weak var btnLabel: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnExtra: UIButton!
    @IBOutlet weak var viewBG: UIView!
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        indicatorView.layer.cornerRadius = indicatorView.frame.size.height / 2
    }
    override func layoutSubviews()
    {
        
    }
    
    
}
