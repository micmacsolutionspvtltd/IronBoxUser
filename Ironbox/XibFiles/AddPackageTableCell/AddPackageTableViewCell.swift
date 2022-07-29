//
//  AddPackageTableViewCell.swift
//  Ironbox
//
//  Created by MAC on 20/04/22.
//  Copyright © 2022 Gopalsamy A. All rights reserved.
//

import UIKit

class AddPackageTableViewCell: UITableViewCell {

    @IBOutlet weak var buyNowView: UIView!
    @IBOutlet weak var packageAmtLbl: UILabel!
    @IBOutlet weak var expiryDateLbl: UILabel!
    @IBOutlet weak var packageNameLbl: UILabel!
    @IBOutlet weak var buyNowBtn: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    class var identifier: String
      {
          return String(describing: self)
      }
      
      class var nib: UINib
      {
          return UINib(nibName: identifier, bundle: nil)
      }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
