////
////  OnGoingServices.swift
////  Ironbox
////
////  Created by Gopalsamy A on 09/04/18.
////  Copyright © 2018 Gopalsamy A. All rights reserved.
////
//
import UIKit
import Alamofire
import NVActivityIndicatorView
import CircularRevealKit
import Spring

class OnGoingServices: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var tableOrders: UITableView!
    @IBOutlet weak var tableCancelReason: UITableView!
    @IBOutlet weak var viewCancel: UIView!
    @IBOutlet weak var viewCancelDialouge: SpringView!
    @IBOutlet weak var btnCancelYes: UIButton!
    @IBOutlet weak var btnCancelNo: UIButton!

    var arrCancelReason = Array<Any>()
    var arrBookings = Array<Any>()
    var arrStatus = Array<Any>()
    var selectedReasonIndex = Int()
    var currentPageNumber = Int()
    var totalPages = Int()
    var strCancelReasonId = ""
    var strBookingIdForCancel = ""
    var strBookingIdForBillingDetails = ""

    var ViewTutorial = UIView()
    var ImgTutorial = UIImageView()
    var  nTutorialNumber = Int()

    var merchant:PGMerchantConfiguration!
    var strOrderId = ""
    var strBookingIdForPayment = ""
    var strPayableAmount = ""

    @IBOutlet weak var viewPaymentSuccess: UIView!
    @IBOutlet weak var lblPSBookingID: UILabel!
    @IBOutlet weak var lblPSPaymentDate: UILabel!
    @IBOutlet weak var lblPSPaymentTime: UILabel!
    @IBOutlet weak var lblPSQuantity: UILabel!
    @IBOutlet weak var ImgPSTick: SpringImageView!
    @IBOutlet weak var lblPSTotalAmount: UILabel!


    let yourAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont(name: FONT_MEDIUM, size: 14)!,
        NSAttributedStringKey.foregroundColor : UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0),
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]

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

        self.viewCancel.isHidden = false
        viewCancel.backgroundColor = UIColor(red: 18/255, green: 24/255, blue: 38/255, alpha: 0.852)
        self.tableOrders.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        currentPageNumber = 1

        appDelegate.dictPaymentSuccess.removeAll()
        viewPaymentSuccess.isHidden = true
         self.setMerchant()//initialize merchant with config.

        if ((userDefaults.value(forKey: IS_ONGOING_TUTORIAL_SHOWN) as? String) == nil)
        {
            self.showTutorialScreen()
        }
        else
        {
            self.getCurrentOrderList()
        }

    }

    override func viewWillAppear(_ animated: Bool)
    {
       if appDelegate.dictPaymentSuccess.count != 0
       {
         self.onDisplayPaymentSuccess()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - TUTORIAL SCREEN
    func showTutorialScreen()
    {
    ViewTutorial.removeFromSuperview()
    nTutorialNumber = 1
    let screenSize: CGRect = UIScreen.main.bounds
    ViewTutorial = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
    ViewTutorial.backgroundColor = UIColor(red: 18/255, green: 24/255, blue: 38/255, alpha: 0.852)
    self.navigationController?.view.addSubview(ViewTutorial)

    ImgTutorial  = UIImageView(frame:CGRect(x:0, y:0, width:screenSize.width, height:screenSize.height));
    ImgTutorial.image = UIImage(named:"TutoOnGoing1")
    ViewTutorial.addSubview(ImgTutorial)

    let btnNxt:UIButton = UIButton(frame:  CGRect(x: screenSize.width - 100, y: screenSize.height - 50, width: 100, height: 50))
    btnNxt.backgroundColor = UIColor.clear
    btnNxt.addTarget(self, action: #selector(self.onTutorialNext(_:)), for:.touchUpInside)
    ViewTutorial.addSubview(btnNxt)
    }
    @IBAction func onTutorialNext(_ sender: Any)
    {
        if nTutorialNumber == 1
        {
            ImgTutorial.image = UIImage(named:"TutoOnGoing2")
            nTutorialNumber = 2
        }
        else if nTutorialNumber == 2
        {
            ImgTutorial.image = UIImage(named:"TutoOnGoing3")
            nTutorialNumber = 3
        }
        else if nTutorialNumber == 3
        {
            userDefaults.set("yes", forKey: IS_ONGOING_TUTORIAL_SHOWN)
            ViewTutorial.removeFromSuperview()
            nTutorialNumber = 1
            self.getCurrentOrderList()
        }
    }

    // MARK: - CURRENT ORDER LIST
    func getCurrentOrderList()
    {

        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]

        let param: [String: Any] = [
            "page_number":currentPageNumber
        ]

        self.CheckNetwork()

        if currentPageNumber == 1
        {
          self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        }

        AlamofireHC.requestPOST(USER_CURRENT_ORDER_LIST, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            if self.currentPageNumber == 1
            {
                 UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            }


            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary

            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                self.totalPages = json.value(forKey: "Pages") as! Int
                self.arrBookings += json.value(forKey: "BookingList") as! Array<Any>

                for var i in 0..<self.arrBookings.count
                {
                    var dictBookings = self.arrBookings[i] as! Dictionary<String, Any>
                    dictBookings["isSelected"] = "0"
                    self.arrBookings.remove(at: i)
                    self.arrBookings.insert(dictBookings, at: i)

                }

                if self.arrBookings.count != 0
                {
                    self.tableOrders.delegate = self
                    self.tableOrders.dataSource = self
                    self.tableOrders.reloadData()
                    self.tableOrders.isHidden = false
                }
                else
                {
                    self.tableOrders.isHidden = true
                }

            }
            else
            {
                if self.arrBookings.count == 0
                {
                     self.tableOrders.isHidden = true
                }

                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
            }


        }, failure: { (error) in
            if self.currentPageNumber == 1
            {
                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            }
            if self.arrBookings.count == 0
            {
                self.tableOrders.isHidden = true
            }
            print(error)
        })

    }

    // MARK: - OREDR CANCEL
    func getCancelReasonsList()
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))

        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]

        self.CheckNetwork()

        AlamofireHC.requestPOST(CENCEL_REASON, params: nil, headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary

            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {

                self.arrCancelReason = json.value(forKey: "response") as! Array<Any>

                if self.arrCancelReason.count != 0
                {
                    self.viewCancel.isHidden = false
                    self.tableCancelReason.delegate = self
                    self.tableCancelReason.dataSource = self
                    self.tableCancelReason.reloadData()
                    self.tableCancelReason.isHidden = false

                    let viewControllerSize = self.view.frame.size
                    let width = viewControllerSize.width
                    let height = viewControllerSize.height
                    self.view.bringSubview(toFront: self.viewCancel)
                    self.viewCancel.isHidden = false

//                    let rect = CGRect(
//                        origin: CGPoint(
//                            x: width/2,
//                            y: height/2),
//                        size: CGSize(
//                            width: 250,
//                            height: 400))
//
//                    self.viewCancel.drawAnimatedCircularMask(
//                        startFrame: rect,
//                        duration: 0.33,
//                        revealType: RevealType.reveal) { [weak self] in
//                            self?.viewCancelDialouge.animation = "shake"
//                            self?.viewCancelDialouge.curve = "easeIn"
//                            self?.viewCancelDialouge.duration = 1.0
//                            self?.viewCancelDialouge.repeatCount = 1
//                            self?.viewCancelDialouge.animate()
//
//                    }
                }
                else
                {
                    self.tableCancelReason.isHidden = true
                }

            }
            else
            {
                self.tableCancelReason.isHidden = true
                                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                                self.ShowAlert(msg: errorMessage)
            }


        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
        })

    }

    @IBAction func onCancelYes(_ sender: Any)
    {
        if strCancelReasonId == ""
        {
            ShowAlert(msg: "Please select any given reason \n to continue")
        }
        else
        {
            self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))

            let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
            let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]


            let param: [String: Any] = [
                "bookingId":strBookingIdForCancel,
                "reasonId":strCancelReasonId
            ]

            self.CheckNetwork()

            AlamofireHC.requestPOST(CANCEL_ORDER, params: param as [String : AnyObject], headers: header, success: { (JSON) in
                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
                let  result = JSON.dictionaryObject
                let json = result! as NSDictionary

                let err = json.value(forKey: "error") as? String ?? ""
                if (err == "false")
                {
                    self.viewCancel.isHidden = false
                    let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                    self.ShowAlert(msg: errorMessage)
                    for var j in 0..<self.arrBookings.count
                    {
                        let dictBooking = self.arrBookings[j] as! Dictionary<String, Any>
                        let bookingID = dictBooking["id"]
                        let strBookingID = String(describing: bookingID!)
                        if self.strBookingIdForCancel == strBookingID
                        {
                             self.arrBookings.remove(at: j)

                            if self.arrBookings.count != 0
                            {
                                self.tableOrders.reloadData()
                                self.tableOrders.layoutIfNeeded()
                                self.tableOrders.setContentOffset(.zero, animated: false)
                                self.tableOrders.isHidden = false
                            }
                            else
                            {
                                self.tableOrders.isHidden = true
                            }

                            return
                        }

                    }
                   // self.getCurrentOrderList()

                }
                else
                {
                    let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                    self.ShowAlert(msg: errorMessage)
                }


            }, failure: { (error) in
                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
                print(error)
            })
        }
        //code changed here 
        self.viewCancel.isHidden = true
        self.view.sendSubview(toBack: self.viewCancel)
    }

 /*   func reload(tableView: UITableView) {

        let contentOffset = tableView.contentOffset
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.setContentOffset(.zero, animated: false)

    } */

    @IBAction func onCancelNo(_ sender: Any)
    {

//        let viewControllerSize = view.frame.size
//        let width = viewControllerSize.width
//        let height = viewControllerSize.height
//        let rect = CGRect(
//            origin: CGPoint(
//                x: width/2,
//                y: height/2),
//            size: CGSize(
//                width: 0,
//                height: 0))
//
//        viewCancel.drawAnimatedCircularMask(
//            startFrame: rect,
//            duration: 0.5,
//            revealType: RevealType.unreveal) { [weak self] in
//                self?.viewCancel.isHidden = true
//        }

        self.viewCancel.isHidden = true
        self.view.sendSubview(toBack: self.viewCancel)

    }


    func setMerchant()
    {
        merchant  = PGMerchantConfiguration.default()!
        //user your checksum urls here or connect to paytm developer team for this or use default urls of paytm
        merchant.checksumGenerationURL = "http://139.59.37.241/Ironman/public/api/GenerateCheckSum";
        merchant.checksumValidationURL = "http://139.59.37.241/Ironman/public/api/VerifyChecksum";

        // Set the client SSL certificate path. Certificate.p12 is the certificate which you received from Paytm during the registration process. Set the password if the certificate is protected by a password.
        merchant.clientSSLCertPath = nil; //[[NSBundle mainBundle]pathForResource:@"Certificate" ofType:@"p12"];
        merchant.clientSSLCertPassword = nil; //@"password";

        //configure the PGMerchantConfiguration object specific to your requirements
        merchant.merchantID = MERCHANT_ID//paste here your merchant id  //mandatory
        merchant.website = WEBSITE //mandatory
        merchant.industryID = INDUSTRYTYPEID //mandatory
        merchant.channelID = CHANNELID  //provided by PG WAP //mandatory

    }

    @objc func getOrderId()
    {
    self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))

        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]

        self.CheckNetwork()

        AlamofireHC.requestPOST(GET_ORDERID, params: nil, headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary

            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                self.strOrderId = json.value(forKey: "orderId") as? String ?? ""
                self.onGenerateCheckSum()

            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)

            }


        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)

        })

    }


    @objc func onGenerateCheckSum()
    {
    self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))

        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]


        let strCustomerId = userDefaults.object(forKey: USER_MOBILE) as? String
        let strEmail = userDefaults.object(forKey: USER_EMAIL) as? String
        let strCallBackURL = CALLBACKURL + strOrderId

        var parameters:[String:String]?
        parameters = ["MID":MERCHANT_ID,"ORDER_ID":strOrderId ,"INDUSTRY_TYPE_ID":INDUSTRYTYPEID,"CHANNEL_ID":CHANNELID,"TXN_AMOUNT":strPayableAmount,"WEBSITE":WEBSITE, "CUST_ID":strCustomerId,"CALLBACK_URL":strCallBackURL, "MOBILE_NO":strCustomerId ,"EMAIL_ID":strEmail] as? [String : String]

        AlamofireHC.requestPOST(GENERATE_CHECKSUM_URL, params: parameters! as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary

            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                let dict = json.value(forKey: "check_sum") as! NSDictionary
                let strCheckSum = dict["CHECKSUMHASH"] as? String ?? ""
                self.onValidateeCheckSum(strCheckSum: strCheckSum)
            }
            else
            {

            }


        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)

        })

    }

    func onValidateeCheckSum(strCheckSum: String )
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))

        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]

        let strCustomerId = userDefaults.object(forKey: USER_MOBILE) as? String
        let strEmail = userDefaults.object(forKey: USER_EMAIL) as? String
        let strCallBackURL = CALLBACKURL + strOrderId

        var parameters:[String:String]?
        parameters = ["MID":MERCHANT_ID,"ORDER_ID":strOrderId ,"INDUSTRY_TYPE_ID":INDUSTRYTYPEID,"CHANNEL_ID":CHANNELID,"TXN_AMOUNT":strPayableAmount,"WEBSITE":WEBSITE, "CHECKSUMHASH":strCheckSum ,"CUST_ID":strCustomerId,"CALLBACK_URL":strCallBackURL, "MOBILE_NO":strCustomerId ,"EMAIL_ID":strEmail, "PAY_TYPE":"card"] as? [String : String]


        AlamofireHC.requestPOST(VALIDATE_CHECKSUM_URL, params: parameters! as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary

            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                let errMsg = json.value(forKey: "error_message") as? String ?? ""
                if (errMsg == "TRUE")
                {
                    let screenSize: CGRect = UIScreen.main.bounds
                    let ViewTop = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 60))
                    ViewTop.backgroundColor = UIColor.white

                    let btnCancel:UIButton = UIButton(frame:  CGRect(x: 0, y: 30, width: 90, height: 30))
                    btnCancel.setTitleColor(UIColor(red: 0/255, green: 186/255, blue: 246/255, alpha: 1), for: .normal)
                    btnCancel.setTitle("Cancel", for: .normal)
                    btnCancel.titleLabel?.font =  UIFont(name: FONT_MEDIUM, size: 16)

                    let pgOrder = PGOrder(params: parameters )
                    let transaction = PGTransactionViewController.init(transactionFor: pgOrder)
                    transaction!.serverType = eServerTypeProduction
                    transaction!.merchant = self.merchant
                    transaction!.loggingEnabled = true
                    transaction!.delegate = self
                    transaction?.topBar = ViewTop
                    transaction?.cancelButton = btnCancel
                    self.present(transaction!, animated: true, completion: {

                    })

                }


            }
            else
            {


            }


        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)

        })

    }

    func CardPaymentAPICallOnPaymentSuccess(response: Dictionary<String, Any>)
    {
        view.endEditing(true)
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))

        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]

        let strTransId = response["TXNID"] as? String ?? ""
        let strOrdId = response["ORDERID"] as? String ?? ""
        let strTranStatus = response["STATUS"] as? String ?? ""
        let strTransAmount = response["TXNAMOUNT"] as? String ?? ""
        let strCheckSum = response["CHECKSUMHASH"] as? String ?? ""
        let strPaymentMode = response["PAYMENTMODE"] as? String ?? ""
        let strTransDate = response["TXNDATE"] as? String ?? ""
        let strBankName = response["BANKNAME"] as? String ?? ""
        let strBankTransID = response["BANKTXNID"] as? String ?? ""
        let strStatusCode = response["RESPCODE"] as? String ?? ""

        let param: [String: Any] = [
            "transactionId":strTransId,
            "orderId":strOrdId,
            "tnx_status":strTranStatus,
            "txn_amount":strTransAmount,
            "check_sum":strCheckSum,
            "payment_mode":strPaymentMode,
            "tnx_date":strTransDate,
            "bank_name":strBankName,
            "bank_tnx_id":strBankTransID,
            "status_code":strStatusCode,
            "bookingId":strBookingIdForPayment
            ]

        self.CheckNetwork()

        AlamofireHC.requestPOST(CARD_PAYMENT, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                let strOrderId = json.value(forKey: "orderId")as? String ?? ""

                let PaytmRsponsesData = userDefaults.object(forKey: "PaytmRsponse") as? NSData
                if let PaytmRsponsesData = PaytmRsponsesData {
                    appDelegate.arrPaytmRsponse = NSKeyedUnarchiver.unarchiveObject(with: PaytmRsponsesData as Data) as! Array<Any>

                    for i in 0..<appDelegate.arrPaytmRsponse.count
                    {
                        var dict = appDelegate.arrPaytmRsponse[i] as! Dictionary<String, Any>
                        let strOrdId = dict["ORDERID"] as? String ?? ""
                        if strOrdId == strOrderId
                        {
                            appDelegate.arrPaytmRsponse.remove(at: i)
                            let PaytmRsponsesData = NSKeyedArchiver.archivedData(withRootObject: appDelegate.arrPaytmRsponse)
                            userDefaults.set(PaytmRsponsesData, forKey: "PaytmRsponse")
                        }

                    }

                }

                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)

                appDelegate.dictPaymentSuccess = json.value(forKey: "bookings") as! Dictionary<String,Any>
                if appDelegate.dictPaymentSuccess.count != 0
                {
                    self.onDisplayPaymentSuccess()
                }
            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
            }


        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
        })
    }
    func UserCancelledTransactionAPICall()
    {
        view.endEditing(true)
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))

        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]


        let param: [String: Any] = [
            "orderId":strOrderId
        ]
        print(param)
        self.CheckNetwork()

        AlamofireHC.requestPOST(CANCELLED_TRANSACTION, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                //                self.txtEnterAmount.text = ""
                //                self.txtPromoCode.text = ""
                //                appDelegate.strOfferCode = ""
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
                //  self.getWalletAmount()
            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
            }


        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
        })
    }


    func onDisplayPaymentSuccess()
    {
        for var j in 0..<self.arrBookings.count
        {
            var dictBooking = self.arrBookings[j] as! Dictionary<String, Any>
            let bookingID = dictBooking["id"]
            let strBookingID = String(describing: bookingID!)
            if self.strBookingIdForPayment == strBookingID
            {
                dictBooking["paidStatus"] = "1"
                self.arrBookings.remove(at: j)
                self.arrBookings.insert(dictBooking, at: j)

                let qty = appDelegate.dictPaymentSuccess["quantity"]
                let strQty = String(describing: qty!)

                if strQty == ""
                {
                    self.lblPSQuantity.text = "Will be updated post pickup"
                }
                else
                {
                    self.lblPSQuantity.text = strQty
                }

                var strAmount = appDelegate.dictPaymentSuccess["totalPayment"] as? String ?? ""
                strAmount = "Rs. " + strAmount
                let stringValue = "Total Amount : " + strAmount
                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
                attributedString.setColorForText(textForAttribute: "Total Amount : ", withColor: UIColor.white)
                attributedString.setColorForText(textForAttribute: strAmount, withColor: UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:1))
                self.lblPSTotalAmount.font = UIFont(name: FONT_BOLD, size: 15)
                self.lblPSTotalAmount.attributedText = attributedString

                self.lblPSBookingID.text = appDelegate.dictPaymentSuccess["bookingId"] as? String ?? ""

                let strDate = appDelegate.dictPaymentSuccess["payment_date"] as? String ?? ""
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let deliver: Date? = formatter.date(from: strDate)
                formatter.dateFormat = "dd-MM-yyyy"
                let strDeliverDate = formatter.string(from: deliver!)

                formatter.dateFormat = "HH:mm:ss"
                let strDeliverTime = formatter.string(from: deliver!)

                self.lblPSPaymentDate.text = strDeliverDate
                self.lblPSPaymentTime.text = strDeliverTime

                self.viewPaymentSuccess.isHidden = false

                let viewControllerSize = self.view.frame.size
                let width = viewControllerSize.width
                let height = viewControllerSize.height
                let rect = CGRect(
                    origin: CGPoint(
                        x: width/2,
                        y: height/2),
                    size: CGSize(
                        width: 0,
                        height: 0))

                self.viewPaymentSuccess.drawAnimatedCircularMask(
                    startFrame: rect,
                    duration: 0.33,
                    revealType: RevealType.reveal) { [weak self] in
                        self?.ImgPSTick.animation = "pop"
                        self?.ImgPSTick.curve = "easeIn"
                        self?.ImgPSTick.duration = 1.0
                        self?.ImgPSTick.repeatCount = 1
                        self?.ImgPSTick.animate()
                }

                if self.arrBookings.count != 0
                {
                    self.tableOrders.reloadData()
                    self.tableOrders.layoutIfNeeded()
                    self.tableOrders.isHidden = false
                }
                else
                {
                    self.tableOrders.isHidden = true
                }

                return
            }


        }


    }

    @IBAction func onGoHome(_ sender: Any)
    {
        let viewControllerSize = view.frame.size
        let width = viewControllerSize.width
        let height = viewControllerSize.height
        let rect = CGRect(
            origin: CGPoint(
                x: width/2,
                y: height/2),
            size: CGSize(
                width: 0,
                height: 0))

        viewPaymentSuccess.drawAnimatedCircularMask(
            startFrame: rect,
            duration: 0.33,
            revealType: RevealType.unreveal) { [weak self] in
                self?.viewPaymentSuccess.isHidden = true
                appDelegate.dictPaymentSuccess.removeAll()
        }

    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tableOrders
        {
            return arrBookings.count
        }
        else
        {
            return arrCancelReason.count
        }


    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == tableOrders
        {
            let dict = arrBookings[indexPath.row] as! NSDictionary
            let isSelected = dict["isSelected"] as? String ?? ""
            let strStatus = dict["Status"] as? String ?? ""
            let PaymentStatus = dict["paidStatus"]
            let strPaymentStatus = String(describing: PaymentStatus!)
            let strPaymentType = dict["paymentType"] as? String ?? ""


            var nHeight = 0
            if strStatus == "ON THE WAY"
            {
                nHeight = 80
            }
            else if strStatus == "PICKUP SUCCESS"
            {
                if strPaymentType != "Cash"
                {
                    if strPaymentStatus == "0"
                    {
                         nHeight = 75
                    }
                    else
                    {
                         nHeight = 0
                    }
                }
                else
                {
                     nHeight = 0
                }
            }
            else
            {
             nHeight = 0
            }
            if isSelected == "1"
            {
                self.arrStatus = dict["OrderStatus"] as! Array<Any>
                let canCancel = dict["CanCancel"] as? String ?? ""
                if canCancel == "Yes"
                {
                    let isPickupSuccess = dict["PickupSuccess"]
                    let strisPickupSuccess = String(describing: isPickupSuccess!)
                    if strisPickupSuccess == "0"
                    {
                       return CGFloat((arrStatus.count * 43) + 225 + nHeight) //225
                    }
                    else
                    {
                        return CGFloat((arrStatus.count * 43) + 265 + nHeight) //225
                    }


                }
                else
                {
                    return CGFloat((arrStatus.count * 43) + 225 + nHeight) //265
                }

            }
            return CGFloat(210 + nHeight)
        }
        else
        {
            return 50
        }

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

        if tableView == tableOrders
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OnGoingTableViewCell", for: indexPath) as! OnGoingTableViewCell
            cell.selectionStyle = .none
            cell.bookingStrTopHeight.constant = 10
            cell.bookidTopHeight.constant = 8
            cell.deliveryOtp.isHidden = true
            let dictBooking = self.arrBookings[indexPath.row] as! Dictionary<String, Any>

//            let bookingID = dictBooking["id"]
//            let strBookingID = String(describing: bookingID!)
            cell.lblBookingId.text = dictBooking["bookingId"] as? String ?? ""

            let Qty = dictBooking["quantity"]
            let strQty = String(describing: Qty!)


            if strQty == ""
            {
                cell.lblQuantity.text = "Will be updated post pickup"
                cell.lblQuantity.font = cell.lblQuantity.font.withSize(10)
            }
            else
            {
                cell.lblQuantity.text = strQty
                cell.lblQuantity.font = cell.lblQuantity.font.withSize(14)
            }

            let strPaymentType = dictBooking["paymentType"] as? String ?? ""
            cell.lblPaymentMode.text = strPaymentType.uppercased()

            cell.lblStatus.text = dictBooking["Status"] as? String ?? ""
            var strDescription = dictBooking["description"] as? String ?? ""
            strDescription = "\"" + strDescription + "\""
            cell.lblDescription.text = strDescription
            let strTime = dictBooking["TimeSlot"] as? String ?? ""
            cell.lblTimeSlot.text =  strTime
            let strDate = dictBooking["bookingDate"] as? String ?? ""
            var dateArr = strDate.components(separatedBy: "-")
            let strDat: String = dateArr[0]
            let strMon: String = dateArr[1]
            cell.lblDate.text = strDat + "/" + strMon

            cell.btnTrackYourOrder.tag = indexPath.row + 10000
            cell.btnTrackYourOrder.addTarget(self, action: #selector(self.onTrackOrder(btn:)), for: .touchUpInside)

            cell.btnTrackYourOrder1.tag = indexPath.row + 15000
            cell.btnTrackYourOrder1.addTarget(self, action: #selector(self.onTrackOrder(btn:)), for: .touchUpInside)

            cell.btnCancel.tag = indexPath.row + 20000
            cell.btnCancel.addTarget(self, action: #selector(self.onCancel(btn:)), for: .touchUpInside)

            let strCancel = dictBooking["CanCancel"] as? String ?? ""
            if strCancel == "Yes"
            {
                cell.btnCancel.isHidden = false
            }
            else
            {
                cell.btnCancel.isHidden = true
            }

            cell.btnBillingDetails.tag = indexPath.row + 25000
            cell.btnBillingDetails.addTarget(self, action: #selector(self.onBillingDetails(btn:)), for: .touchUpInside)
            let attributeString1 = NSMutableAttributedString(string: "VIEW BILLING DETAILS",
                                                             attributes: yourAttributes)
            cell.btnBillingDetails.setAttributedTitle(attributeString1, for: .normal)

            cell.viewDetailsWithColor.layoutIfNeeded()

            let strStatus = dictBooking["Status"] as? String ?? ""
            let PaymentStatus = dictBooking["paidStatus"]
            let strPaymentStatus = String(describing: PaymentStatus!)


            if strStatus == "CONFIRMED"
            {
                cell.imgStatusIcon.image = UIImage(named: "Confirmed")
                cell.imgStatusIcon.frame.size.width = 35
                cell.imgStatusIcon.center.x = cell.viewDetailsWithColor.bounds.midX
                cell.imgStatusIcon.frame.size.height = 35
                cell.imgStatusIcon.frame.origin.y =  cell.lblStatus.frame.origin.y - 40

                cell.viewDriverDetails.isHidden = true
                cell.viewTrackingTop.constant = 135

                cell.viewDetails.layer.cornerRadius = 5
                cell.viewDetails.clipsToBounds = true
                cell.viewDetails.layer.borderColor  =  UIColor.lightGray.cgColor
                cell.viewDetails.layer.borderWidth = 0.3
                cell.viewDetails.layer.shadowOpacity = 0.8
                cell.viewDetails.layer.shadowColor =  UIColor.darkGray.cgColor
                cell.viewDetails.layer.shadowRadius = 3.0
                cell.viewDetails.layer.shadowOffset = CGSize(width:0, height: 2)
                cell.viewDetails.layer.masksToBounds = false
                cell.viewDetailsWithColor.roundCorners([.topLeft, .bottomLeft], radius: 5)


            }
            else  if strStatus == "ON THE WAY"
            {
                cell.viewPayment.isHidden = true
                let isPickupSuccess = dictBooking["PickupSuccess"]
                let strisPickupSuccess = String(describing: isPickupSuccess!)
                if strisPickupSuccess == "0"
                {
                    cell.imgStatusIcon.image = UIImage(named: "OnTheWayPickup")
                    cell.viewDriverDetailsWithPay.isHidden = true

                }
                else
                {
                    cell.imgStatusIcon.image = UIImage(named: "OnTheWayDelivery")
                    cell.bookingStrTopHeight.constant = 50
                    cell.bookidTopHeight.constant = 48
                    cell.deliveryOtp.isHidden = false

                    cell.otpLbl.text = "\(dictBooking["delivery_otp"] as? Int ?? 0)"

                    if strPaymentType != "Cash"
                    {
                        if strPaymentStatus == "0"
                        {
                            cell.viewDriverDetailsWithPay.isHidden = false
                        }
                        else
                        {
                            cell.viewDriverDetailsWithPay.isHidden = true
                        }
                    }
                    else
                    {
                        cell.viewDriverDetailsWithPay.isHidden = true
                    }

                }

                cell.imgStatusIcon.frame.size.width = 80
                cell.imgStatusIcon.center.x = cell.viewDetailsWithColor.bounds.midX
                cell.imgStatusIcon.frame.size.height = 22
                cell.imgStatusIcon.frame.origin.y =  cell.lblStatus.frame.origin.y - 27


                cell.viewDriverDetails.isHidden = false
                cell.viewTrackingTop.constant = 205

                cell.viewDetails.layoutIfNeeded()
                cell.viewDetails.layer.cornerRadius = 0
                cell.viewDetails.roundCorners([.topLeft, .topRight], radius: 5)
                cell.viewDetails.clipsToBounds = true
                cell.viewDetails.layer.borderColor  =  UIColor.lightGray.cgColor
                cell.viewDetails.layer.borderWidth = 0.3
                cell.viewDetails.layer.shadowOpacity = 0.8
                cell.viewDetails.layer.shadowColor =  UIColor.darkGray.cgColor
                cell.viewDetails.layer.shadowRadius = 3.0
                cell.viewDetails.layer.shadowOffset = CGSize(width:0, height: 2)
                cell.viewDetails.layer.masksToBounds = false


              //  cell.viewDriverDetails.roundCorners([.bottomLeft, .bottomRight], radius: 5)
                cell.viewDriverDetails.layer.cornerRadius = 5
                cell.viewDriverDetails.clipsToBounds = true
                cell.viewDriverDetails.layer.borderColor  =  UIColor.lightGray.cgColor
                cell.viewDriverDetails.layer.borderWidth = 0.3
                cell.viewDriverDetails.layer.shadowOpacity = 0.8
                cell.viewDriverDetails.layer.shadowColor =  UIColor.darkGray.cgColor
                cell.viewDriverDetails.layer.shadowRadius = 3.0
                cell.viewDriverDetails.layer.shadowOffset = CGSize(width:0, height: 2)
                cell.viewDriverDetails.layer.masksToBounds = false

                cell.viewDetailsWithColor.roundCorners([.topLeft], radius: 5)

                let dictDriverDetails = dictBooking["DeliveryUser"] as! Dictionary<String, Any>
                cell.lblDriverNo.text = dictDriverDetails["mobile"] as? String ?? ""
                cell.lblDriverName.text = dictDriverDetails["name"] as? String ?? ""

                cell.lblDriverNoWithPay.text = dictDriverDetails["mobile"] as? String ?? ""
                cell.lblDriverNameWithPay.text = dictDriverDetails["name"] as? String ?? ""


                if dictDriverDetails["image"] as? String != nil
                {
                    var strImageURL = dictDriverDetails["image"] as? String ?? ""
                    strImageURL = strImageURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                  //  cell.imgDriver.sd_setImage(with: URL(string: strImageURL), placeholderImage: UIImage(named: "User"), options: .refreshCached)
                     cell.imgDriver.imageFromServerURL(urlString: strImageURL)
                    cell.imgDriverWithPay.imageFromServerURL(urlString: strImageURL)
                }
                else
                {
                 //   cell.imgDriver.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: "User"), options: .refreshCached)

                    cell.imgDriver.image = UIImage(named: "User")
                    cell.imgDriverWithPay.image = UIImage(named: "User")
                }

                cell.btnCall.tag = indexPath.row + 30000
                cell.btnCall.addTarget(self, action: #selector(self.onCall(btn:)), for: .touchUpInside)

                cell.btnCallWithPay.tag = indexPath.row + 35000
                cell.btnCallWithPay.addTarget(self, action: #selector(self.onCallWithPay(btn:)), for: .touchUpInside)

                cell.btnPayWithPay.tag = indexPath.row + 45000
                cell.btnPayWithPay.addTarget(self, action: #selector(self.onPayWithCall(btn:)), for: .touchUpInside)

            }
            else  if strStatus == "PICKUP SUCCESS"
            {
                cell.imgStatusIcon.image = UIImage(named: "Pickup Success")
                cell.imgStatusIcon.frame.size.width = 35
                cell.imgStatusIcon.center.x = cell.viewDetailsWithColor.bounds.midX
                cell.imgStatusIcon.frame.size.height = 35
                cell.imgStatusIcon.frame.origin.y =  cell.lblStatus.frame.origin.y - 40


                if strPaymentType != "Cash"
                {
                    if strPaymentStatus == "0"
                    {
                        cell.viewPayment.isHidden = false

                        cell.viewDriverDetails.isHidden = false
                        cell.viewTrackingTop.constant = 205

                        cell.viewDetails.layoutIfNeeded()
                        cell.viewDetails.layer.cornerRadius = 0
                        cell.viewDetails.roundCorners([.topLeft, .topRight], radius: 5)
                        cell.viewDetails.clipsToBounds = true
                        cell.viewDetails.layer.borderColor  =  UIColor.lightGray.cgColor
                        cell.viewDetails.layer.borderWidth = 0.3
                        cell.viewDetails.layer.shadowOpacity = 0.8
                        cell.viewDetails.layer.shadowColor =  UIColor.darkGray.cgColor
                        cell.viewDetails.layer.shadowRadius = 3.0
                        cell.viewDetails.layer.shadowOffset = CGSize(width:0, height: 2)
                        cell.viewDetails.layer.masksToBounds = false


                        //  cell.viewDriverDetails.roundCorners([.bottomLeft, .bottomRight], radius: 5)
                        cell.viewDriverDetails.layer.cornerRadius = 5
                        cell.viewDriverDetails.clipsToBounds = true
                        cell.viewDriverDetails.layer.borderColor  =  UIColor.lightGray.cgColor
                        cell.viewDriverDetails.layer.borderWidth = 0.3
                        cell.viewDriverDetails.layer.shadowOpacity = 0.8
                        cell.viewDriverDetails.layer.shadowColor =  UIColor.darkGray.cgColor
                        cell.viewDriverDetails.layer.shadowRadius = 3.0
                        cell.viewDriverDetails.layer.shadowOffset = CGSize(width:0, height: 2)
                        cell.viewDriverDetails.layer.masksToBounds = false

                        cell.viewDetailsWithColor.roundCorners([.topLeft], radius: 5)

                        cell.btnPay.tag = indexPath.row + 40000
                        cell.btnPay.addTarget(self, action: #selector(self.onPay(btn:)), for: .touchUpInside)

                    }
                    else
                    {
                        cell.viewPayment.isHidden = true

                        cell.viewDriverDetails.isHidden = true
                        cell.viewTrackingTop.constant = 135

                        cell.viewDetails.layer.cornerRadius = 5
                        cell.viewDetails.clipsToBounds = true
                        cell.viewDetails.layer.borderColor  =  UIColor.lightGray.cgColor
                        cell.viewDetails.layer.borderWidth = 0.3
                        cell.viewDetails.layer.shadowOpacity = 0.8
                        cell.viewDetails.layer.shadowColor =  UIColor.darkGray.cgColor
                        cell.viewDetails.layer.shadowRadius = 3.0
                        cell.viewDetails.layer.shadowOffset = CGSize(width:0, height: 2)
                        cell.viewDetails.layer.masksToBounds = false
                        cell.viewDetailsWithColor.roundCorners([.topLeft, .bottomLeft], radius: 5)
                    }
                }
                else
                {
                    cell.viewPayment.isHidden = true

                    cell.viewDriverDetails.isHidden = true
                    cell.viewTrackingTop.constant = 135

                    cell.viewDetails.layer.cornerRadius = 5
                    cell.viewDetails.clipsToBounds = true
                    cell.viewDetails.layer.borderColor  =  UIColor.lightGray.cgColor
                    cell.viewDetails.layer.borderWidth = 0.3
                    cell.viewDetails.layer.shadowOpacity = 0.8
                    cell.viewDetails.layer.shadowColor =  UIColor.darkGray.cgColor
                    cell.viewDetails.layer.shadowRadius = 3.0
                    cell.viewDetails.layer.shadowOffset = CGSize(width:0, height: 2)
                    cell.viewDetails.layer.masksToBounds = false
                    cell.viewDetailsWithColor.roundCorners([.topLeft, .bottomLeft], radius: 5)

                }


            }



            let isSelected = dictBooking["isSelected"] as? String ?? ""

            var progressBarPercentage = -2.5
            var arrOrdSts = dictBooking["OrderStatus"] as! Array<Any>
            for var j in 0..<arrOrdSts.count
            {
                var dictStatus = arrOrdSts[j] as! Dictionary<String, Any>
                let strStatus = dictStatus["Status"] as? String ?? ""
                if strStatus == "Yes"
                {
                    progressBarPercentage = progressBarPercentage + 2.5
                }
            }

            if isSelected == "1"
            {

                let isPickupSuccess = dictBooking["PickupSuccess"]
                let strisPickupSuccess = String(describing: isPickupSuccess!)
                if strisPickupSuccess == "0"
                {
                    cell.btnBillingDetails.isHidden = true
                }
                else
                {
                    cell.btnBillingDetails.isHidden = false
                }

                cell.viewTracking.frame.size.height = 50
                cell.progressBar.isHidden = false
                cell.lblTrackYourOrder.isHidden = true
                cell.btnTrackYourOrder.isHidden = true
                UIView.animate(withDuration: 0.4, animations: {
                    let arSts = dictBooking["OrderStatus"] as! Array<Any>

                    let canCancel = dictBooking["CanCancel"] as? String ?? ""
                    if canCancel == "Yes"
                    {
                        let isPickupSuccess = dictBooking["PickupSuccess"]
                        let strisPickupSuccess = String(describing: isPickupSuccess!)
                        if strisPickupSuccess == "0"
                        {
                            cell.viewTracking.frame.size.height = CGFloat((arSts.count * 43) + 65) //100
                        }
                        else
                        {
                            cell.viewTracking.frame.size.height = CGFloat((arSts.count * 43) + 100) //65
                        }
                    }
                    else
                    {
                        cell.viewTracking.frame.size.height = CGFloat((arSts.count * 43) + 65) //100
                    }


                    cell.collectionViewHeight.constant = CGFloat(arSts.count * 43)
                    cell.imgArrow.image = UIImage(named: "UpArrow")
                    cell.progressBar.layoutIfNeeded()

                    cell.OrderStatusShapeLayer?.removeFromSuperlayer()

                    // create whatever path you want
                    let path = UIBezierPath()
                    path.move(to: CGPoint(x: 2, y: 0))
                    let PrgsFill = Double(cell.progressBar.frame.size.height/10)
                    let ProgressFill = PrgsFill * progressBarPercentage
                    path.addLine(to: CGPoint(x: 2, y: ProgressFill))
                    //path.addLine(to: CGPoint(x: 200, y: 240))

                    // create shape layer for that path
                    let shapeLayer = CAShapeLayer()
                    shapeLayer.fillColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 0.4).cgColor
                    shapeLayer.strokeColor = #colorLiteral(red: 0.09019607843, green: 0.7254901961, blue: 0.4705882353, alpha: 1).cgColor
                    shapeLayer.lineWidth = 4
                    shapeLayer.path = path.cgPath

                    // animate it
                    cell.progressBar.layer.addSublayer(shapeLayer)
                    let animation = CABasicAnimation(keyPath: "strokeEnd")
                    animation.fromValue = 0
                    animation.duration = 2
                    shapeLayer.add(animation, forKey: "MyAnimation")

                    // save shape layer
                    cell.OrderStatusShapeLayer = shapeLayer

                }, completion: {
                    (value: Bool) in
                })
            }
            else
            {
                cell.viewTracking.frame.size.height = 50
                cell.imgArrow.image = UIImage(named: "DownArrow")
                cell.progressBar.isHidden = true
                cell.btnBillingDetails.isHidden = true
                cell.lblTrackYourOrder.isHidden = false
                cell.btnTrackYourOrder.isHidden = false


            }

            return cell
        }
        else
        {
             let cell = tableView.dequeueReusableCell(withIdentifier: "CancelReasonTableViewCell", for: indexPath) as! CancelReasonTableViewCell

            let dictCancel = self.arrCancelReason[indexPath.row] as! Dictionary<String, Any>
            cell.lblReason.text = dictCancel["reasons"] as? String ?? ""

            let reasonId = dictCancel["id"]
            let strRsnId = String(describing: reasonId!)
            if strCancelReasonId == strRsnId
            {
                cell.imgRadio.image = UIImage(named: "RadioOn")
            }
            else
            {
                cell.imgRadio.image = UIImage(named: "RadioOff")
            }

            return cell
        }


    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if tableView == tableOrders
        {
            guard let tableViewCell = cell as? OnGoingTableViewCell else { return }
            tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)


            let lastCell = self.arrBookings.count - 1
            if indexPath.row == lastCell {
                if currentPageNumber <  totalPages{
                    currentPageNumber = currentPageNumber + 1
                    self.getCurrentOrderList()
                }
            }

            cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.6) {
                cell.transform = CGAffineTransform.identity
            }

        }


    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if tableView == tableOrders
        {
           guard let tableViewCell = cell as? OnGoingTableViewCell else { return }
        }



    }


    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView == tableOrders
        {

        }
        else
        {
            let dict = self.arrCancelReason[indexPath.row] as! Dictionary<String, Any>
            let reasonId = dict["id"]
            strCancelReasonId = String(describing: reasonId!)
            tableCancelReason.reloadData()
        }
    }


    // MARK: - ACTIONS
    @objc func ClickonBackBtn()
    {
        _ = navigationController?.popViewController(animated: true)
    }

    @objc func onTrackOrder(btn:UIButton)
    {
        var btnTag = btn.tag - 10000
        if btn.tag >= 15000
        {
            btnTag = btn.tag - 15000
        }
        else
        {
            btnTag = btn.tag - 10000
        }

        let indexpath = NSIndexPath(row:btnTag, section: 0)
        var dictBookings = self.arrBookings[btnTag] as! Dictionary<String, Any>
        let isSelected = dictBookings["isSelected"] as? String ?? ""
        if isSelected == "1"
        {
            dictBookings["isSelected"] = "0"
            let cell = tableOrders.cellForRow(at: indexpath as IndexPath) as! OnGoingTableViewCell?
            let arSts = dictBookings["OrderStatus"] as! Array<Any>
            cell?.viewTracking.frame.size.height = CGFloat((arSts.count * 43) + 100) //60
            UIView.animate(withDuration: 0.4, animations: {
                cell?.viewTracking.frame.size.height = 50
            }, completion: {
                (value: Bool) in
                cell?.imgArrow.image = UIImage(named: "DownArrow")
                cell?.progressBar.isHidden = true
                self.arrBookings.remove(at: btnTag)
                self.arrBookings.insert(dictBookings, at: btnTag)
                self.tableOrders.reloadRows(at: [indexpath as IndexPath], with: .automatic)
            })

        }
        else
        {
            dictBookings["isSelected"] = "1"
            self.arrBookings.remove(at: btnTag)
            self.arrBookings.insert(dictBookings, at: btnTag)
            tableOrders.reloadRows(at: [indexpath as IndexPath], with: .automatic)
        }



    }

    @objc func onCancel(btn:UIButton)
    {
        let btnTag = btn.tag - 20000
        let dict = self.arrBookings[btnTag] as! Dictionary<String, Any>
        let bookingID = dict["id"]
        strBookingIdForCancel = String(describing: bookingID!)

        strCancelReasonId = ""
        self.getCancelReasonsList()
    }

    @objc func onBillingDetails(btn:UIButton)
    {
        let btnTag = btn.tag - 25000
        let dict = self.arrBookings[btnTag] as! Dictionary<String, Any>
        let bookingID = dict["id"]
        strBookingIdForBillingDetails = String(describing: bookingID!)
        self.performSegue(withIdentifier: "Services_Billing", sender: self)
    }

    @objc func onCall(btn:UIButton)
    {
        let btnTag = btn.tag - 30000
        let dict = self.arrBookings[btnTag] as! Dictionary<String, Any>
        var dictDriver = dict["DeliveryUser"] as! Dictionary<String, Any>
        let strMobileNo = dictDriver["mobile"] as? String ?? ""

        if let url = URL(string: "tel://\(strMobileNo)") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }

    }

    @objc func onCallWithPay(btn:UIButton)
    {
        let btnTag = btn.tag - 35000
        let dict = self.arrBookings[btnTag] as! Dictionary<String, Any>
        var dictDriver = dict["DeliveryUser"] as! Dictionary<String, Any>
        let strMobileNo = dictDriver["mobile"] as? String ?? ""

        if let url = URL(string: "tel://\(strMobileNo)") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }

    }


    @objc func onPay(btn:UIButton)
    {
        let btnTag = btn.tag - 40000
        let dict = self.arrBookings[btnTag] as! Dictionary<String, Any>
        let bookingID = dict["id"]
        strBookingIdForPayment = String(describing: bookingID!)
        let totalPayment = dict["totalPayment"]
        strPayableAmount = String(describing: totalPayment!)
        let strPaymentType = dict["paymentType"] as? String ?? ""

        if strPaymentType == "Card"
        {
             self.getOrderId()
        }
        else if strPaymentType == "Wallet"
        {
            self.performSegue(withIdentifier: "onGoing_WalletPayment", sender: self)
        }


    }

    @objc func onPayWithCall(btn:UIButton)
    {
        let btnTag = btn.tag - 45000
        let dict = self.arrBookings[btnTag] as! Dictionary<String, Any>
        let bookingID = dict["id"]
        strBookingIdForPayment = String(describing: bookingID!)
        let totalPayment = dict["totalPayment"]
        strPayableAmount = String(describing: totalPayment!)
        let strPaymentType = dict["paymentType"] as? String ?? ""

        if strPaymentType == "Card"
        {
            self.getOrderId()
        }
        else if strPaymentType == "Wallet"
        {
            self.performSegue(withIdentifier: "onGoing_WalletPayment", sender: self)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if (segue.identifier == "Services_Billing")
        {
            let billingVC = segue.destination as! BillingDetailsVC
            billingVC.strBookingId = strBookingIdForBillingDetails

        }
        else if (segue.identifier == "onGoing_WalletPayment")
        {
            let WalletPaymentVC = segue.destination as! WalletPaymentVC
            WalletPaymentVC.strBookingID = strBookingIdForPayment
            WalletPaymentVC.strPayebleAmout = strPayableAmount

        }
    }


    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let dict = arrBookings[collectionView.tag] as! NSDictionary
        self.arrStatus = dict["OrderStatus"] as! Array<Any>
        return arrStatus.count

    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpandDataCollectionViewCell", for: indexPath) as! ExpandDataCollectionViewCell
        let dict = arrBookings[collectionView.tag] as! NSDictionary

        let isSelected = dict["isSelected"] as? String ?? ""
        if isSelected == "1"
        {
            let arSts = dict["OrderStatus"] as! Array<Any>
            let dictSts = arSts[indexPath.row] as! NSDictionary
            cell.lblStatus.text =  dictSts["name"] as? String ?? ""

            let strStatus = dictSts["Status"] as? String ?? ""
            if strStatus  == "Yes"
            {
                cell.lblStatus.textColor = UIColor(red: 23/255, green: 185/255, blue: 120/255, alpha: 1.0) // Green
                cell.viewDot.backgroundColor = UIColor(red: 23/255, green: 185/255, blue: 120/255, alpha: 1.0) // Green
            }
            else
            {
                cell.lblStatus.textColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 0.3) // Gray
                cell.viewDot.backgroundColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 0.3) // Gray
            }
        }
        else
        {
            cell.lblStatus.textColor = UIColor.clear
            cell.viewDot.backgroundColor = UIColor.clear
        }




        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {

    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.invalidateLayout()
        return CGSize(width: collectionView.frame.width , height:40)
    }


    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

}

