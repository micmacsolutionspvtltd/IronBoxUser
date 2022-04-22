//
//  BillingDetailsVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 11/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView

class BillingDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableBillingHeight: NSLayoutConstraint!
    @IBOutlet weak var tableBillingDetails: UITableView!
    var arrBillingDetails = Array<Any>()

    @IBOutlet weak var lblOfferAmount: UILabel!

    @IBOutlet weak var lblStaticOfferAmount: UILabel!
    @IBOutlet weak var lblStaticgrandtotalwithoutgst: UILabel!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var amountHeaderLabel: UILabel!
    @IBOutlet weak var taxAmountHeaderLabel: UILabel!
    @IBOutlet weak var taxAmountLabel: UILabel!
    @IBOutlet weak var totalAmountHeaderLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var paidAmountHeaderLabel: UILabel!
    @IBOutlet weak var paidAmountLabel: UILabel!
    @IBOutlet weak var totalPayableAmountHeaderLabel: UILabel!
    @IBOutlet weak var totalPayableAmountLabel: UILabel!

    var strBookingId = ""

    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setFontFamilyAndSize()

        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]

        let btnBack = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItems([item], animated: true)

        viewBG.isHidden = true
        self.getBillingDetails()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: - ACTIONS
    @objc func ClickonBackBtn()
    {
        _ = navigationController?.popViewController(animated: true)
    }


    // MARK: - GET BILLING DETAILS
    func getBillingDetails()
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))

        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]

        let param: [String: Any] = [
            "bookingId":strBookingId
        ]


        self.CheckNetwork()

        AlamofireHC.requestPOST(VIEW_BILLING_DETAILS, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary

            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {

                self.arrBillingDetails = json.value(forKey: "BookingItems") as! Array<Any>

                if self.arrBillingDetails.count != 0
                {
                    let strDiscountAmount = json.value(forKey: "discount_amount") as? String ?? ""

                    if strDiscountAmount == ""
                    {
                        self.lblOfferAmount.isHidden = true
                        self.lblStaticOfferAmount.isHidden = true
                        self.lblStaticgrandtotalwithoutgst.text = "Rs.\(json.value(forKey: "grandtotalwithoutgst") as? Double ?? 0.0)"
                    
//                        self.lblStaticSgst.text = "\(gstArray.last?["gst_val"] as? Double ?? 0.0)"
//                        self.lblStaticCgst.text = "\(gstArray.first?["gst_val"] as? Double ?? 0.0)"
                      //  self.lblTotalAmount.text = "\(json.value(forKey: "PaidAmount") as? Double ?? 0.0)"
                        self.paidAmountLabel.text = "Rs.\(json.value(forKey: "PaidAmount") as? Double ?? 0.0)"
                        self.taxAmountLabel.text = "\(json.value(forKey: "taxamount") as? String ?? "")"
                        self.totalAmountLabel.text =
                        "\(json.value(forKey: "totalPayment") as? String ?? "")"
                        self.totalPayableAmountLabel.text =
                        "\(json.value(forKey: "grand_total") as? String ?? "")"
                       // self.lblPayableAmountWithoutOffer.text = json.value(forKey: "totalPayment") as? String ?? ""

                       // self.lblPayableAmountWithoutOffer.isHidden = false
                        //self.lblStaticPayableAmountWithoutOffer.isHidden = false


                        // self.lblTotalAmount.isHidden = true
                        // self.lblStaticTotalAmount.isHidden = true
                        self.lblOfferAmount.isHidden = true
                        self.lblStaticOfferAmount.isHidden = true
                    
                        //test
                        print( json.value(forKey: "grandtotalwithoutgst")!)
                        print( json.value(forKey: "grandtotalwithoutgst")!)

                    }
                    else
                    {
                        //self.lblTotalAmount.isHidden = false
                        // self.lblStaticTotalAmount.isHidden = false
                        self.lblOfferAmount.isHidden = false
                        self.lblStaticOfferAmount.isHidden = false
                
                      
                       // self.lblPayableAmountWithoutOffer.isHidden = true
                       // self.lblStaticPayableAmountWithoutOffer.isHidden = true


                        self.lblStaticgrandtotalwithoutgst.text = "\(json.value(forKey: "grandtotalwithoutgst") as? Double ?? 0.0)"
                       // self.lblTotalAmount.text = json.value(forKey: "totalPayment") as? String ?? ""
                        self.lblOfferAmount.text = json.value(forKey: "discount_amount") as? String ?? ""
                        let totalAmount = Double("\(self.lblStaticgrandtotalwithoutgst.text ?? "0.0")")
                        let offerprice = Double("\(self.lblOfferAmount.text?.components(separatedBy: ".").last ?? "0.0")")
                        let payable = (totalAmount ?? 0.0) - (offerprice ?? 0.0)
                        self.totalPayableAmountLabel.text =  "\(payable)"
                            //json.value(forKey: "grand_total") as? String ?? ""

                        let gstArray = json.value(forKey: "each_gst_amts") as! Array<[String: Any]>
                       // self.lblTotalAmount.text = "\(json.value(forKey: "PaidAmount") as? Double ?? 0.0)"
                        self.paidAmountLabel.text = "\(json.value(forKey: "PaidAmount") as? Double ?? 0.0)"
                        self.taxAmountLabel.text = "\(json.value(forKey: "taxamount") as? String ?? "")"
                        self.totalAmountLabel.text =
                        "\(json.value(forKey: "totalPayment") as? String ?? "")"
                        self.totalPayableAmountLabel.text =
                        "\(json.value(forKey: "grand_total") as? String ?? "")"
                        let strPromoCode = json.value(forKey: "promocode") as? String ?? ""

                        let nPAckage = json.value(forKey: "Is_package")
                        let strPackage = String(describing: nPAckage!)

                        if strPackage == "1"
                        {
                            self.lblStaticOfferAmount.text = "Using Package"
                        }
                        else
                        {


                            //                            self.lblStaticOfferAmount.text = "Offer Applied ( " + strPromoCode + " )"

                            self.lblStaticOfferAmount.text = "Offer Applied("+strPromoCode+")"


                        }

                    }

                    self.tableBillingDetails.delegate = self
                    self.tableBillingDetails.dataSource = self
                    self.tableBillingDetails.reloadData()
                    self.tableBillingDetails.isHidden = false
                    self.tableBillingHeight.constant = CGFloat(self.arrBillingDetails.count * 65)

                    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: CGFloat(self.arrBillingDetails.count * 65) + 108)

                    self.viewBG.isHidden = false
                }
                else
                {
                    self.tableBillingDetails.isHidden = true
                }

            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
                self.tableBillingDetails.isHidden = true
            }


        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
            self.tableBillingDetails.isHidden = true
        })

    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 65
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return arrBillingDetails.count

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

        let cell = tableView.dequeueReusableCell(withIdentifier: "BillingDetailsTableViewCell", for: indexPath) as! BillingDetailsTableViewCell
        cell.selectionStyle = .none

        let dictRateCard = self.arrBillingDetails[indexPath.row] as! Dictionary<String, Any>
        cell.lblCategoryName.text = dictRateCard["product_name"] as? String ?? ""
        cell.lblPrice.text = dictRateCard["amount"] as? String ?? ""
        let qty = dictRateCard["quantity"]
        cell.lblQuantity.text = String(describing: qty!)

        let isPackageAmt = dictRateCard["IsPackage_amt"] as? Int ?? 0
        if isPackageAmt == 1
        {
            cell.lblIsPackage.isHidden = false
        }
        else
        {
            cell.lblIsPackage.isHidden = true
        }
        return cell

    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {

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
