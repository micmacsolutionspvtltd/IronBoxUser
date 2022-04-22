//
//  CustomerSupportVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 07/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import Spring
import Toaster


class CustomerSupportVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var referralTxtFldContentView: UIView!
    @IBOutlet weak var submitBtnView: UIView!
    @IBOutlet weak var referralCodeLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var referralCodeTextFld: UITextField!
    @IBOutlet weak var viewBG: SpringView!
    @IBOutlet weak var txtVwFeedback: UITextView!
    @IBOutlet weak var lblContactNo: UILabel!
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setFontFamilyAndSize()
        self.hideKeyboardWhenTappedAround()
        referralCodeTextFld.textColor = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0)
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]
        
        let btnBack = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItems([item], animated: true)
        
    //   addDottedLine(textField: referralCodeTextFld)
        //        let stringValue = "Contact us at 9090903456"
//        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
//        attributedString.setColorForText(textForAttribute: "Contact us at ", withColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha:1))
//        attributedString.setColorForText(textForAttribute: "9090903456", withColor: UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:1))
//        lblContactNo.font = UIFont(name: FONT_MEDIUM, size: 15)
//        lblContactNo.attributedText = attributedString
        
        viewBG.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
        {
            self.viewBG.isHidden = false
            self.viewBG.animation = "squeezeRight"
            self.viewBG.curve = "shake"
            self.viewBG.duration = 1.5
            self.viewBG.repeatCount = 1
            self.viewBG.animate()
            
        }
        
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        getAgentCodeValues(agentCode: "")
    }
    
    override func viewWillLayoutSubviews()
    {
        referralCodeTextFld.textColor = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0)
        self.referralCodeTextFld.layer.borderWidth = 1
        self.referralCodeTextFld.layer.borderColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:0.43).cgColor
        self.referralCodeTextFld.layer.masksToBounds = true
        self.referralCodeTextFld.layer.cornerRadius = 3

        txtVwFeedback.text = "Type your comments"
        txtVwFeedback.textColor = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0)
        self.txtVwFeedback.layer.borderWidth = 1
        self.txtVwFeedback.layer.borderColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:0.43).cgColor
        self.txtVwFeedback.layer.masksToBounds = true
        self.txtVwFeedback.layer.cornerRadius = 3
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
    
    @IBAction func referralSubmitAtn(_ sender: Any) {
        if referralCodeTextFld.text == ""{
            ShowAlert(msg: "Please enter your agent code")
        }else{
            getAgentCodeValues(agentCode: referralCodeTextFld.text ?? "")
        }
        

        
    }
    @IBAction func onFeedback(_ sender: Any)
    {
        view.endEditing(true)
        if txtVwFeedback.text == "" || (txtVwFeedback.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!
        {
            ShowAlert(msg: "Please enter your comments")
        }
        else if txtVwFeedback.text == "Type your comments"
        {
            ShowAlert(msg: "Please enter your comments")
        }
        else
        {
            view.endEditing(true)
            self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
            
            let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
            let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
            
            let param: [String: Any] = [
                "Comments":txtVwFeedback.text!,
            ]
            self.CheckNetwork()
            
            AlamofireHC.requestPOST(SEND_FEEDBACK, params: param as [String : AnyObject], headers: header, success: { (JSON) in
                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
                let  result = JSON.dictionaryObject
                let json = result! as NSDictionary
                let err = json.value(forKey: "error") as? String ?? ""
                if (err == "false")
                {
                    self.txtVwFeedback.text = "Type your comments"
                    self.txtVwFeedback.textColor = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0)
                    let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                    self.ShowAlert(msg: errorMessage)
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
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - TextView Delegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return numberOfChars < 500;
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0) {
            textView.text = nil
            textView.textColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:1)
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            txtVwFeedback.text = "Type your comments"
            textView.textColor = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0)
        }
    }
    func addDottedLine(textField : UITextField){
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:0.43).cgColor
        yourViewBorder.lineDashPattern = [10, 5]
      //  yourViewBorder.frame = textField.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.path = UIBezierPath(rect: textField.bounds).cgPath
        textField.layer.addSublayer(yourViewBorder)
    }
    func getAgentCodeValues(agentCode: String){
        view.addSubview(UIView().customActivityIndicator(view: (self.view)!, widthView: nil, message: "Loading"))

        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        var param: [String: Any] = [
           "agentcode" : agentCode
           ]
        AlamofireHC.requestPOSTMethod(AGENT_REFFERCODE, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            let results : Data? = JSON
            UIView().hideLoader(removeFrom: (self.view)!)

            if results != nil{
                do
                {
                let response = try JSONDecoder().decode(ReferralCodeModel.self, from: results!)
                    self.getReferranceValuesData(data: response)
               
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
    
    func getReferranceValuesData(data : ReferralCodeModel){
        if data.status == "false"{
            if referralCodeTextFld.text != ""{
                ShowAlert(msg: "Agent Referral code is invalid")
            }else{
                
            }
            referralCodeLbl.text = "Enter Your Agent Referral code"
            submitBtnView.isHidden = false
            referralCodeTextFld.isUserInteractionEnabled = true
        }else{
            if referralCodeTextFld.text != ""{
                ShowAlert(msg: "Your agent code register sucessfully")
               // referralCodeTextFld.text = data.agentCode ?? ""

            }else{
                referralCodeTextFld.text = data.agentCode ?? ""

            }
            referralCodeLbl.text = "Your Agent Code"
            referralCodeLbl.textAlignment = .center
           // referralCodeLbl.isHidden = true
            submitBtnView.isHidden = true
            referralCodeTextFld.isUserInteractionEnabled = false
          
        }
    }
    
}