/*

 var progressBarPercentage = -2.5
 var arrOrdSts = dictBooking["OrderStatus"] as! Array<Any>
 for var j in 0..<arrOrdSts.count
 {
 var dictStatus = arrOrdSts[j] as! Dictionary<String, Any>
 let strStatus = dictStatus["Status"] as? String ?? ""
 if strStatus == "Yes"
 {
 progressBarPercentage = progressBarPercentage + 2.5
 }
 }


 let PrgsFill = Double(cell.progressBar.frame.size.height/10)
 let ProgressFill = PrgsFill * progressBarPercentage

 */

// MARK: Paytm Delegate methods.
extension OnGoingServices : PGTransactionDelegate{
    func didFinishedResponse(_ controller: PGTransactionViewController!, response responseString: String!)
    {
        var dictPaymentSuccess = convertToDictionary(text: responseString)
        self.dismiss(animated: true, completion: nil)
        let dict = dictPaymentSuccess as! Dictionary<String, Any>

        dictPaymentSuccess!["bookingId"] = strBookingIdForPayment
        dictPaymentSuccess!["paymentType"] = "Service"
        appDelegate.arrPaytmRsponse.append(dictPaymentSuccess!)
        let PaytmRsponsesData = NSKeyedArchiver.archivedData(withRootObject: appDelegate.arrPaytmRsponse)
        userDefaults.set(PaytmRsponsesData, forKey: "PaytmRsponse")

        let strTransStatus = dict["STATUS"] as? String ?? ""
        self.ShowAlert(msg: strTransStatus)

        self.CardPaymentAPICallOnPaymentSuccess(response: dictPaymentSuccess!)

//        if strTransStatus == "TXN_SUCCESS"
//        {
//            self.CardPaymentAPICallOnPaymentSuccess(response: dictPaymentSuccess!)
//        }


    }

