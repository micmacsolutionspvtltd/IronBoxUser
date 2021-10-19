//
//  OnGoingTableViewCell.swift
//  Ironbox
//
//  Created by Gopalsamy A on 10/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class OnGoingTableViewCell: UITableViewCell {
    
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
    @IBOutlet weak var deliveryOtp:UIView!
    @IBOutlet weak var otpLbl: UILabel!
    @IBOutlet weak var bookidTopHeight: NSLayoutConstraint!
    @IBOutlet weak var bookingStrTopHeight: NSLayoutConstraint!
    
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
    
    @IBOutlet weak var viewDriverDetails: UIView!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblDriverNo: UILabel!
    @IBOutlet weak var imgDriver: UIImageView!
    @IBOutlet weak var btnCall: UIButton!
    
    @IBOutlet weak var viewDriverDetailsWithPay: UIView!
    @IBOutlet weak var lblDriverNameWithPay: UILabel!
    @IBOutlet weak var lblDriverNoWithPay: UILabel!
    @IBOutlet weak var imgDriverWithPay: UIImageView!
    @IBOutlet weak var btnCallWithPay: UIButton!
    @IBOutlet weak var btnPayWithPay: UIButton!
    
    @IBOutlet weak var viewPayment: UIView!
    @IBOutlet weak var btnPay: UIButton!
    @IBOutlet weak var lblPayNote: UILabel!
    
    @IBOutlet fileprivate weak var collectionStatus: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    weak var OrderStatusShapeLayer: CAShapeLayer?
    
    @IBOutlet weak var viewTrackingTop: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func layoutSubviews()
    {
        viewTracking.layer.cornerRadius = 5
        viewTracking.clipsToBounds = true
        
        imgDriver.layer.cornerRadius = imgDriver.frame.size.height / 2
        imgDriver.clipsToBounds = true
        imgDriver.layer.borderColor  =  UIColor.lightGray.cgColor
        imgDriver.layer.borderWidth = 0.3
        imgDriver.layer.shadowOpacity = 0.8
        imgDriver.layer.shadowColor =  UIColor.lightGray.cgColor
        imgDriver.layer.shadowRadius = 1.0
        imgDriver.layer.shadowOffset = CGSize(width:0, height: 2)
        //imgDriver.layer.masksToBounds = false
        
        btnCall.layer.cornerRadius = btnCall.frame.size.height / 2
        btnCall.clipsToBounds = true
        btnCall.layer.borderColor  =  UIColor.lightGray.cgColor
        btnCall.layer.borderWidth = 0.3
        btnCall.layer.shadowOpacity = 0.8
        btnCall.layer.shadowColor =  UIColor.lightGray.cgColor
        btnCall.layer.shadowRadius = 1.0
        btnCall.layer.shadowOffset = CGSize(width:0, height: 2)
        
        
        imgDriverWithPay.layer.cornerRadius = imgDriverWithPay.frame.size.height / 2
        imgDriverWithPay.clipsToBounds = true
        imgDriverWithPay.layer.borderColor  =  UIColor.lightGray.cgColor
        imgDriverWithPay.layer.borderWidth = 0.3
        imgDriverWithPay.layer.shadowOpacity = 0.8
        imgDriverWithPay.layer.shadowColor =  UIColor.lightGray.cgColor
        imgDriverWithPay.layer.shadowRadius = 1.0
        imgDriverWithPay.layer.shadowOffset = CGSize(width:0, height: 2)
        //imgDriver.layer.masksToBounds = false
        
        btnCallWithPay.layer.cornerRadius = btnCallWithPay.frame.size.height / 2
        btnCallWithPay.clipsToBounds = true
        btnCallWithPay.layer.borderColor  =  UIColor.lightGray.cgColor
        btnCallWithPay.layer.borderWidth = 0.3
        btnCallWithPay.layer.shadowOpacity = 0.8
        btnCallWithPay.layer.shadowColor =  UIColor.lightGray.cgColor
        btnCallWithPay.layer.shadowRadius = 1.0
        btnCallWithPay.layer.shadowOffset = CGSize(width:0, height: 2)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension OnGoingTableViewCell {
    
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


