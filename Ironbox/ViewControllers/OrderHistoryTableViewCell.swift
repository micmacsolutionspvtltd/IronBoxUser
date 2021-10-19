//
//  OrderHistoryTableViewCell.swift
//  Ironbox
//
//  Created by Gopalsamy A on 07/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class OrderHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblBookingId: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblTimeSlot: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var imgStatusIcon: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPaymentMode: UILabel!
    @IBOutlet weak var viewDetails: UIView!
    @IBOutlet weak var viewDetailsWithColor: GradientView!
    @IBOutlet weak var viewBG: UIView!
    
    @IBOutlet weak var viewTracking: UIView!
    @IBOutlet weak var viewOrderConfirmed: UIView!
    @IBOutlet weak var viewOnTheWayPickup: UIView!
    @IBOutlet weak var viewPickupSuccessFull: UIView!
    @IBOutlet weak var viewOnTheWayDelivery: UIView!
    @IBOutlet weak var viewDeliverySuccessfull: UIView!
    @IBOutlet weak var viewPaymentSuccessfull: UIView!
    @IBOutlet weak var progressBar: UIView!
    
    @IBOutlet weak var lblOrderConfirmed: UILabel!
    @IBOutlet weak var lblOnTheWayPickup: UILabel!
    @IBOutlet weak var lblPickupSuccessFull: UILabel!
    @IBOutlet weak var lblOnTheWayDelivery: UILabel!
    @IBOutlet weak var lblDeliverySuccessfull: UILabel!
    @IBOutlet weak var lblPaymentSuccessfull: UILabel!
    
    @IBOutlet weak var lblTrackYourOrder: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnTrackYourOrder: UIButton!
    @IBOutlet weak var btnTrackYourOrder1: UIButton!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var btnBillingDetails: UIButton!
    
    @IBOutlet weak var heightCollectionView: NSLayoutConstraint!
    @IBOutlet fileprivate weak var collectionStatus: UICollectionView!
     weak var OrderStatusShapeLayer: CAShapeLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews()
    {
        viewDetails.layer.cornerRadius = 5
        viewDetails.clipsToBounds = true
        viewDetails.layer.borderColor  =  UIColor.lightGray.cgColor
        viewDetails.layer.borderWidth = 0.3
        viewDetails.layer.shadowOpacity = 0.8
        viewDetails.layer.shadowColor =  UIColor.darkGray.cgColor
        viewDetails.layer.shadowRadius = 3.0
        viewDetails.layer.shadowOffset = CGSize(width:0, height: 2)
        viewDetails.layer.masksToBounds = false
        viewDetailsWithColor.roundCorners([.topLeft, .bottomLeft], radius: 5)
        
        
        viewTracking.layer.cornerRadius = 5
        viewTracking.clipsToBounds = true
        
//        viewOrderConfirmed.layer.cornerRadius = viewOrderConfirmed.frame.size.height/2
//        viewOnTheWayPickup.layer.cornerRadius = viewOnTheWayPickup.frame.size.height/2
//        viewPickupSuccessFull.layer.cornerRadius = viewPickupSuccessFull.frame.size.height/2
//        viewOnTheWayDelivery.layer.cornerRadius = viewOnTheWayDelivery.frame.size.height/2
//        viewDeliverySuccessfull.layer.cornerRadius = viewDeliverySuccessfull.frame.size.height/2
//        viewPaymentSuccessfull.layer.cornerRadius = viewPaymentSuccessfull.frame.size.height/2
        
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension OrderHistoryTableViewCell {
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        collectionStatus.delegate = dataSourceDelegate
        collectionStatus.dataSource = dataSourceDelegate
        collectionStatus.tag = row
        collectionStatus.setContentOffset(collectionStatus.contentOffset, animated:false) // Stops collection view if it was scrolling.
        self.collectionStatus.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { collectionStatus.contentOffset.x = newValue }
        get { return collectionStatus.contentOffset.x }
    }
}

