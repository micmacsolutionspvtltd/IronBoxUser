//
//  BookingHistoryCell.swift
//  Ironbox
//
//  Created by MAC on 21/05/22.
//  Copyright © 2022 Gopalsamy A. All rights reserved.
//

import UIKit

class BookingHistoryCell: UITableViewCell {

    @IBOutlet weak var bookingDateLbl: UILabel!
    @IBOutlet weak var bookingIdLbl: UILabel!
    @IBOutlet weak var clothCountLbl: UILabel!
    @IBOutlet weak var creditPonitsLbl: UILabel!
    @IBOutlet weak var totalContentView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        totalContentView.applyShadowView(color: .black, radius: 3, cornerRadius: 5, alpha: 0.3)
    }
  
          
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