    func didCancelTrasaction(_ controller: PGTransactionViewController!)
    {
        self.dismiss(animated: true, completion: nil)
        self.UserCancelledTransactionAPICall()
    }

    func errorMisssingParameter(_ controller: PGTransactionViewController!, error: Error!) {
        print(error)
        // showAlert(title: "Transaction Failed", message: error.localizedDescription)
        self.dismiss(animated: true, completion: nil)
        self.ShowAlert(msg: error.localizedDescription)
    }



}



//
//  OnGoingServices.swift
//  Ironbox
//
//  Created by Gopalsamy A on 09/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

//import UIKit
//import Alamofire
//import NVActivityIndicatorView
//import CircularRevealKit
//import Spring
//
//class OnGoingServices: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    @IBOutlet weak var tableOrders: UITableView!
//    @IBOutlet weak var tableCancelReason: UITableView!
//    @IBOutlet weak var viewCancel: UIView!
//    @IBOutlet weak var viewCancelDialouge: SpringView!
//    @IBOutlet weak var btnCancelYes: UIButton!
//    @IBOutlet weak var btnCancelNo: UIButton!
//
//    var arrCancelReason = Array<Any>()
//    var arrBookings = Array<Any>()
//    var arrStatus = Array<Any>()
//    var selectedReasonIndex = Int()
//    var currentPageNumber = Int()
//    var totalPages = Int()
//    var strCancelReasonId = ""
//    var strBookingIdForCancel = ""
//    var strBookingIdForBillingDetails = ""
//
//    var ViewTutorial = UIView()
//    var ImgTutorial = UIImageView()
//    var  nTutorialNumber = Int()
//
//    var merchant:PGMerchantConfiguration!
//    var strOrderId = ""
//    var strBookingIdForPayment = ""
//    var strPayableAmount = ""
//
//    @IBOutlet weak var viewPaymentSuccess: UIView!
//    @IBOutlet weak var lblPSBookingID: UILabel!
//    @IBOutlet weak var lblPSPaymentDate: UILabel!
//    @IBOutlet weak var lblPSPaymentTime: UILabel!
//    @IBOutlet weak var lblPSQuantity: UILabel!
//    @IBOutlet weak var ImgPSTick: SpringImageView!
//    @IBOutlet weak var lblPSTotalAmount: UILabel!
//
//
//    let yourAttributes : [NSAttributedStringKey: Any] = [
//        NSAttributedStringKey.font : UIFont(name: FONT_MEDIUM, size: 14)!,
//        NSAttributedStringKey.foregroundColor : UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0),
//        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
//
//    // MARK: - VIEW LIFE CYCLE
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.setFontFamilyAndSize()
//        navigationController?.navigationBar.barTintColor = UIColor.white
//        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]
//
//        let btnBack = UIButton(type: .custom)
//        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
//        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
//        let item = UIBarButtonItem(customView: btnBack)
//        self.navigationItem.setLeftBarButtonItems([item], animated: true)
//
//        self.viewCancel.isHidden = true
//        viewCancel.backgroundColor = UIColor(red: 18/255, green: 24/255, blue: 38/255, alpha: 0.852)
//        self.tableOrders.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        currentPageNumber = 1
//
//        appDelegate.dictPaymentSuccess.removeAll()
//        viewPaymentSuccess.isHidden = true
//        self.setMerchant()//initialize merchant with config.
//
//        if ((userDefaults.value(forKey: IS_ONGOING_TUTORIAL_SHOWN) as? String) == nil)
//        {
//            self.showTutorialScreen()
//        }
//        else
//        {
//            self.getCurrentOrderList()
//        }
//
//    }
//
//    override func viewWillAppear(_ animated: Bool)
//    {
//        if appDelegate.dictPaymentSuccess.count != 0
//        {
//            self.onDisplayPaymentSuccess()
//        }
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//    // MARK: - TUTORIAL SCREEN
//    func showTutorialScreen()
//    {
//        ViewTutorial.removeFromSuperview()
//        nTutorialNumber = 1
//        let screenSize: CGRect = UIScreen.main.bounds
//        ViewTutorial = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
//        ViewTutorial.backgroundColor = UIColor(red: 18/255, green: 24/255, blue: 38/255, alpha: 0.852)
//        self.navigationController?.view.addSubview(ViewTutorial)
//
//        ImgTutorial  = UIImageView(frame:CGRect(x:0, y:0, width:screenSize.width, height:screenSize.height));
//        ImgTutorial.image = UIImage(named:"TutoOnGoing1")
//        ViewTutorial.addSubview(ImgTutorial)
//
//        let btnNxt:UIButton = UIButton(frame:  CGRect(x: screenSize.width - 100, y: screenSize.height - 50, width: 100, height: 50))
//        btnNxt.backgroundColor = UIColor.clear
//        btnNxt.addTarget(self, action: #selector(self.onTutorialNext(_:)), for:.touchUpInside)
//        ViewTutorial.addSubview(btnNxt)
//    }
//    @IBAction func onTutorialNext(_ sender: Any)
//    {
//        if nTutorialNumber == 1
//        {
//            ImgTutorial.image = UIImage(named:"TutoOnGoing2")
//            nTutorialNumber = 2
//        }
//        else if nTutorialNumber == 2
//        {
//            ImgTutorial.image = UIImage(named:"TutoOnGoing3")
//            nTutorialNumber = 3
//        }
//        else if nTutorialNumber == 3
//        {
//            userDefaults.set("yes", forKey: IS_ONGOING_TUTORIAL_SHOWN)
//            ViewTutorial.removeFromSuperview()
//            nTutorialNumber = 1
//            self.getCurrentOrderList()
//        }
//    }
//
//    // MARK: - CURRENT ORDER LIST
//    func getCurrentOrderList()
//    {
//
//        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
//        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
//
//        let param: [String: Any] = [
//            "page_number":currentPageNumber
//        ]
//
//        self.CheckNetwork()
//
//        if currentPageNumber == 1
//        {
//            self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
//        }
//
//        AlamofireHC.requestPOST(USER_CURRENT_ORDER_LIST, params: param as [String : AnyObject], headers: header, success: { (JSON) in
//            if self.currentPageNumber == 1
//            {
//                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            }
//
//
//            let  result = JSON.dictionaryObject
//            let json = result! as NSDictionary
//
//            let err = json.value(forKey: "error") as? String ?? ""
//            if (err == "false")
//            {
//                self.totalPages = json.value(forKey: "Pages") as! Int
//                self.arrBookings += json.value(forKey: "BookingList") as! Array<Any>
//
//                for var i in 0..<self.arrBookings.count
//                {
//                    var dictBookings = self.arrBookings[i] as! Dictionary<String, Any>
//                    dictBookings["isSelected"] = "0"
//                    self.arrBookings.remove(at: i)
//                    self.arrBookings.insert(dictBookings, at: i)
//
//                }
//
//                if self.arrBookings.count != 0
//                {
//                    self.tableOrders.delegate = self
//                    self.tableOrders.dataSource = self
//                    self.tableOrders.reloadData()
//                    self.tableOrders.isHidden = false
//                }
//                else
//                {
//                    self.tableOrders.isHidden = true
//                }
//
//            }
//            else
//            {
//                if self.arrBookings.count == 0
//                {
//                    self.tableOrders.isHidden = true
//                }
//
//                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
//                self.ShowAlert(msg: errorMessage)
//            }
//
//
//        }, failure: { (error) in
//            if self.currentPageNumber == 1
//            {
//                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            }
//            if self.arrBookings.count == 0
//            {
//                self.tableOrders.isHidden = true
//            }
//            print(error)
//        })
//
//    }
//
//    // MARK: - OREDR CANCEL
//    func getCancelReasonsList()
//    {
//        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
//
//        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
//        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
//
//        self.CheckNetwork()
//
//        AlamofireHC.requestPOST(CENCEL_REASON, params: nil, headers: header, success: { (JSON) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            let  result = JSON.dictionaryObject
//            let json = result! as NSDictionary
//
//            let err = json.value(forKey: "error") as? String ?? ""
//            if (err == "false")
//            {
//
//                self.arrCancelReason = json.value(forKey: "response") as! Array<Any>
//
//                if self.arrCancelReason.count != 0
//                {
//                    self.viewCancel.isHidden = false
//                    self.tableCancelReason.delegate = self
//                    self.tableCancelReason.dataSource = self
//                    self.tableCancelReason.reloadData()
//                    self.tableCancelReason.isHidden = false
//
//                    let viewControllerSize = self.view.frame.size
//                    let width = viewControllerSize.width
//                    let height = viewControllerSize.height
//                    let rect = CGRect(
//                        origin: CGPoint(
//                            x: width/2,
//                            y: height/2),
//                        size: CGSize(
//                            width: 0,
//                            height: 0))
//
//                    self.viewCancel.drawAnimatedCircularMask(
//                        startFrame: rect,
//                        duration: 0.33,
//                        revealType: RevealType.reveal) { [weak self] in
//                            self?.viewCancelDialouge.animation = "shake"
//                            self?.viewCancelDialouge.curve = "easeIn"
//                            self?.viewCancelDialouge.duration = 1.0
//                            self?.viewCancelDialouge.repeatCount = 1
//                            self?.viewCancelDialouge.animate()
//                    }
//                }
//                else
//                {
//                    self.tableCancelReason.isHidden = true
//                }
//
//            }
//            else
//            {
//                self.tableCancelReason.isHidden = true
//                //                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
//                //                self.ShowAlert(msg: errorMessage)
//            }
//
//
//        }, failure: { (error) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            print(error)
//        })
//
//    }
//
//    @IBAction func onCancelYes(_ sender: Any)
//    {
//        if strCancelReasonId == ""
//        {
//            ShowAlert(msg: "Please select any given reason \n to continue")
//        }
//        else
//        {
//            self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
//
//            let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
//            let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
//
//
//            let param: [String: Any] = [
//                "bookingId":strBookingIdForCancel,
//                "reasonId":strCancelReasonId
//            ]
//
//            self.CheckNetwork()
//
//            AlamofireHC.requestPOST(CANCEL_ORDER, params: param as [String : AnyObject], headers: header, success: { (JSON) in
//                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//                let  result = JSON.dictionaryObject
//                let json = result! as NSDictionary
//
//                let err = json.value(forKey: "error") as? String ?? ""
//                if (err == "false")
//                {
//                    self.viewCancel.isHidden = true
//                    let errorMessage = json.value(forKey: "error_message")as? String ?? ""
//                    self.ShowAlert(msg: errorMessage)
//                    for var j in 0..<self.arrBookings.count
//                    {
//                        let dictBooking = self.arrBookings[j] as! Dictionary<String, Any>
//                        let bookingID = dictBooking["id"]
//                        let strBookingID = String(describing: bookingID!)
//                        if self.strBookingIdForCancel == strBookingID
//                        {
//                            self.arrBookings.remove(at: j)
//
//                            if self.arrBookings.count != 0
//                            {
//                                self.tableOrders.reloadData()
//                                self.tableOrders.layoutIfNeeded()
//                                self.tableOrders.setContentOffset(.zero, animated: false)
//                                self.tableOrders.isHidden = false
//                            }
//                            else
//                            {
//                                self.tableOrders.isHidden = true
//                            }
//
//                            return
//                        }
//
//                    }
//                    // self.getCurrentOrderList()
//
//                }
//                else
//                {
//                    let errorMessage = json.value(forKey: "error_message")as? String ?? ""
//                    self.ShowAlert(msg: errorMessage)
//                }
//
//
//            }, failure: { (error) in
//                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//                print(error)
//            })
//        }
//
//    }
//
//    /*   func reload(tableView: UITableView) {
//
//     let contentOffset = tableView.contentOffset
//     tableView.reloadData()
//     tableView.layoutIfNeeded()
//     tableView.setContentOffset(.zero, animated: false)
//
//     } */
//
//    @IBAction func onCancelNo(_ sender: Any)
//    {
//
//        let viewControllerSize = view.frame.size
//        let width = viewControllerSize.width
//        let height = viewControllerSize.height
//        let rect = CGRect(
//            origin: CGPoint(
//                x: width/2,
//                y: height/2),
//            size: CGSize(
//                width: 0,
//                height: 0))
//
//        viewCancel.drawAnimatedCircularMask(
//            startFrame: rect,
//            duration: 0.5,
//            revealType: RevealType.unreveal) { [weak self] in
//                self?.viewCancel.isHidden = true
//        }
//
//    }
//
//
//    func setMerchant()
//    {
//        merchant  = PGMerchantConfiguration.default()!
//        //user your checksum urls here or connect to paytm developer team for this or use default urls of paytm
//        merchant.checksumGenerationURL = "http://139.59.37.241/Ironman/public/api/GenerateCheckSum";
//        merchant.checksumValidationURL = "http://139.59.37.241/Ironman/public/api/VerifyChecksum";
//
//        // Set the client SSL certificate path. Certificate.p12 is the certificate which you received from Paytm during the registration process. Set the password if the certificate is protected by a password.
//        merchant.clientSSLCertPath = nil; //[[NSBundle mainBundle]pathForResource:@"Certificate" ofType:@"p12"];
//        merchant.clientSSLCertPassword = nil; //@"password";
//
//        //configure the PGMerchantConfiguration object specific to your requirements
//        merchant.merchantID = MERCHANT_ID//paste here your merchant id  //mandatory
//        merchant.website = WEBSITE //mandatory
//        merchant.industryID = INDUSTRYTYPEID //mandatory
//        merchant.channelID = CHANNELID  //provided by PG WAP //mandatory
//
//    }
//
//    @objc func getOrderId()
//    {
//        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
//
//        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
//        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
//
//        self.CheckNetwork()
//
//        AlamofireHC.requestPOST(GET_ORDERID, params: nil, headers: header, success: { (JSON) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            let  result = JSON.dictionaryObject
//            let json = result! as NSDictionary
//
//            let err = json.value(forKey: "error") as? String ?? ""
//            if (err == "false")
//            {
//                self.strOrderId = json.value(forKey: "orderId") as? String ?? ""
//                self.onGenerateCheckSum()
//
//            }
//            else
//            {
//                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
//                self.ShowAlert(msg: errorMessage)
//
//            }
//
//
//        }, failure: { (error) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            print(error)
//
//        })
//
//    }
//
//
//    @objc func onGenerateCheckSum()
//    {
//        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
//
//        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
//        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
//
//
//        let strCustomerId = userDefaults.object(forKey: USER_MOBILE) as? String
//        let strEmail = userDefaults.object(forKey: USER_EMAIL) as? String
//        let strCallBackURL = CALLBACKURL + strOrderId
//
//        var parameters:[String:String]?
//        parameters = ["MID":MERCHANT_ID,"ORDER_ID":strOrderId ,"INDUSTRY_TYPE_ID":INDUSTRYTYPEID,"CHANNEL_ID":CHANNELID,"TXN_AMOUNT":strPayableAmount,"WEBSITE":WEBSITE, "CUST_ID":strCustomerId,"CALLBACK_URL":strCallBackURL, "MOBILE_NO":strCustomerId ,"EMAIL_ID":strEmail] as? [String : String]
//
//        AlamofireHC.requestPOST(GENERATE_CHECKSUM_URL, params: parameters! as [String : AnyObject], headers: header, success: { (JSON) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            let  result = JSON.dictionaryObject
//            let json = result! as NSDictionary
//
//            let err = json.value(forKey: "error") as? String ?? ""
//            if (err == "false")
//            {
//                let dict = json.value(forKey: "check_sum") as! NSDictionary
//                let strCheckSum = dict["CHECKSUMHASH"] as? String ?? ""
//                self.onValidateeCheckSum(strCheckSum: strCheckSum)
//            }
//            else
//            {
//
//            }
//
//
//        }, failure: { (error) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            print(error)
//
//        })
//
//    }
//
//    func onValidateeCheckSum(strCheckSum: String )
//    {
//        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
//
//        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
//        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
//
//        let strCustomerId = userDefaults.object(forKey: USER_MOBILE) as? String
//        let strEmail = userDefaults.object(forKey: USER_EMAIL) as? String
//        let strCallBackURL = CALLBACKURL + strOrderId
//
//        var parameters:[String:String]?
//        parameters = ["MID":MERCHANT_ID,"ORDER_ID":strOrderId ,"INDUSTRY_TYPE_ID":INDUSTRYTYPEID,"CHANNEL_ID":CHANNELID,"TXN_AMOUNT":strPayableAmount,"WEBSITE":WEBSITE, "CHECKSUMHASH":strCheckSum ,"CUST_ID":strCustomerId,"CALLBACK_URL":strCallBackURL, "MOBILE_NO":strCustomerId ,"EMAIL_ID":strEmail, "PAY_TYPE":"card"] as? [String : String]
//
//
//        AlamofireHC.requestPOST(VALIDATE_CHECKSUM_URL, params: parameters! as [String : AnyObject], headers: header, success: { (JSON) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            let  result = JSON.dictionaryObject
//            let json = result! as NSDictionary
//
//            let err = json.value(forKey: "error") as? String ?? ""
//            if (err == "false")
//            {
//                let errMsg = json.value(forKey: "error_message") as? String ?? ""
//                if (errMsg == "TRUE")
//                {
//                    let screenSize: CGRect = UIScreen.main.bounds
//                    let ViewTop = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 60))
//                    ViewTop.backgroundColor = UIColor.white
//
//                    let btnCancel:UIButton = UIButton(frame:  CGRect(x: 0, y: 30, width: 90, height: 30))
//                    btnCancel.setTitleColor(UIColor(red: 0/255, green: 186/255, blue: 246/255, alpha: 1), for: .normal)
//                    btnCancel.setTitle("Cancel", for: .normal)
//                    btnCancel.titleLabel?.font =  UIFont(name: FONT_MEDIUM, size: 16)
//
//                    let pgOrder = PGOrder(params: parameters )
//                    let transaction = PGTransactionViewController.init(transactionFor: pgOrder)
//                    transaction!.serverType = eServerTypeProduction
//                    transaction!.merchant = self.merchant
//                    transaction!.loggingEnabled = true
//                    transaction!.delegate = self
//                    transaction?.topBar = ViewTop
//                    transaction?.cancelButton = btnCancel
//                    self.present(transaction!, animated: true, completion: {
//
//                    })
//
//                }
//
//
//            }
//            else
//            {
//
//
//            }
//
//
//        }, failure: { (error) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            print(error)
//
//        })
//
//    }
//
//    func CardPaymentAPICallOnPaymentSuccess(response: Dictionary<String, Any>)
//    {
//        view.endEditing(true)
//        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
//
//        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
//        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
//
//        let strTransId = response["TXNID"] as? String ?? ""
//        let strOrdId = response["ORDERID"] as? String ?? ""
//        let strTranStatus = response["STATUS"] as? String ?? ""
//        let strTransAmount = response["TXNAMOUNT"] as? String ?? ""
//        let strCheckSum = response["CHECKSUMHASH"] as? String ?? ""
//        let strPaymentMode = response["PAYMENTMODE"] as? String ?? ""
//        let strTransDate = response["TXNDATE"] as? String ?? ""
//        let strBankName = response["BANKNAME"] as? String ?? ""
//        let strBankTransID = response["BANKTXNID"] as? String ?? ""
//        let strStatusCode = response["RESPCODE"] as? String ?? ""
//
//        let param: [String: Any] = [
//            "transactionId":strTransId,
//            "orderId":strOrdId,
//            "tnx_status":strTranStatus,
//            "txn_amount":strTransAmount,
//            "check_sum":strCheckSum,
//            "payment_mode":strPaymentMode,
//            "tnx_date":strTransDate,
//            "bank_name":strBankName,
//            "bank_tnx_id":strBankTransID,
//            "status_code":strStatusCode,
//            "bookingId":strBookingIdForPayment
//        ]
//
//        self.CheckNetwork()
//
//        AlamofireHC.requestPOST(CARD_PAYMENT, params: param as [String : AnyObject], headers: header, success: { (JSON) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            let  result = JSON.dictionaryObject
//            let json = result! as NSDictionary
//            let err = json.value(forKey: "error") as? String ?? ""
//            if (err == "false")
//            {
//                let strOrderId = json.value(forKey: "orderId")as? String ?? ""
//
//                let PaytmRsponsesData = userDefaults.object(forKey: "PaytmRsponse") as? NSData
//                if let PaytmRsponsesData = PaytmRsponsesData {
//                    appDelegate.arrPaytmRsponse = NSKeyedUnarchiver.unarchiveObject(with: PaytmRsponsesData as Data) as! Array<Any>
//
//                    for i in 0..<appDelegate.arrPaytmRsponse.count
//                    {
//                        var dict = appDelegate.arrPaytmRsponse[i] as! Dictionary<String, Any>
//                        let strOrdId = dict["ORDERID"] as? String ?? ""
//                        if strOrdId == strOrderId
//                        {
//                            appDelegate.arrPaytmRsponse.remove(at: i)
//                            let PaytmRsponsesData = NSKeyedArchiver.archivedData(withRootObject: appDelegate.arrPaytmRsponse)
//                            userDefaults.set(PaytmRsponsesData, forKey: "PaytmRsponse")
//                        }
//
//                    }
//
//                }
//
//                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
//                self.ShowAlert(msg: errorMessage)
//
//                appDelegate.dictPaymentSuccess = json.value(forKey: "bookings") as! Dictionary<String,Any>
//                if appDelegate.dictPaymentSuccess.count != 0
//                {
//                    self.onDisplayPaymentSuccess()
//                }
//            }
//            else
//            {
//                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
//                self.ShowAlert(msg: errorMessage)
//            }
//
//
//        }, failure: { (error) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            print(error)
//        })
//    }
//    func UserCancelledTransactionAPICall()
//    {
//        view.endEditing(true)
//        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
//
//        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
//        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
//
//
//        let param: [String: Any] = [
//            "orderId":strOrderId
//        ]
//        print(param)
//        self.CheckNetwork()
//
//        AlamofireHC.requestPOST(CANCELLED_TRANSACTION, params: param as [String : AnyObject], headers: header, success: { (JSON) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            let  result = JSON.dictionaryObject
//            let json = result! as NSDictionary
//            let err = json.value(forKey: "error") as? String ?? ""
//            if (err == "false")
//            {
//                //                self.txtEnterAmount.text = ""
//                //                self.txtPromoCode.text = ""
//                //                appDelegate.strOfferCode = ""
//                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
//                self.ShowAlert(msg: errorMessage)
//                //  self.getWalletAmount()
//            }
//            else
//            {
//                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
//                self.ShowAlert(msg: errorMessage)
//            }
//
//
//        }, failure: { (error) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            print(error)
//        })
//    }
//
//
//    func onDisplayPaymentSuccess()
//    {
//        for var j in 0..<self.arrBookings.count
//        {
//            var dictBooking = self.arrBookings[j] as! Dictionary<String, Any>
//            let bookingID = dictBooking["id"]
//            let strBookingID = String(describing: bookingID!)
//            if self.strBookingIdForPayment == strBookingID
//            {
//                dictBooking["paidStatus"] = "1"
//                self.arrBookings.remove(at: j)
//                self.arrBookings.insert(dictBooking, at: j)
//
//                let qty = appDelegate.dictPaymentSuccess["quantity"]
//                let strQty = String(describing: qty!)
//
//                if strQty == ""
//                {
//                    self.lblPSQuantity.text = "Will be updated post pickup"
//                }
//                else
//                {
//                    self.lblPSQuantity.text = strQty
//                }
//
//                var strAmount = appDelegate.dictPaymentSuccess["totalPayment"] as? String ?? ""
//                strAmount = "Rs. " + strAmount
//                let stringValue = "Total Amount : " + strAmount
//                let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
//                attributedString.setColorForText(textForAttribute: "Total Amount : ", withColor: UIColor.white)
//                attributedString.setColorForText(textForAttribute: strAmount, withColor: UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:1))
//                self.lblPSTotalAmount.font = UIFont(name: FONT_BOLD, size: 15)
//                self.lblPSTotalAmount.attributedText = attributedString
//
//                self.lblPSBookingID.text = appDelegate.dictPaymentSuccess["bookingId"] as? String ?? ""
//
//                let strDate = appDelegate.dictPaymentSuccess["payment_date"] as? String ?? ""
//                let formatter = DateFormatter()
//                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                let deliver: Date? = formatter.date(from: strDate)
//                formatter.dateFormat = "dd-MM-yyyy"
//                let strDeliverDate = formatter.string(from: deliver!)
//
//                formatter.dateFormat = "HH:mm:ss"
//                let strDeliverTime = formatter.string(from: deliver!)
//
//                self.lblPSPaymentDate.text = strDeliverDate
//                self.lblPSPaymentTime.text = strDeliverTime
//
//                self.viewPaymentSuccess.isHidden = false
//
//                let viewControllerSize = self.view.frame.size
//                let width = viewControllerSize.width
//                let height = viewControllerSize.height
//                let rect = CGRect(
//                    origin: CGPoint(
//                        x: width/2,
//                        y: height/2),
//                    size: CGSize(
//                        width: 0,
//                        height: 0))
//
//                self.viewPaymentSuccess.drawAnimatedCircularMask(
//                    startFrame: rect,
//                    duration: 0.33,
//                    revealType: RevealType.reveal) { [weak self] in
//                        self?.ImgPSTick.animation = "pop"
//                        self?.ImgPSTick.curve = "easeIn"
//                        self?.ImgPSTick.duration = 1.0
//                        self?.ImgPSTick.repeatCount = 1
//                        self?.ImgPSTick.animate()
//                }
//
//                if self.arrBookings.count != 0
//                {
//                    self.tableOrders.reloadData()
//                    self.tableOrders.layoutIfNeeded()
//                    self.tableOrders.isHidden = false
//                }
//                else
//                {
//                    self.tableOrders.isHidden = true
//                }
//
//                return
//            }
//
//
//        }
//
//
//    }
//
//    @IBAction func onGoHome(_ sender: Any)
//    {
//        let viewControllerSize = view.frame.size
//        let width = viewControllerSize.width
//        let height = viewControllerSize.height
//        let rect = CGRect(
//            origin: CGPoint(
//                x: width/2,
//                y: height/2),
//            size: CGSize(
//                width: 0,
//                height: 0))
//
//        viewPaymentSuccess.drawAnimatedCircularMask(
//            startFrame: rect,
//            duration: 0.33,
//            revealType: RevealType.unreveal) { [weak self] in
//                self?.viewPaymentSuccess.isHidden = true
//                appDelegate.dictPaymentSuccess.removeAll()
//        }
//
//    }
//
//    // MARK: - TableView DataSource
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    {
//        if tableView == tableOrders
//        {
//            return arrBookings.count
//        }
//        else
//        {
//            return arrCancelReason.count
//        }
//
//
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        if tableView == tableOrders
//        {
//            let dict = arrBookings[indexPath.row] as! NSDictionary
//            let isSelected = dict["isSelected"] as? String ?? ""
//            let strStatus = dict["Status"] as? String ?? ""
//            let PaymentStatus = dict["paidStatus"]
//            let strPaymentStatus = String(describing: PaymentStatus!)
//            let strPaymentType = dict["paymentType"] as? String ?? ""
//
//
//            var nHeight = 0
//            if strStatus == "ON THE WAY"
//            {
//                nHeight = 75
//            }
//            else  if strStatus == "PICKUP SUCCESS"
//            {
//                if strPaymentType != "Cash"
//                {
//                    if strPaymentStatus == "0"
//                    {
//                        nHeight = 75
//                    }
//                    else
//                    {
//                        nHeight = 0
//                    }
//                }
//                else
//                {
//                    nHeight = 0
//                }
//            }
//            else
//            {
//                nHeight = 0
//            }
//            if isSelected == "1"
//            {
//                self.arrStatus = dict["OrderStatus"] as! Array<Any>
//                let canCancel = dict["CanCancel"] as? String ?? ""
//                if canCancel == "Yes"
//                {
//                    let isPickupSuccess = dict["PickupSuccess"]
//                    let strisPickupSuccess = String(describing: isPickupSuccess!)
//                    if strisPickupSuccess == "0"
//                    {
//                        return CGFloat((arrStatus.count * 43) + 225 + nHeight) //225
//                    }
//                    else
//                    {
//                        return CGFloat((arrStatus.count * 43) + 265 + nHeight) //225
//                    }
//
//
//                }
//                else
//                {
//                    return CGFloat((arrStatus.count * 43) + 225 + nHeight) //265
//                }
//
//            }
//            return CGFloat(210 + nHeight)
//        }
//        else
//        {
//            return 50
//        }
//
//    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
//    {
//
//        if tableView == tableOrders
//        {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "OnGoingTableViewCell", for: indexPath) as! OnGoingTableViewCell
//            cell.selectionStyle = .none
//            let dictBooking = self.arrBookings[indexPath.row] as! Dictionary<String, Any>
//
//            //            let bookingID = dictBooking["id"]
//            //            let strBookingID = String(describing: bookingID!)
//            cell.lblBookingId.text = dictBooking["bookingId"] as? String ?? ""
//
//            let Qty = dictBooking["quantity"]
//            let strQty = String(describing: Qty!)
//
//
//            if strQty == ""
//            {
//                cell.lblQuantity.text = "Will be updated post pickup"
//                cell.lblQuantity.font = cell.lblQuantity.font.withSize(10)
//            }
//            else
//            {
//                cell.lblQuantity.text = strQty
//                cell.lblQuantity.font = cell.lblQuantity.font.withSize(14)
//            }
//
//            let strPaymentType = dictBooking["paymentType"] as? String ?? ""
//            cell.lblPaymentMode.text = strPaymentType.uppercased()
//
//            cell.lblStatus.text = dictBooking["Status"] as? String ?? ""
//            var strDescription = dictBooking["description"] as? String ?? ""
//            strDescription = "\"" + strDescription + "\""
//            cell.lblDescription.text = strDescription
//            let strTime = dictBooking["TimeSlot"] as? String ?? ""
//            cell.lblTimeSlot.text =  strTime
//            let strDate = dictBooking["bookingDate"] as? String ?? ""
//            var dateArr = strDate.components(separatedBy: "-")
//            let strDat: String = dateArr[0]
//            let strMon: String = dateArr[1]
//            cell.lblDate.text = strDat + "/" + strMon
//
//            cell.btnTrackYourOrder.tag = indexPath.row + 10000
//            cell.btnTrackYourOrder.addTarget(self, action: #selector(self.onTrackOrder(btn:)), for: .touchUpInside)
//
//            cell.btnTrackYourOrder1.tag = indexPath.row + 15000
//            cell.btnTrackYourOrder1.addTarget(self, action: #selector(self.onTrackOrder(btn:)), for: .touchUpInside)
//
//            cell.btnCancel.tag = indexPath.row + 20000
//            cell.btnCancel.addTarget(self, action: #selector(self.onCancel(btn:)), for: .touchUpInside)
//
//            let strCancel = dictBooking["CanCancel"] as? String ?? ""
//            if strCancel == "Yes"
//            {
//                cell.btnCancel.isHidden = false
//            }
//            else
//            {
//                cell.btnCancel.isHidden = true
//            }
//
//            cell.btnBillingDetails.tag = indexPath.row + 25000
//            cell.btnBillingDetails.addTarget(self, action: #selector(self.onBillingDetails(btn:)), for: .touchUpInside)
//            let attributeString1 = NSMutableAttributedString(string: "VIEW BILLING DETAILS",
//                                                             attributes: yourAttributes)
//            cell.btnBillingDetails.setAttributedTitle(attributeString1, for: .normal)
//
//            cell.viewDetailsWithColor.layoutIfNeeded()
//
//            let strStatus = dictBooking["Status"] as? String ?? ""
//            let PaymentStatus = dictBooking["paidStatus"]
//            let strPaymentStatus = String(describing: PaymentStatus!)
//
//
//            if strStatus == "CONFIRMED"
//            {
//                cell.imgStatusIcon.image = UIImage(named: "Confirmed")
//                cell.imgStatusIcon.frame.size.width = 35
//                cell.imgStatusIcon.center.x = cell.viewDetailsWithColor.bounds.midX
//                cell.imgStatusIcon.frame.size.height = 35
//                cell.imgStatusIcon.frame.origin.y =  cell.lblStatus.frame.origin.y - 40
//
//                cell.viewDriverDetails.isHidden = true
//                cell.viewTrackingTop.constant = 135
//
//                cell.viewDetails.layer.cornerRadius = 5
//                cell.viewDetails.clipsToBounds = true
//                cell.viewDetails.layer.borderColor  =  UIColor.lightGray.cgColor
//                cell.viewDetails.layer.borderWidth = 0.3
//                cell.viewDetails.layer.shadowOpacity = 0.8
//                cell.viewDetails.layer.shadowColor =  UIColor.darkGray.cgColor
//                cell.viewDetails.layer.shadowRadius = 3.0
//                cell.viewDetails.layer.shadowOffset = CGSize(width:0, height: 2)
//                cell.viewDetails.layer.masksToBounds = false
//                cell.viewDetailsWithColor.roundCorners([.topLeft, .bottomLeft], radius: 5)
//
//
//            }
//            else  if strStatus == "ON THE WAY"
//            {
//                cell.viewPayment.isHidden = true
//                let isPickupSuccess = dictBooking["PickupSuccess"]
//                let strisPickupSuccess = String(describing: isPickupSuccess!)
//                if strisPickupSuccess == "0"
//                {
//                    cell.imgStatusIcon.image = UIImage(named: "OnTheWayPickup")
//                    cell.viewDriverDetailsWithPay.isHidden = true
//
//                }
//                else
//                {
//                    cell.imgStatusIcon.image = UIImage(named: "OnTheWayDelivery")
//
//                    if strPaymentType != "Cash"
//                    {
//                        if strPaymentStatus == "0"
//                        {
//                            cell.viewDriverDetailsWithPay.isHidden = false
//                        }
//                        else
//                        {
//                            cell.viewDriverDetailsWithPay.isHidden = true
//                        }
//                    }
//                    else
//                    {
//                        cell.viewDriverDetailsWithPay.isHidden = true
//                    }
//
//                }
//
//                cell.imgStatusIcon.frame.size.width = 80
//                cell.imgStatusIcon.center.x = cell.viewDetailsWithColor.bounds.midX
//                cell.imgStatusIcon.frame.size.height = 22
//                cell.imgStatusIcon.frame.origin.y =  cell.lblStatus.frame.origin.y - 27
//
//
//                cell.viewDriverDetails.isHidden = false
//                cell.viewTrackingTop.constant = 205
//
//                cell.viewDetails.layoutIfNeeded()
//                cell.viewDetails.layer.cornerRadius = 0
//                cell.viewDetails.roundCorners([.topLeft, .topRight], radius: 5)
//                cell.viewDetails.clipsToBounds = true
//                cell.viewDetails.layer.borderColor  =  UIColor.lightGray.cgColor
//                cell.viewDetails.layer.borderWidth = 0.3
//                cell.viewDetails.layer.shadowOpacity = 0.8
//                cell.viewDetails.layer.shadowColor =  UIColor.darkGray.cgColor
//                cell.viewDetails.layer.shadowRadius = 3.0
//                cell.viewDetails.layer.shadowOffset = CGSize(width:0, height: 2)
//                cell.viewDetails.layer.masksToBounds = false
//
//
//                //  cell.viewDriverDetails.roundCorners([.bottomLeft, .bottomRight], radius: 5)
//                cell.viewDriverDetails.layer.cornerRadius = 5
//                cell.viewDriverDetails.clipsToBounds = true
//                cell.viewDriverDetails.layer.borderColor  =  UIColor.lightGray.cgColor
//                cell.viewDriverDetails.layer.borderWidth = 0.3
//                cell.viewDriverDetails.layer.shadowOpacity = 0.8
//                cell.viewDriverDetails.layer.shadowColor =  UIColor.darkGray.cgColor
//                cell.viewDriverDetails.layer.shadowRadius = 3.0
//                cell.viewDriverDetails.layer.shadowOffset = CGSize(width:0, height: 2)
//                cell.viewDriverDetails.layer.masksToBounds = false
//
//                cell.viewDetailsWithColor.roundCorners([.topLeft], radius: 5)
//
//                let dictDriverDetails = dictBooking["DeliveryUser"] as! Dictionary<String, Any>
//                cell.lblDriverNo.text = dictDriverDetails["mobile"] as? String ?? ""
//                cell.lblDriverName.text = dictDriverDetails["name"] as? String ?? ""
//
//                cell.lblDriverNoWithPay.text = dictDriverDetails["mobile"] as? String ?? ""
//                cell.lblDriverNameWithPay.text = dictDriverDetails["name"] as? String ?? ""
//
//
//                if dictDriverDetails["image"] as? String != nil
//                {
//                    var strImageURL = dictDriverDetails["image"] as? String ?? ""
//                    strImageURL = strImageURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
//                    //  cell.imgDriver.sd_setImage(with: URL(string: strImageURL), placeholderImage: UIImage(named: "User"), options: .refreshCached)
//                    cell.imgDriver.imageFromServerURL(urlString: strImageURL)
//                    cell.imgDriverWithPay.imageFromServerURL(urlString: strImageURL)
//                }
//                else
//                {
//                    //   cell.imgDriver.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: "User"), options: .refreshCached)
//
//                    cell.imgDriver.image = UIImage(named: "User")
//                    cell.imgDriverWithPay.image = UIImage(named: "User")
//                }
//
//                cell.btnCall.tag = indexPath.row + 30000
//                cell.btnCall.addTarget(self, action: #selector(self.onCall(btn:)), for: .touchUpInside)
//
//                cell.btnCallWithPay.tag = indexPath.row + 35000
//                cell.btnCallWithPay.addTarget(self, action: #selector(self.onCallWithPay(btn:)), for: .touchUpInside)
//
//                cell.btnPayWithPay.tag = indexPath.row + 45000
//                cell.btnPayWithPay.addTarget(self, action: #selector(self.onPayWithCall(btn:)), for: .touchUpInside)
//
//            }
//            else  if strStatus == "PICKUP SUCCESS"
//            {
//                cell.imgStatusIcon.image = UIImage(named: "Pickup Success")
//                cell.imgStatusIcon.frame.size.width = 35
//                cell.imgStatusIcon.center.x = cell.viewDetailsWithColor.bounds.midX
//                cell.imgStatusIcon.frame.size.height = 35
//                cell.imgStatusIcon.frame.origin.y =  cell.lblStatus.frame.origin.y - 40
//
//
//                if strPaymentType != "Cash"
//                {
//                    if strPaymentStatus == "0"
//                    {
//                        cell.viewPayment.isHidden = false
//
//                        cell.viewDriverDetails.isHidden = false
//                        cell.viewTrackingTop.constant = 205
//
//                        cell.viewDetails.layoutIfNeeded()
//                        cell.viewDetails.layer.cornerRadius = 0
//                        cell.viewDetails.roundCorners([.topLeft, .topRight], radius: 5)
//                        cell.viewDetails.clipsToBounds = true
//                        cell.viewDetails.layer.borderColor  =  UIColor.lightGray.cgColor
//                        cell.viewDetails.layer.borderWidth = 0.3
//                        cell.viewDetails.layer.shadowOpacity = 0.8
//                        cell.viewDetails.layer.shadowColor =  UIColor.darkGray.cgColor
//                        cell.viewDetails.layer.shadowRadius = 3.0
//                        cell.viewDetails.layer.shadowOffset = CGSize(width:0, height: 2)
//                        cell.viewDetails.layer.masksToBounds = false
//
//
//                        //  cell.viewDriverDetails.roundCorners([.bottomLeft, .bottomRight], radius: 5)
//                        cell.viewDriverDetails.layer.cornerRadius = 5
//                        cell.viewDriverDetails.clipsToBounds = true
//                        cell.viewDriverDetails.layer.borderColor  =  UIColor.lightGray.cgColor
//                        cell.viewDriverDetails.layer.borderWidth = 0.3
//                        cell.viewDriverDetails.layer.shadowOpacity = 0.8
//                        cell.viewDriverDetails.layer.shadowColor =  UIColor.darkGray.cgColor
//                        cell.viewDriverDetails.layer.shadowRadius = 3.0
//                        cell.viewDriverDetails.layer.shadowOffset = CGSize(width:0, height: 2)
//                        cell.viewDriverDetails.layer.masksToBounds = false
//
//                        cell.viewDetailsWithColor.roundCorners([.topLeft], radius: 5)
//
//                        cell.btnPay.tag = indexPath.row + 40000
//                        cell.btnPay.addTarget(self, action: #selector(self.onPay(btn:)), for: .touchUpInside)
//
//                    }
//                    else
//                    {
//                        cell.viewPayment.isHidden = true
//
//                        cell.viewDriverDetails.isHidden = true
//                        cell.viewTrackingTop.constant = 135
//
//                        cell.viewDetails.layer.cornerRadius = 5
//                        cell.viewDetails.clipsToBounds = true
//                        cell.viewDetails.layer.borderColor  =  UIColor.lightGray.cgColor
//                        cell.viewDetails.layer.borderWidth = 0.3
//                        cell.viewDetails.layer.shadowOpacity = 0.8
//                        cell.viewDetails.layer.shadowColor =  UIColor.darkGray.cgColor
//                        cell.viewDetails.layer.shadowRadius = 3.0
//                        cell.viewDetails.layer.shadowOffset = CGSize(width:0, height: 2)
//                        cell.viewDetails.layer.masksToBounds = false
//                        cell.viewDetailsWithColor.roundCorners([.topLeft, .bottomLeft], radius: 5)
//                    }
//                }
//                else
//                {
//                    cell.viewPayment.isHidden = true
//
//                    cell.viewDriverDetails.isHidden = true
//                    cell.viewTrackingTop.constant = 135
//
//                    cell.viewDetails.layer.cornerRadius = 5
//                    cell.viewDetails.clipsToBounds = true
//                    cell.viewDetails.layer.borderColor  =  UIColor.lightGray.cgColor
//                    cell.viewDetails.layer.borderWidth = 0.3
//                    cell.viewDetails.layer.shadowOpacity = 0.8
//                    cell.viewDetails.layer.shadowColor =  UIColor.darkGray.cgColor
//                    cell.viewDetails.layer.shadowRadius = 3.0
//                    cell.viewDetails.layer.shadowOffset = CGSize(width:0, height: 2)
//                    cell.viewDetails.layer.masksToBounds = false
//                    cell.viewDetailsWithColor.roundCorners([.topLeft, .bottomLeft], radius: 5)
//
//                }
//
//
//            }
//
//
//
//            let isSelected = dictBooking["isSelected"] as? String ?? ""
//
//            var progressBarPercentage = -2.5
//            var arrOrdSts = dictBooking["OrderStatus"] as! Array<Any>
//            for var j in 0..<arrOrdSts.count
//            {
//                var dictStatus = arrOrdSts[j] as! Dictionary<String, Any>
//                let strStatus = dictStatus["Status"] as? String ?? ""
//                if strStatus == "Yes"
//                {
//                    progressBarPercentage = progressBarPercentage + 2.5
//                }
//            }
//
//            if isSelected == "1"
//            {
//
//                let isPickupSuccess = dictBooking["PickupSuccess"]
//                let strisPickupSuccess = String(describing: isPickupSuccess!)
//                if strisPickupSuccess == "0"
//                {
//                    cell.btnBillingDetails.isHidden = true
//                }
//                else
//                {
//                    cell.btnBillingDetails.isHidden = false
//                }
//
//                cell.viewTracking.frame.size.height = 50
//                cell.progressBar.isHidden = false
//                cell.lblTrackYourOrder.isHidden = true
//                cell.btnTrackYourOrder.isHidden = true
//                UIView.animate(withDuration: 0.4, animations: {
//                    let arSts = dictBooking["OrderStatus"] as! Array<Any>
//
//                    let canCancel = dictBooking["CanCancel"] as? String ?? ""
//                    if canCancel == "Yes"
//                    {
//                        let isPickupSuccess = dictBooking["PickupSuccess"]
//                        let strisPickupSuccess = String(describing: isPickupSuccess!)
//                        if strisPickupSuccess == "0"
//                        {
//                            cell.viewTracking.frame.size.height = CGFloat((arSts.count * 43) + 65) //100
//                        }
//                        else
//                        {
//                            cell.viewTracking.frame.size.height = CGFloat((arSts.count * 43) + 100) //65
//                        }
//                    }
//                    else
//                    {
//                        cell.viewTracking.frame.size.height = CGFloat((arSts.count * 43) + 65) //100
//                    }
//
//
//                    cell.collectionViewHeight.constant = CGFloat(arSts.count * 43)
//                    cell.imgArrow.image = UIImage(named: "UpArrow")
//                    cell.progressBar.layoutIfNeeded()
//
//                    cell.OrderStatusShapeLayer?.removeFromSuperlayer()
//
//                    // create whatever path you want
//                    let path = UIBezierPath()
//                    path.move(to: CGPoint(x: 2, y: 0))
//                    let PrgsFill = Double(cell.progressBar.frame.size.height/10)
//                    let ProgressFill = PrgsFill * progressBarPercentage
//                    path.addLine(to: CGPoint(x: 2, y: ProgressFill))
//                    //path.addLine(to: CGPoint(x: 200, y: 240))
//
//                    // create shape layer for that path
//                    let shapeLayer = CAShapeLayer()
//                    shapeLayer.fillColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 0.4).cgColor
//                    shapeLayer.strokeColor = #colorLiteral(red: 0.09019607843, green: 0.7254901961, blue: 0.4705882353, alpha: 1).cgColor
//                    shapeLayer.lineWidth = 4
//                    shapeLayer.path = path.cgPath
//
//                    // animate it
//                    cell.progressBar.layer.addSublayer(shapeLayer)
//                    let animation = CABasicAnimation(keyPath: "strokeEnd")
//                    animation.fromValue = 0
//                    animation.duration = 2
//                    shapeLayer.add(animation, forKey: "MyAnimation")
//
//                    // save shape layer
//                    cell.OrderStatusShapeLayer = shapeLayer
//
//                }, completion: {
//                    (value: Bool) in
//                })
//            }
//            else
//            {
//                cell.viewTracking.frame.size.height = 50
//                cell.imgArrow.image = UIImage(named: "DownArrow")
//                cell.progressBar.isHidden = true
//                cell.btnBillingDetails.isHidden = true
//                cell.lblTrackYourOrder.isHidden = false
//                cell.btnTrackYourOrder.isHidden = false
//
//
//            }
//
//            return cell
//        }
//        else
//        {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CancelReasonTableViewCell", for: indexPath) as! CancelReasonTableViewCell
//
//            let dictCancel = self.arrCancelReason[indexPath.row] as! Dictionary<String, Any>
//            cell.lblReason.text = dictCancel["reasons"] as? String ?? ""
//
//            let reasonId = dictCancel["id"]
//            let strRsnId = String(describing: reasonId!)
//            if strCancelReasonId == strRsnId
//            {
//                cell.imgRadio.image = UIImage(named: "RadioOn")
//            }
//            else
//            {
//                cell.imgRadio.image = UIImage(named: "RadioOff")
//            }
//
//            return cell
//        }
//
//
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//        if tableView == tableOrders
//        {
//            guard let tableViewCell = cell as? OnGoingTableViewCell else { return }
//            tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
//            tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
//
//
//            let lastCell = self.arrBookings.count - 1
//            if indexPath.row == lastCell {
//                if currentPageNumber <  totalPages{
//                    currentPageNumber = currentPageNumber + 1
//                    self.getCurrentOrderList()
//                }
//            }
//
//            cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//            UIView.animate(withDuration: 0.6) {
//                cell.transform = CGAffineTransform.identity
//            }
//
//        }
//
//
//    }
//
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//        if tableView == tableOrders
//        {
//            guard let tableViewCell = cell as? OnGoingTableViewCell else { return }
//        }
//
//
//
//    }
//
//
//    // MARK: - TableView Delegate
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
//    {
//        if tableView == tableOrders
//        {
//
//        }
//        else
//        {
//            let dict = self.arrCancelReason[indexPath.row] as! Dictionary<String, Any>
//            let reasonId = dict["id"]
//            strCancelReasonId = String(describing: reasonId!)
//            tableCancelReason.reloadData()
//        }
//    }
//
//
//    // MARK: - ACTIONS
//    @objc func ClickonBackBtn()
//    {
//        _ = navigationController?.popViewController(animated: true)
//    }
//
//    @objc func onTrackOrder(btn:UIButton)
//    {
//        var btnTag = btn.tag - 10000
//        if btn.tag >= 15000
//        {
//            btnTag = btn.tag - 15000
//        }
//        else
//        {
//            btnTag = btn.tag - 10000
//        }
//
//        let indexpath = NSIndexPath(row:btnTag, section: 0)
//        var dictBookings = self.arrBookings[btnTag] as! Dictionary<String, Any>
//        let isSelected = dictBookings["isSelected"] as? String ?? ""
//        if isSelected == "1"
//        {
//            dictBookings["isSelected"] = "0"
//            let cell = tableOrders.cellForRow(at: indexpath as IndexPath) as! OnGoingTableViewCell?
//            let arSts = dictBookings["OrderStatus"] as! Array<Any>
//            cell?.viewTracking.frame.size.height = CGFloat((arSts.count * 43) + 100) //60
//            UIView.animate(withDuration: 0.4, animations: {
//                cell?.viewTracking.frame.size.height = 50
//            }, completion: {
//                (value: Bool) in
//                cell?.imgArrow.image = UIImage(named: "DownArrow")
//                cell?.progressBar.isHidden = true
//                self.arrBookings.remove(at: btnTag)
//                self.arrBookings.insert(dictBookings, at: btnTag)
//                self.tableOrders.reloadRows(at: [indexpath as IndexPath], with: .automatic)
//            })
//
//        }
//        else
//        {
//            dictBookings["isSelected"] = "1"
//            self.arrBookings.remove(at: btnTag)
//            self.arrBookings.insert(dictBookings, at: btnTag)
//            tableOrders.reloadRows(at: [indexpath as IndexPath], with: .automatic)
//        }
//
//
//
//    }
//
//    @objc func onCancel(btn:UIButton)
//    {
//        let btnTag = btn.tag - 20000
//        let dict = self.arrBookings[btnTag] as! Dictionary<String, Any>
//        let bookingID = dict["id"]
//        strBookingIdForCancel = String(describing: bookingID!)
//
//        strCancelReasonId = ""
//        self.getCancelReasonsList()
//    }
//
//    @objc func onBillingDetails(btn:UIButton)
//    {
//        let btnTag = btn.tag - 25000
//        let dict = self.arrBookings[btnTag] as! Dictionary<String, Any>
//        let bookingID = dict["id"]
//        strBookingIdForBillingDetails = String(describing: bookingID!)
//        self.performSegue(withIdentifier: "Services_Billing", sender: self)
//    }
//
//    @objc func onCall(btn:UIButton)
//    {
//        let btnTag = btn.tag - 30000
//        let dict = self.arrBookings[btnTag] as! Dictionary<String, Any>
//        var dictDriver = dict["DeliveryUser"] as! Dictionary<String, Any>
//        let strMobileNo = dictDriver["mobile"] as? String ?? ""
//
//        if let url = URL(string: "tel://\(strMobileNo)") {
//            if #available(iOS 10, *) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                UIApplication.shared.openURL(url as URL)
//            }
//        }
//
//    }
//
//    @objc func onCallWithPay(btn:UIButton)
//    {
//        let btnTag = btn.tag - 35000
//        let dict = self.arrBookings[btnTag] as! Dictionary<String, Any>
//        var dictDriver = dict["DeliveryUser"] as! Dictionary<String, Any>
//        let strMobileNo = dictDriver["mobile"] as? String ?? ""
//
//        if let url = URL(string: "tel://\(strMobileNo)") {
//            if #available(iOS 10, *) {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            } else {
//                UIApplication.shared.openURL(url as URL)
//            }
//        }
//
//    }
//
//
//    @objc func onPay(btn:UIButton)
//    {
//        let btnTag = btn.tag - 40000
//        let dict = self.arrBookings[btnTag] as! Dictionary<String, Any>
//        let bookingID = dict["id"]
//        strBookingIdForPayment = String(describing: bookingID!)
//        let totalPayment = dict["totalPayment"]
//        strPayableAmount = String(describing: totalPayment!)
//        let strPaymentType = dict["paymentType"] as? String ?? ""
//
//        if strPaymentType == "Card"
//        {
//            self.getOrderId()
//        }
//        else if strPaymentType == "Wallet"
//        {
//            self.performSegue(withIdentifier: "onGoing_WalletPayment", sender: self)
//        }
//
//
//    }
//
//    @objc func onPayWithCall(btn:UIButton)
//    {
//        let btnTag = btn.tag - 45000
//        let dict = self.arrBookings[btnTag] as! Dictionary<String, Any>
//        let bookingID = dict["id"]
//        strBookingIdForPayment = String(describing: bookingID!)
//        let totalPayment = dict["totalPayment"]
//        strPayableAmount = String(describing: totalPayment!)
//        let strPaymentType = dict["paymentType"] as? String ?? ""
//
//        if strPaymentType == "Card"
//        {
//            self.getOrderId()
//        }
//        else if strPaymentType == "Wallet"
//        {
//            self.performSegue(withIdentifier: "onGoing_WalletPayment", sender: self)
//        }
//    }
//
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//
//        if (segue.identifier == "Services_Billing")
//        {
//            let billingVC = segue.destination as! BillingDetailsVC
//            billingVC.strBookingId = strBookingIdForBillingDetails
//
//        }
//        else if (segue.identifier == "onGoing_WalletPayment")
//        {
//            let WalletPaymentVC = segue.destination as! WalletPaymentVC
//            WalletPaymentVC.strBookingID = strBookingIdForPayment
//            WalletPaymentVC.strPayebleAmout = strPayableAmount
//
//        }
//    }
//
//
//    // MARK: - CollectionView
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
//    {
//        let dict = arrBookings[collectionView.tag] as! NSDictionary
//        self.arrStatus = dict["OrderStatus"] as! Array<Any>
//        return arrStatus.count
//
//    }
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
//    {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpandDataCollectionViewCell", for: indexPath) as! ExpandDataCollectionViewCell
//        let dict = arrBookings[collectionView.tag] as! NSDictionary
//
//        let isSelected = dict["isSelected"] as? String ?? ""
//        if isSelected == "1"
//        {
//            let arSts = dict["OrderStatus"] as! Array<Any>
//            let dictSts = arSts[indexPath.row] as! NSDictionary
//            cell.lblStatus.text =  dictSts["name"] as? String ?? ""
//
//            let strStatus = dictSts["Status"] as? String ?? ""
//            if strStatus  == "Yes"
//            {
//                cell.lblStatus.textColor = UIColor(red: 23/255, green: 185/255, blue: 120/255, alpha: 1.0) // Green
//                cell.viewDot.backgroundColor = UIColor(red: 23/255, green: 185/255, blue: 120/255, alpha: 1.0) // Green
//            }
//            else
//            {
//                cell.lblStatus.textColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 0.3) // Gray
//                cell.viewDot.backgroundColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 0.3) // Gray
//            }
//        }
//        else
//        {
//            cell.lblStatus.textColor = UIColor.clear
//            cell.viewDot.backgroundColor = UIColor.clear
//        }
//
//
//
//
//        return cell
//    }
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 2.0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout
//        collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 5.0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
//    {
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
//        layout.invalidateLayout()
//        return CGSize(width: collectionView.frame.width , height:40)
//    }
//
//
//    func convertToDictionary(text: String) -> [String: Any]? {
//        if let data = text.data(using: .utf8) {
//            do {
//                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//        return nil
//    }
//
//}
//
///*
//
// var progressBarPercentage = -2.5
// var arrOrdSts = dictBooking["OrderStatus"] as! Array<Any>
// for var j in 0..<arrOrdSts.count
// {
// var dictStatus = arrOrdSts[j] as! Dictionary<String, Any>
// let strStatus = dictStatus["Status"] as? String ?? ""
// if strStatus == "Yes"
// {
// progressBarPercentage = progressBarPercentage + 2.5
// }
// }
//
//
// let PrgsFill = Double(cell.progressBar.frame.size.height/10)
// let ProgressFill = PrgsFill * progressBarPercentage
//
// */
//
//// MARK: Paytm Delegate methods.
//extension OnGoingServices : PGTransactionDelegate{
//    func didFinishedResponse(_ controller: PGTransactionViewController!, response responseString: String!)
//    {
//        var dictPaymentSuccess = convertToDictionary(text: responseString)
//        self.dismiss(animated: true, completion: nil)
//        let dict = dictPaymentSuccess as! Dictionary<String, Any>
//
//        dictPaymentSuccess!["bookingId"] = strBookingIdForPayment
//        dictPaymentSuccess!["paymentType"] = "Service"
//        appDelegate.arrPaytmRsponse.append(dictPaymentSuccess!)
//        let PaytmRsponsesData = NSKeyedArchiver.archivedData(withRootObject: appDelegate.arrPaytmRsponse)
//        userDefaults.set(PaytmRsponsesData, forKey: "PaytmRsponse")
//
//        let strTransStatus = dict["STATUS"] as? String ?? ""
//        self.ShowAlert(msg: strTransStatus)
//
//        self.CardPaymentAPICallOnPaymentSuccess(response: dictPaymentSuccess!)
//
//        //        if strTransStatus == "TXN_SUCCESS"
//        //        {
//        //            self.CardPaymentAPICallOnPaymentSuccess(response: dictPaymentSuccess!)
//        //        }
//
//
//    }
//
//    func didCancelTrasaction(_ controller: PGTransactionViewController!)
//    {
//        self.dismiss(animated: true, completion: nil)
//        self.UserCancelledTransactionAPICall()
//    }
//
//    func errorMisssingParameter(_ controller: PGTransactionViewController!, error: Error!) {
//        print(error)
//        // showAlert(title: "Transaction Failed", message: error.localizedDescription)
//        self.dismiss(animated: true, completion: nil)
//        self.ShowAlert(msg: error.localizedDescription)
//    }
//
//
//
//}












