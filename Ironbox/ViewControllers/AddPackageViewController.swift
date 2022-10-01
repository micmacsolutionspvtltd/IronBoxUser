//
//  AddPackageViewController.swift
//  Ironbox
//
//  Created by MAC on 20/04/22.
//  Copyright © 2022 Gopalsamy A. All rights reserved.
//

import UIKit
import Razorpay
import Alamofire
import Toaster

class AddPackageViewController: UIViewController {
    @IBOutlet weak var packageTableView: UITableView!
    
    var strOrderId = ""
     var packageId = ""
    var packageAmount = ""
    var buyBtnShow = false
    var razorpayObj : RazorpayCheckout? = nil
    fileprivate var packageData : SubscriptionModel?
    {
        didSet
        {
            packageTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
   prepareViews()
        getSubscriptionApi()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    private func prepareViews(){
        packageTableView?.register(AddPackageTableViewCell.nib, forCellReuseIdentifier: AddPackageTableViewCell.identifier)
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]
        
        self.navigationItem.hidesBackButton = true
        let btnBack = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnBack)
        razorpayObj = RazorpayCheckout.initWithKey("rzp_live_li9Fr16AIXoqpK", andDelegateWithData: self)
      //  razorpayObj = RazorpayCheckout.initWithKey("rzp_test_Ah4i08pOreY6XZ", andDelegateWithData: self)
    }
    func getSubscriptionApi(){
        view.addSubview(UIView().customActivityIndicator(view: (self.view)!, widthView: nil, message: "Loading"))

        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        var param: [String: Any] = ["":""]
       
        AlamofireHC.requestPOSTMethod(SUBSCRIPTION_VALUE, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            let results : Data? = JSON
            UIView().hideLoader(removeFrom: (self.view)!)

            if results != nil{
                do
                {
                let response = try JSONDecoder().decode(SubscriptionModel.self, from: results!)
                  
                    if response.packs?.count == 0{
                        Toast(text: "No packages available now", duration: 2.5).show()
                    }else{
                        self.packageData = response
                    }

                }  catch let error as NSError
                {
                    print(error)
                }
            }else{
               
                print("Something Went wrong")
            }

       
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.view)!)
            print(error)
        })
    }
    @IBAction func backBtnClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @objc func ClickonBackBtn()
    {
      //  view.endEditing(true)
     //
        _ = navigationController?.popViewController(animated: true)
      //  self.dismiss(animated: true, completion: nil)

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
           // "payment_mode":packageId,
            "transactionId": strTransId,
            "package_id" : packageId
          //  "promocode": "",
           // "full_amount": packageAmount
        ]
        print(param)
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(SUBSCRIPE_PAYMENT, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false"){
//                self.txtEnterAmount.text = ""
//                self.txtPromoCode.text = ""
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
                self.navigationController?.popViewController(animated: true)
               // self.getWalletAmount()
            } else {
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
     func getOrderId()
    {
        
//        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
//
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(GET_ORDERID, params: nil, headers: header, success: { (JSON) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                self.strOrderId = json.value(forKey: "orderId") as? String ?? ""
                DispatchQueue.main.async {
                    self.showPaymentForm(orderAmount : self.packageAmount)
                }
              
                //self.onGenerateCheckSum()
                
            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
                
            }
            
            
        }, failure: { (error) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)

        })
        
    }
    internal func showPaymentForm(orderAmount : String) {

        
        let options: [String:Any] = [
            "prefill": [
                "contact": userDefaults.object(forKey: USER_MOBILE) as? String,
                "email": userDefaults.object(forKey: USER_EMAIL) as? String
            ],
            "image": "http://13.126.228.76/Ironbox_new/public/images/ironbox.png",
            "amount" : Double("\(packageAmount )")! * 100.0,
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
    @objc func buyNowClicked(sender : UIButton){
        packageId = String(packageData?.packs?[sender.tag].id ?? 0)
        packageAmount = packageData?.packs?[sender.tag].amount ?? ""
        getOrderId()
       // showPaymentForm(orderAmount : packageData?.packs?[sender.tag].amount ?? "")
    }
}

extension AddPackageViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packageData?.packs?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddPackageTableViewCell") as! AddPackageTableViewCell
        if buyBtnShow == false{
            cell.buyNowView.isHidden = true
        }else{
            cell.buyNowView.isHidden = false
        }
        cell.buyNowBtn.tag = indexPath.row
        cell.buyNowBtn.addTarget(self, action: #selector(buyNowClicked(sender: )), for: .touchUpInside)
        cell.packageNameLbl.text = packageData?.packs?[indexPath.row].packageName ?? ""
        cell.descriptionLbl.text = packageData?.packs?[indexPath.row].description ?? ""
        cell.expiryDateLbl.text = "Expiry days \(packageData?.packs?[indexPath.row].expiryDays ?? "")"
        cell.packageAmtLbl.text = "₹ \(packageData?.packs?[indexPath.row].amount ?? "")"
        return cell
    }
    
    
}

// MARK: Paytm Delegate methods.
extension AddPackageViewController : PGTransactionDelegate {
    func didFinishedResponse(_ controller: PGTransactionViewController!, response responseString: String!)
    {
        var dictPaymentSuccess = convertToDictionary(text: responseString)
        self.dismiss(animated: true, completion: nil)
        let dict = dictPaymentSuccess as! Dictionary<String, Any>
        
        dictPaymentSuccess!["paymentType"] = packageId
        dictPaymentSuccess!["offer_code"] = packageAmount
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
 extension AddPackageViewController: RazorpayPaymentCompletionProtocolWithData {

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
    dictPaymentSuccess["TXNAMOUNT"] = packageAmount
    dictPaymentSuccess["PAYMENTMODE"] = packageId
    appDelegate.arrPaytmRsponse.append(dictPaymentSuccess)
    let PaytmRsponsesData = NSKeyedArchiver.archivedData(withRootObject: appDelegate.arrPaytmRsponse)
    userDefaults.set(PaytmRsponsesData, forKey: "PaytmRsponse")
    self.ShowAlert(msg: "Transaction Success")
    self.AddMoneyAPICallOnPaymentSuccess(response: dictPaymentSuccess)
 //self.presentAlert(withTitle: "Success", message: "Payment Succeeded")
 }
 }

