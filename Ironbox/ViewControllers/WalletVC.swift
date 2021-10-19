//
//  WalletVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 07/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Alamofire
import Spring
import Razorpay




class WalletVC: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var viewBG: SpringView!
    @IBOutlet weak var txtEnterAmount: UITextField!
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var lblCreditAmount: UILabel!
    @IBOutlet weak var lblRefferalAmount: UILabel!
    @IBOutlet weak var txtPromoCode: UITextField!

    var merchant:PGMerchantConfiguration!
    var strOrderId = ""
    var razorpayObj : RazorpayCheckout? = nil
    // var razorpay: Razorpay!
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setFontFamilyAndSize()
        self.hideKeyboardWhenTappedAround()
        self.addDoneButtonOnKeyboard()
        appDelegate.strOfferCode = ""
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]
        
        self.navigationItem.hidesBackButton = true
        let btnBack = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItems([item], animated: true)
        //razorpayObj = RazorpayCheckout.initWithKey("rzp_live_vq8tmnnZmbWVkx", andDelegate: self)
        razorpayObj = RazorpayCheckout.initWithKey("rzp_live_vq8tmnnZmbWVkx", andDelegateWithData: self)
        
        //        razorpay = Razorpay.initWithKey("", andDelegate: self)
        

        self.txtEnterAmount.delegate = self
        self.lblTotalAmount.text = "Rs. 00"
        self.lblCreditAmount.text = "Rs. 00"
        self.lblRefferalAmount.text = "Rs. 00"
        
        self.viewBG.isHidden = true
        self.getWalletAmount()
        self.setMerchant()//initialize merchant with config.
        
    }
    override func viewWillAppear(_ animated: Bool)
    {

        txtPromoCode.text = appDelegate.strOfferCode
    }
    //
    //    override func viewDidAppear(_ animated: Bool)
    //      {
    //          self.showPaymentForm()
    //
    //      }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        self.txtEnterAmount.attributedPlaceholder = NSAttributedString(string: "Enter your amount",
                                                                       attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0)])
        self.txtEnterAmount.layer.borderWidth = 1
        self.txtEnterAmount.layer.borderColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:0.43).cgColor
        self.txtEnterAmount.layer.masksToBounds = true
        self.txtEnterAmount.setLeftPaddingPoints(10)
        
        self.txtPromoCode.attributedPlaceholder = NSAttributedString(string: "Enter promo code",
                                                                     attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0)])
        self.txtPromoCode.layer.borderWidth = 1
        self.txtPromoCode.layer.borderColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:0.43).cgColor
        self.txtPromoCode.layer.masksToBounds = true
        self.txtPromoCode.setLeftPaddingPoints(10)
        
    }
    
    @objc func getWalletAmount()
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(GET_AMOUNT_WALLET, params: nil, headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                
                let nAmount = json.value(forKey: "wallet_amount")
                let strAmount = String(describing: nAmount!)
                self.lblTotalAmount.text = "Rs. " + strAmount

                let nAmount1 = json.value(forKey: "credit_amount")
                let strAmount1 = String(describing: nAmount1!)
                self.lblCreditAmount.text = "Rs. " + strAmount1
                
                let nAmount2 = json.value(forKey: "referral_amount")
                let strAmount2 = String(describing: nAmount2!)
                self.lblRefferalAmount.text = "Rs. " + strAmount2
                
                self.viewBG.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
                {
                    self.viewBG.isHidden = false
                    self.viewBG.animation = "squeezeLeft"
                    self.viewBG.curve = "easeIn"
                    self.viewBG.duration = 1.5
                    self.viewBG.repeatCount = 1
                    self.viewBG.animate()
                    
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
    
    @objc func validatePromoCode()
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        let param: [String: Any] = [
            "offer_code":txtPromoCode.text!
        ]
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(VALIDATE_OFFERS, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                self.getOrderId()
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
                self.showPaymentForm()
                //self.onGenerateCheckSum()
                
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
        parameters = ["MID":MERCHANT_ID,"ORDER_ID":strOrderId ,"INDUSTRY_TYPE_ID":INDUSTRYTYPEID,"CHANNEL_ID":CHANNELID,"TXN_AMOUNT":txtEnterAmount.text!,"WEBSITE":WEBSITE, "CUST_ID":strCustomerId,"CALLBACK_URL":strCallBackURL,"MOBILE_NO":strCustomerId ,"EMAIL_ID":strEmail] as? [String : String]
        
        
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
        
        /*
         parameters = ["MID":"zerode40008007001297","ORDER_ID":"ORDS15123844" ,"INDUSTRY_TYPE_ID":"Retail109","CHANNEL_ID":"WAP","TXN_AMOUNT":"1.00","WEBSITE":"APPPROD", "CHECKSUMHASH":"Gs+iK+qoLkxO8V/rDMEkm0rYR36Zm5TuvXSDt27hvBx9DvaOFRuff4l/SjHL7VvrrFDBZviYO0mj3VMFnGbUYh52PUcIvGkfAchPYWCwtU4=" ,"CUST_ID":"CUST001","CALLBACK_URL":"https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=ORDS15123844", "MOBILE_NO":"9944146639" ,"EMAIL_ID":"gopal@pyramidions.in"] as? [String : String]

         */
        
        var parameters:[String:String]?
        parameters = ["MID":MERCHANT_ID,"ORDER_ID":strOrderId ,"INDUSTRY_TYPE_ID":INDUSTRYTYPEID,"CHANNEL_ID":CHANNELID,"TXN_AMOUNT":txtEnterAmount.text!,"WEBSITE":WEBSITE, "CHECKSUMHASH":strCheckSum ,"CUST_ID":strCustomerId,"CALLBACK_URL":strCallBackURL, "MOBILE_NO":strCustomerId ,"EMAIL_ID":strEmail, "PAY_TYPE":"wallet"] as? [String : String]
        
        print(parameters!)
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
                    transaction!.serverType = eServerTypeStaging
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
    
    @IBAction func onOffers(_ sender: Any)
    {
        view.endEditing(true)
        appDelegate.strOfferType = "Wallet"
        guard let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ApplyOffersVC") else { return }
        let navController = UINavigationController(rootViewController: myVC)
        
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    // MARK: - ACTIONS
    @objc func ClickonBackBtn()
    {
        view.endEditing(true)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onAmount1(_ sender: Any)
    {
        if txtEnterAmount.text != ""
        {
            let strAmt = txtEnterAmount.text
            var nAmt = Int(strAmt!)
            nAmt = nAmt! + 50
            txtEnterAmount.text = String(describing: nAmt!)
            
        }
        else
        {
            txtEnterAmount.text = "50"
        }
        
    }
    @IBAction func onAmount2(_ sender: Any)
    {
        if txtEnterAmount.text != ""
        {
            let strAmt = txtEnterAmount.text
            var nAmt = Int(strAmt!)
            nAmt = nAmt! + 100
            txtEnterAmount.text = String(describing: nAmt!)
            
        }
        else
        {
            txtEnterAmount.text = "100"
        }
    }
    @IBAction func onAmount3(_ sender: Any)
    {
        if txtEnterAmount.text != ""
        {
            let strAmt = txtEnterAmount.text
            var nAmt = Int(strAmt!)
            nAmt = nAmt! + 500
            txtEnterAmount.text = String(describing: nAmt!)
            
        }
        else
        {
            txtEnterAmount.text = "500"
        }
    }
    @IBAction func onAmount4(_ sender: Any)
    {
        if txtEnterAmount.text != ""
        {
            let strAmt = txtEnterAmount.text
            var nAmt = Int(strAmt!)
            nAmt = nAmt! + 1000
            txtEnterAmount.text = String(describing: nAmt!)
            
        }
        else
        {
            txtEnterAmount.text = "1000"
        }
    }
    
    @IBAction func onViewTransactions(_ sender: Any)
    {
        
    }
    
    @IBAction func onAddMoney(_ sender: Any)
    {
        view.endEditing(true)
        let strAmount = txtEnterAmount.text
        let nAmount = Int(strAmount ?? "0")
        if txtEnterAmount.text == "" || (txtEnterAmount.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!
        {
            ShowAlert(msg: "Please enter your amount")
        }
        else if nAmount! < 50
        {
            ShowAlert(msg: "Please add minimum Rs.50")
        } else {
            if txtPromoCode.text == "" {
                  self.getOrderId()
            } else {
                 self.validatePromoCode()
            }
            
        }
        
    }

    internal func showPaymentForm() {

        let options: [AnyHashable:Any] = [
            "prefill": [
                "contact": userDefaults.object(forKey: USER_MOBILE) as? String,
                "email": userDefaults.object(forKey: USER_EMAIL) as? String
            ],
            "image": "http://13.126.228.76/Ironbox_new/public/images/ironbox.png",
            "amount" : Double("\(txtEnterAmount.text ?? "0.0")")! * 100.0,
            "currency": "INR",
            "name": "VOLUNTAD INDIA PVT LTD",
            "theme": [
                "color": "#1A3C5C"
            ]
            // follow link for more options - https://razorpay.com/docs/payment-gateway/web-integration/standard/checkout-form/
        ]
        if let rzp = self.razorpayObj {
            rzp.open(options)
        } else {
            print("Unable to initialize")
        }
        // razorpay.open(options)
        
    }
    
    func AddMoneyAPICallOnPaymentSuccess(response: Dictionary<String, Any>)
    {
        view.endEditing(true)
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        let strTransId = response["TXNID"] as? String ?? ""
       // let strOrdId = response["ORDERID"] as? String ?? ""
        let strTranStatus = response["STATUS"] as? String ?? ""
        let strTransAmount = response["TXNAMOUNT"] as? String ?? ""
//        let strCheckSum = response["CHECKSUMHASH"] as? String ?? ""
        let strPaymentMode = response["PAYMENTMODE"] as? String ?? ""
        let promoCode = response["PROMOCODE"] as? String ?? ""

        
        let param: [String: Any] = [
            "orderId": self.strOrderId,
            "tnx_status":"SUCCESS",
            "txn_amount":strTransAmount,
            "payment_mode":"wallet",
            "transactionId": strTransId,
            "promocode": txtPromoCode.text == "" ? "0" : txtPromoCode.text ?? "0",
            "full_amount": lblTotalAmount.text ?? "0"
        ]
        print(param)
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(ADD_AMOUNT_WALLET, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false"){
                self.txtEnterAmount.text = ""
                self.txtPromoCode.text = ""
                appDelegate.strOfferCode = ""
                let strOrderId = json.value(forKey: "orderId")as? String ?? ""
                
                let PaytmRsponsesData = userDefaults.object(forKey: "PaytmRsponse") as? NSData
                if let PaytmRsponsesData = PaytmRsponsesData {
                    appDelegate.arrPaytmRsponse = NSKeyedUnarchiver.unarchiveObject(with: PaytmRsponsesData as Data) as! Array<Any>
                    /*
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
 */
                }
                
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
                self.getWalletAmount()
            } else {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
            }
            
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
        })
    }

 /*

    func OneClickPayment() {

     view.endEditing(true)
     self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))

     let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
     let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]

     let strTransId = response["TXNID"] as? String ?? ""
     // let strOrdId = response["ORDERID"] as? String ?? ""
     let strTranStatus = response["STATUS"] as? String ?? ""
     let strTransAmount = response["TXNAMOUNT"] as? String ?? ""
     //        let strCheckSum = response["CHECKSUMHASH"] as? String ?? ""
     let strPaymentMode = response["PAYMENTMODE"] as? String ?? ""
     let promoCode = response["PROMOCODE"] as? String ?? ""


     let param: [String: Any] = [
     "orderId": self.strOrderId,
     "tnx_status":"SUCCESS",
     "txn_amount":strTransAmount,
     "payment_mode":"wallet",
     "transactionId": strTransId,
     "promocode": txtPromoCode.text == "" ? "0" : txtPromoCode.text ?? "0",
     "full_amount": lblTotalAmount.text ?? "0"
     ]
     print(param)
     self.CheckNetwork()

     AlamofireHC.requestPOST(ADD_AMOUNT_WALLET, params: param as [String : AnyObject], headers: header, success: { (JSON) in
     UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
     let  result = JSON.dictionaryObject
     let json = result! as NSDictionary
     let err = json.value(forKey: "error") as? String ?? ""
     if (err == "false"){
     self.txtEnterAmount.text = ""
     self.txtPromoCode.text = ""
     appDelegate.strOfferCode = ""
     let strOrderId = json.value(forKey: "orderId")as? String ?? ""

     let PaytmRsponsesData = userDefaults.object(forKey: "PaytmRsponse") as? NSData
     if let PaytmRsponsesData = PaytmRsponsesData {
     appDelegate.arrPaytmRsponse = NSKeyedUnarchiver.unarchiveObject(with: PaytmRsponsesData as Data) as! Array<Any>
     /*
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
     */
     }

     let errorMessage = json.value(forKey: "error_message")as? String ?? ""
     self.ShowAlert(msg: errorMessage)
     self.getWalletAmount()
     } else {
     let errorMessage = json.value(forKey: "error_message")as? String ?? ""
     self.ShowAlert(msg: errorMessage)
     }

     }, failure: { (error) in
     UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
     print(error)
     })
















    }


