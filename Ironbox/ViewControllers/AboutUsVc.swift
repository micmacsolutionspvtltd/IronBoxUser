//
//  AboutUsVc.swift
//  Ironbox
//
//  Created by Gopalsamy A on 07/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import Spring

class AboutUsVc: UIViewController
{

    @IBOutlet weak var viewBG: SpringView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblAboutUs: UILabel!
    @IBOutlet weak var btnRateUs: UIButton!
    
    var strAboutUs = ""
    
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
        
        lblAboutUs.padding =  UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        viewBG.isHidden = true
        self.getDetails()
    }

    override func viewWillLayoutSubviews()
    {
        self.lblAboutUs.layer.borderWidth = 1
        self.lblAboutUs.layer.borderColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:0.43).cgColor
        self.lblAboutUs.layer.masksToBounds = false
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - GET DETAILS
    func getDetails()
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(ABOUT_US, params: nil, headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            print(json)
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                self.strAboutUs = json.value(forKey: "About") as? String ?? ""
                self.lblAboutUs.text = self.strAboutUs
                self.lblAboutUs.sizeToFit()
                self.viewBG.layoutIfNeeded()
                self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.btnRateUs.frame.origin.y + self.btnRateUs.frame.size.height + 50)
                self.scrollView.layoutIfNeeded()
                self.viewBG.isHidden = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4)
                {
                    self.viewBG.isHidden = false
                    self.viewBG.animation = "fadeInDown"
                    self.viewBG.curve = "easeIn"
                    self.viewBG.duration = 1
                    self.viewBG.repeatCount = 1
                    self.viewBG.animate()
                    // self.viewBG.animation = "wobble"
                    // self.viewBG.curve = "spring"
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
    
   
//    - (void)onPaymentSuccess:(nonnull NSString*)payment_id
//    {
//    [[[UIAlertView alloc] initWithTitle:@"Payment Successful" message:payment_id delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//
//    }
//    - (void)onPaymentError:(int)code description:(nonnull NSString *)str
//    {      [[[UIAlertView alloc] initWithTitle:@"Error" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//
//    }

    @objc func ClickonBackBtn()
    {
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func onRateus(_ sender: Any)
    {
        if let url = URL(string: APP_STORE_URL),
            UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    @IBAction func onDisclaimer(_ sender: Any)
    {
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let WebViewVC = story.instantiateViewController(withIdentifier: "WebViewVC")as! WebViewVC
        WebViewVC.strTitle = "Disclaimer"
        WebViewVC.strURL = DISCLAIMER_URL
        self.navigationController?.pushViewController(WebViewVC, animated: false)
    }
    
    @IBAction func onRefundPolicy(_ sender: Any)
    {
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let WebViewVC = story.instantiateViewController(withIdentifier: "WebViewVC")as! WebViewVC
        WebViewVC.strTitle = "Return and Refund Policy"
        WebViewVC.strURL = REFUND_URL
            self.navigationController?.pushViewController(WebViewVC, animated: false)
    }
    
    @IBAction func onTermsConds(_ sender: Any)
    {
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let WebViewVC = story.instantiateViewController(withIdentifier: "WebViewVC")as! WebViewVC
        WebViewVC.strTitle = "Terms and Conditions"
        WebViewVC.strURL = TERMSCONDS_URL
        self.navigationController?.pushViewController(WebViewVC, animated: false)
    }
    
    @IBAction func onPrivacyPolicy(_ sender: Any)
    {
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let WebViewVC = story.instantiateViewController(withIdentifier: "WebViewVC")as! WebViewVC
        WebViewVC.strTitle = "Privacy and Policy"
        WebViewVC.strURL = PRIVACY_URL
            self.navigationController?.pushViewController(WebViewVC, animated: false)
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
