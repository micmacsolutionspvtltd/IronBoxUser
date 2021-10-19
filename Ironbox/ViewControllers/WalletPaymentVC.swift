//
//  WalletPaymentVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 06/06/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Alamofire
import Spring

class WalletPaymentVC: UIViewController
{
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblTotalAmount: UILabel!
    
    var strBookingID = ""
    var strPayebleAmout = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setFontFamilyAndSize()
        self.title = "Payment"
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]
        
        self.navigationItem.hidesBackButton = true
        let btnBack = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItems([item], animated: true)
        
        
        self.lblTotalAmount.text = "Rs. " + strPayebleAmout
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        self.getWalletAmount()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                self.lblBalance.text = "( Available Balance Rs." + strAmount + " )"
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
    
    
    // MARK: - ACTIONS
    @objc func ClickonBackBtn()
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onPayNow(_ sender: Any)
    {
        view.endEditing(true)
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        let param: [String: Any] = [
            "bookingId":strBookingID,
            "amount":strPayebleAmout
            ]
       
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(WALLET_PAYMENT, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
                appDelegate.dictPaymentSuccess = json.value(forKey: "bookings") as! Dictionary<String,Any>
                _ = self.navigationController?.popViewController(animated: true)
                
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
    
    @IBAction func onAddWallet(_ sender : Any)
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