*/

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
    
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    // MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtEnterAmount
        {
            let  maxLength = 5
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        
        return true
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        done.tintColor = UIColor.black
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        txtEnterAmount.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        txtEnterAmount.resignFirstResponder()
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

// MARK: Paytm Delegate methods.
extension WalletVC : PGTransactionDelegate {
    func didFinishedResponse(_ controller: PGTransactionViewController!, response responseString: String!)
    {
        var dictPaymentSuccess = convertToDictionary(text: responseString)
        self.dismiss(animated: true, completion: nil)
        let dict = dictPaymentSuccess as! Dictionary<String, Any>
        
        dictPaymentSuccess!["paymentType"] = "Wallet"
        dictPaymentSuccess!["offer_code"] = txtPromoCode.text!
        appDelegate.arrPaytmRsponse.append(dictPaymentSuccess!)
        let PaytmRsponsesData = NSKeyedArchiver.archivedData(withRootObject: appDelegate.arrPaytmRsponse)
        userDefaults.set(PaytmRsponsesData, forKey: "PaytmRsponse")

        let strTransStatus = dict["STATUS"] as? String ?? ""
        
        if strTransStatus == "TXN_FAILURE"
        {
            self.ShowAlert(msg: "Transaction failed. Please try again later")
        }
        else
        {
            self.ShowAlert(msg: strTransStatus)
        }
        
        self.AddMoneyAPICallOnPaymentSuccess(response: dictPaymentSuccess!)
        
        //        if strTransStatus == "TXN_SUCCESS"
        //        {
        //            self.AddMoneyAPICallOnPaymentSuccess(response: dictPaymentSuccess!)
        //        }
        
    }
    
    func didCancelTrasaction(_ controller: PGTransactionViewController!)
    {
        self.dismiss(animated: true, completion: nil)
        self.UserCancelledTransactionAPICall()
        // self.ShowAlert(msg: "Payment cancelled")
    }
    
    func errorMisssingParameter(_ controller: PGTransactionViewController!, error: Error!) {
        print(error)
        // showAlert(title: "Transaction Failed", message: error.localizedDescription)
        self.dismiss(animated: true, completion: nil)
        self.ShowAlert(msg: error.localizedDescription)
    }
    
    public func onPaymentError(_ code: Int32, description str: String){
        
        
        let alertController = UIAlertController(title: "FAILURE", message: str, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.view.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }

    public func onPaymentSuccess(_ payment_id: String)
    {
         self.ShowAlert(msg: payment_id)

        let alertController = UIAlertController(title: "SUCCESS", message: "Payment Id \(payment_id)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.view.window?.rootViewController?.present(alertController, animated: true, completion: nil)

    }
    
    
    /*
     func didSucceedTransaction(_ controller: PGTransactionViewController!, response: [AnyHashable : Any]!) {
     print(response)
     showAlert(title: "Transaction Successfull", message: NSString.localizedStringWithFormat("Response- %@", response) as String)
     }


     func didFailTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
     print(error)
     showAlert(title: "Transaction Failed", message: error.localizedDescription)
     }
     func didCancelTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {

     showAlert(title: "Transaction Cancelled", message: error.localizedDescription)

     }

     func didFinishCASTransaction(_ controller: PGTransactionViewController!, response: [AnyHashable : Any]!) {
     print(response)
     showAlert(title: "cas", message: "")
     }

     */
    
}

/*
 // RazorpayPaymentCompletionProtocol - This will execute two methods 1.Error and 2. Success case. On payment failure you will get a code and description. In payment success you will get the payment id.
 extension WalletVC : RazorpayPaymentCompletionProtocol {

 func onPaymentError(_ code: Int32, description str: String) {
 print("error: ", code, str)
 self.presentAlert(withTitle: "Alert", message: str)
 }

 func onPaymentSuccess(_ payment_id: String) {
 print("success: ", payment_id)
 self.presentAlert(withTitle: "Success", message: "Payment Succeeded")
 }
 }
*/
 // RazorpayPaymentCompletionProtocolWithData - This will returns you the data in both error and success case. On payment failure you will get a code and description. In payment success you will get the payment id.
 extension WalletVC: RazorpayPaymentCompletionProtocolWithData {

 func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
    self.ShowAlert(msg: description)

 print("error: ", code)
 //self.presentAlert(withTitle: "Alert", message: str)
 }

 func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
 print("success: ", payment_id)

    /*
     let strTransId = response["TXNID"] as? String ?? ""
     let strOrdId = response["ORDERID"] as? String ?? ""
     let strTranStatus = response["STATUS"] as? String ?? ""
     let strTransAmount = response["TXNAMOUNT"] as? String ?? ""
     let strCheckSum = response["CHECKSUMHASH"] as? String ?? ""
     let strPaymentMode = response["PAYMENTMODE"] as? String ?? ""

     let strTransDate = response["TXNDATE"] as? String ?? ""
     let strBankName = response["BANKNAME"] as? String ?? ""
     let strBankTransID = response["BANKTXNID"] as? String ?? "
     */
    self.ShowAlert(msg: payment_id)

    var dictPaymentSuccess = response as! [String : Any]
    self.dismiss(animated: true, completion: nil)
    _ = dictPaymentSuccess


    dictPaymentSuccess["TXNID"] = payment_id
    dictPaymentSuccess["STATUS"] = "SUCCESS"
    dictPaymentSuccess["TXNAMOUNT"] = txtEnterAmount.text
    dictPaymentSuccess["PAYMENTMODE"] = "Wallet"
    appDelegate.arrPaytmRsponse.append(dictPaymentSuccess)
    let PaytmRsponsesData = NSKeyedArchiver.archivedData(withRootObject: appDelegate.arrPaytmRsponse)
    userDefaults.set(PaytmRsponsesData, forKey: "PaytmRsponse")
    self.ShowAlert(msg: "Transaction Success")
    self.AddMoneyAPICallOnPaymentSuccess(response: dictPaymentSuccess)
 //self.presentAlert(withTitle: "Success", message: "Payment Succeeded")
 }
 }

