//
//  ServiceSuccessfullVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 17/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Spring
import FBSDKCoreKit

class ServiceSuccessfullVC: UIViewController {

    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var lblBookingID: UILabel!
    @IBOutlet weak var lblBookedDate: UILabel!
    @IBOutlet weak var lblBookedTime: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblWalletStatus: UILabel!
    @IBOutlet weak var lblPaymentType: UILabel!
    @IBOutlet weak var ImgTick: SpringImageView!
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setFontFamilyAndSize()
        self.hideKeyboardWhenTappedAround()
        
        appDelegate.IsfromRatingsVC = false
//        let ID = appDelegate.dictServiceSuccess["userBookId"]
//        let strID = String(describing: ID!)
        
        let qty = appDelegate.dictServiceSuccess["quantity"]
        let strQty = String(describing: qty!)
        
        lblQuantity.text = strQty
        lblBookingID.text = appDelegate.dictServiceSuccess["BookId"] as? String ?? ""
        lblBookedDate.text = appDelegate.dictServiceSuccess["deliverydate"] as? String ?? ""
        lblBookedTime.text = appDelegate.dictServiceSuccess["TimeSlot"] as? String ?? ""
        
        let strPaymentMode = appDelegate.dictServiceSuccess["paymentType"] as? String ?? ""
        self.lblPaymentType.text = strPaymentMode.uppercased()
        
        var strAmount = appDelegate.dictServiceSuccess["totalPayment"] as? String ?? ""
        strAmount = "Rs. " + strAmount
        
        let stringValue = "Total Amount : " + strAmount
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
        attributedString.setColorForText(textForAttribute: "Total Amount : ", withColor: UIColor.white)
        attributedString.setColorForText(textForAttribute: strAmount, withColor: UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:1))
        lblTotalAmount.font = UIFont(name: FONT_BOLD, size: 15)
        lblTotalAmount.attributedText = attributedString
        

        let strDate = appDelegate.dictServiceSuccess["DeliverySuccessDate"] as? String ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let deliver: Date? = formatter.date(from: strDate)
        formatter.dateFormat = "dd-MM-yyyy"
        let strDeliverDate = formatter.string(from: deliver!)
       
        formatter.dateFormat = "HH:mm:ss"
        let strDeliverTime = formatter.string(from: deliver!)
        
        lblBookedDate.text = strDeliverDate
        lblBookedTime.text = strDeliverTime
        
        let strPaymentType = appDelegate.dictServiceSuccess["paymentType"] as? String ?? ""
        if strPaymentType == "Wallet"
        {
            lblWalletStatus.isHidden = false
            let sts = appDelegate.dictServiceSuccess["wallet_status"]
            let strStatus = String(describing: sts!)
            if strStatus == "1"
            {
               lblWalletStatus.text = "Insufficient balance in wallet. Please pay cash to delivery man"
            }
            else
            {
                lblWalletStatus.text = "Payment successfully debited from your wallet."
            }
            
        }
        else
        {
            lblWalletStatus.isHidden = true
        }
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        if (appDelegate.IsfromRatingsVC)
        {
            self.dismiss(animated: true, completion: nil)
        }
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ACTIONS
    @IBAction func onRateUs(_ sender: Any)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RatingsVC") as! RatingsVC
        self.present(vc, animated: true, completion: nil)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
