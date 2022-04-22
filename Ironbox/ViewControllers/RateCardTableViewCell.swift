//
//  RateCardTableViewCell.swift
//  Ironbox
//
//  Created by Gopalsamy A on 06/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class RateCardTableViewCell: UITableViewCell {

    @IBOutlet weak var btnCategoryPlusMinus: UIButton!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblExample: UILabel!
    @IBOutlet weak var viewDot: UIView!
    @IBOutlet fileprivate weak var collectionCategory: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews()
    {
        viewDot.layer.cornerRadius = viewDot.frame.size.height/2
        collectionCategory.layer.borderWidth = 1
        collectionCategory.layer.borderColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:1).cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension RateCardTableViewCell {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        collectionCategory.delegate = dataSourceDelegate
        collectionCategory.dataSource = dataSourceDelegate
        collectionCategory.tag = row
        collectionCategory.setContentOffset(collectionCategory.contentOffset, animated:false) // Stops collection view if it was scrolling.
        self.collectionCategory.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { collectionCategory.contentOffset.x = newValue }
        get { return collectionCategory.contentOffset.x }
    }
}

