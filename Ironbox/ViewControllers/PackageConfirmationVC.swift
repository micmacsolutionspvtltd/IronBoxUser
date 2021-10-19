//
//  PackageConfirmationVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 22/06/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Alamofire
import Spring

class PackageConfirmationVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var lblRatePerCloth: UILabel!
    @IBOutlet weak var lblTotalClothes: UILabel!
    @IBOutlet weak var lblOriginalRate: UILabel!
    @IBOutlet weak var lblPackageDetail: UILabel!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var txtQuantity: UITextField!
    
    var dictPackage = Dictionary<String,Any>()
    var merchant:PGMerchantConfiguration!
    var strOrderId = ""
    var strPayableCost = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setFontFamilyAndSize()
        self.hideKeyboardWhenTappedAround()
        self.addDoneButtonOnKeyboard()
        txtQuantity.delegate = self
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]
        
        self.navigationItem.hidesBackButton = true
        let btnBack = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItems([item], animated: true)
        
        lblOriginalRate.text = dictPackage["actual_price"] as? String ?? ""
        lblRatePerCloth.text = dictPackage["price"] as? String ?? ""
        lblTotalClothes.text = dictPackage["no_of_clothes"] as? String ?? ""
        lblPackageDetail.text = dictPackage["packages_cost"] as? String ?? ""
        
         self.setMerchant()//initialize merchant with config.
    }

    override func viewWillLayoutSubviews()
    {
        lblOriginalRate.layer.cornerRadius = lblOriginalRate.frame.size.height/2
        lblOriginalRate.clipsToBounds = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ACTIONS
    
    @objc func ClickonBackBtn()
    {
        appDelegate.IsfromPackageConfirmation = true
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onPay(_ sender: Any)
    {
        view.endEditing(true)
        let strQty = txtQuantity.text
        let nQty = Int(strQty!)
        if txtQuantity.text == "" || (txtQuantity.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!
        {
            ShowAlert(msg: "Please enter package quantity")
        }
        else if nQty! < 1
        {
            ShowAlert(msg: "Please enter valid package quantity")
        }
        else
        {
            var payableCost = dictPackage["payablecost"] as! Int
            payableCost = payableCost * nQty!
            strPayableCost = String(describing: payableCost)
            
            self.getOrderId()
        }
        
    }

    func setMerchant(){
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
        parameters = ["MID":MERCHANT_ID,"ORDER_ID":strOrderId ,"INDUSTRY_TYPE_ID":INDUSTRYTYPEID,"CHANNEL_ID":CHANNELID,"TXN_AMOUNT":strPayableCost,"WEBSITE":WEBSITE, "CUST_ID":strCustomerId,"CALLBACK_URL":strCallBackURL, "MOBILE_NO":strCustomerId ,"EMAIL_ID":strEmail] as? [String : String]
        
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
        parameters = ["MID":MERCHANT_ID,"ORDER_ID":strOrderId ,"INDUSTRY_TYPE_ID":INDUSTRYTYPEID,"CHANNEL_ID":CHANNELID,"TXN_AMOUNT":strPayableCost,"WEBSITE":WEBSITE, "CHECKSUMHASH":strCheckSum ,"CUST_ID":strCustomerId,"CALLBACK_URL":strCallBackURL, "MOBILE_NO":strCustomerId ,"EMAIL_ID":strEmail, "PAY_TYPE":"package"] as? [String : String]
        
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
    
    func AddPackageAPICallOnPaymentSuccess(response: Dictionary<String, Any>)
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
        
        let packageID = dictPackage["id"]
        let strPackageID = String(describing: packageID!)
        
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
            "quantity":txtQuantity.text!,
            "packageId": strPackageID
        ]
        
       
        self.CheckNetwork()
        print(param)
        AlamofireHC.requestPOST(PAYMENT_PACKAGES, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            print(json)
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
                
                self.txtQuantity.text = ""
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                
                let alertController = UIAlertController(title: ALERT_TITLE, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    appDelegate.IsfromPackageConfirmation = true
                    _ = self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        
        txtQuantity.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        txtQuantity.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtQuantity
        {
            
            let  maxLength = 2
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
            
        }
        
        return false
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
extension PackageConfirmationVC : PGTransactionDelegate{
    func didFinishedResponse(_ controller: PGTransactionViewController!, response responseString: String!)
    {
        var dictPaymentSuccess = convertToDictionary(text: responseString)
        self.dismiss(animated: true, completion: nil)
        let dict = dictPaymentSuccess as! Dictionary<String, Any>
        
        let packageID = dictPackage["id"]
        let strPackageID = String(describing: packageID!)
        
        dictPaymentSuccess!["quantity"] = txtQuantity.text!
        dictPaymentSuccess!["packageID"] = strPackageID
        dictPaymentSuccess!["paymentType"] = "Package"
        appDelegate.arrPaytmRsponse.append(dictPaymentSuccess!)
        let PaytmRsponsesData = NSKeyedArchiver.archivedData(withRootObject: appDelegate.arrPaytmRsponse)
        userDefaults.set(PaytmRsponsesData, forKey: "PaytmRsponse")
        
        let strTransStatus = dict["STATUS"] as? String ?? ""
        self.ShowAlert(msg: strTransStatus)
        self.AddPackageAPICallOnPaymentSuccess(response: dictPaymentSuccess!)
        
//        if strTransStatus == "TXN_SUCCESS"
//        {
//            self.AddPackageAPICallOnPaymentSuccess(response: dictPaymentSuccess!)
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
