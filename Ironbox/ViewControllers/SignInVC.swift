//
//  SignInVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 22/03/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import Firebase

class SignInVC: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var viewPhoneNumber: UIView!
    @IBOutlet weak var txtMobileNo: UITextField!
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var viewOTPBG: UIView!
    @IBOutlet weak var viewOTP: UIView!
    
    @IBOutlet weak var txtField1: UITextField!
    @IBOutlet weak var txtField2: UITextField!
    @IBOutlet weak var txtField3: UITextField!
    @IBOutlet weak var txtField4: UITextField!
   
    @IBOutlet weak var btnResend: UIButton!
    @IBOutlet weak var lblResend: UILabel!
    
    var counterTimer = 0
    var timer = Timer()
    var strOTP = ""
    var updatableAddress: [String: Any]!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destination = segue.destination as? AddAddressVC {
//        }
    }
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setFontFamilyAndSize()
        self.hideKeyboardWhenTappedAround()
        
        viewOTPBG.backgroundColor = UIColor(red: 18/255, green: 24/255, blue: 38/255, alpha: 0.852)
        viewOTPBG.isHidden = true
        txtMobileNo.setLeftPaddingPoints(5)
        
//        txtMobileNo.text = "9944332211"
        
       // viewPhoneNumber.addDashedLine(strokeColor: UIColor.red, lineWidth: 2.0)
        
        let OtpBiginEditing = Notification.Name("OTPVerificationBeginEditing")
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOTPVerificationBeginEditing), name: OtpBiginEditing, object: nil)
        
        let OtpEndEditing = Notification.Name("OTPVerificationEndEditing")
        NotificationCenter.default.addObserver(self, selector: #selector(self.onOTPEndEditing(_:)), name: OtpEndEditing, object: nil)
    }
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.isNavigationBarHidden = true
        if appDelegate.IsNewRegistration == true
        {
            appDelegate.IsNewRegistration = false
            userDefaults.set("yes", forKey: IS_LOGIN)
            let story = UIStoryboard.init(name: "Main", bundle: nil)
            let HomeVC = story.instantiateViewController(withIdentifier: "HomeVC")as! HomeVC
            self.navigationController?.pushViewController(HomeVC, animated: false)
        }
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillLayoutSubviews()
    {
//        self.txtField1.tintColor = UIColor.clear
//        self.txtField2.tintColor = UIColor.clear
//        self.txtField3.tintColor = UIColor.clear
//        self.txtField4.tintColor = UIColor.clear

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ACTIONS
    @IBAction func onSendOTP(_ sender: Any)
    {
        view.endEditing(true)
        timer.invalidate()
        
        if txtMobileNo.text == "" || (txtMobileNo.text?.trimmingCharacters(in: .whitespaces).isEmpty)!
        {
            ShowAlert(msg: "Please enter phone number")
        }
        else if txtMobileNo.text?.count != 10
        {
           ShowAlert(msg: "Please enter valid phone number")
        }
        else
        {
           self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
            
            let header:HTTPHeaders = ["Accept":"application/json"]

            let tokenFCM = Messaging.messaging().fcmToken
//            print("FCM token: \(tokenFCM ?? "")")
            let strMobileNo = txtMobileNo.text as String?
            
            let param: [String: Any] = [
                "mobile":strMobileNo!,
                "deviceToken":tokenFCM!,
                "os":"ios"
            ]

            self.CheckNetwork()
            
            AlamofireHC.requestPOST(LOGIN, params: param as [String : AnyObject], headers: header, success: { (JSON) in
                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
                let  result = JSON.dictionaryObject
                let json = result! as NSDictionary
               
                let err = json.value(forKey: "error") as? String ?? ""
                if (err == "false")
                {
                    let otp = json.value(forKey: "Otp")
                    self.strOTP = String(describing: otp!)
                    let strMblNo = strMobileNo?.prefix(6)
                    self.lblMessage.text = "We have sent a onetime password (OTP) to " + strMblNo! + "XXXX"
                    self.viewOTP.roundCorners([.topLeft, .topRight], radius: 15)
                    self.viewOTP.frame.origin.y += (self.view.frame.size.height/2)
                    self.viewOTPBG.isHidden = false
                    UIView.animate(withDuration: 0.4, animations: {
                       self.viewOTP.frame.origin.y -= (self.view.frame.size.height/2)
                        self.addBottomLineToTextField(textField: self.txtField1, color: "Light_Gray")
                        self.addBottomLineToTextField(textField: self.txtField2, color: "Light_Gray")
                        self.addBottomLineToTextField(textField: self.txtField3, color: "Light_Gray")
                        self.addBottomLineToTextField(textField: self.txtField4, color: "Light_Gray")
                        
                        self.btnResend.isHidden = true
                        self.lblResend.isHidden = false
                        self.counterTimer = 30
                        self.lblResend.text = "RESEND OTP IN 30s"
                        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateResendOTP), userInfo: nil, repeats: true)
                        
//                        self.ShowAlert(msg: self.strOTP )
                        
                    }, completion: nil)
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
    
    // must be internal or public.
    @objc func updateResendOTP()
    {
        counterTimer -= 1
        if counterTimer < 1
        {
            btnResend.isHidden = false
            lblResend.isHidden = true
            timer.invalidate()
        }
        else
        {
            btnResend.isHidden = true
            lblResend.isHidden = false
            let strCounterTimer = String(describing: counterTimer)
            let strMsgResend = "RESEND OTP IN " + strCounterTimer + "s"
            lblResend.text = strMsgResend
        }
        
    }
    
    @IBAction func onClose(_ sender: Any)
    {
        timer.invalidate()
        view.endEditing(true)
        UIView.animate(withDuration: 0.4, animations: {
            self.viewOTP.frame.origin.y += (self.view.frame.size.height/2)
        }, completion: {
            (value: Bool) in
            self.viewOTPBG.isHidden = true
            self.viewOTP.frame.origin.y -= (self.view.frame.size.height/2)
            
            self.txtField1.text = ""
            self.txtField2.text = ""
            self.txtField3.text = ""
            self.txtField4.text = ""
            
        })
        
    }
    
    @IBAction func onConfirm(_ sender: Any)
    {
        let strEnteredOTP = txtField1.text! + txtField2.text! + txtField3.text! + txtField4.text!
        
        view.endEditing(true)
        
        if strEnteredOTP == "" || (strEnteredOTP.trimmingCharacters(in: .whitespaces).isEmpty)
        {
            ShowAlert(msg: "Please enter OTP")
        }
        else if strEnteredOTP.count != 4
        {
            ShowAlert(msg: "Please enter valid phone number")
        }
        else
        {
            self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
            
            let header:HTTPHeaders = ["Accept":"application/json"]
            
            
            let strMobileNo = txtMobileNo.text!
            
            let param: [String: Any] = [
                "mobile":strMobileNo,
                "otp":strEnteredOTP
            ]
            
            self.CheckNetwork()
            
            AlamofireHC.requestPOST(CHECK_OTP, params: param as [String : AnyObject], headers: header, success: { (JSON) in
                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
                let  result = JSON.dictionaryObject
                let json = result! as NSDictionary
                
                let err = json.value(forKey: "error") as? String ?? ""
                if (err == "false")
                {
                    self.onClose(self)
                    
                    let strType = json["type"] as? String ?? ""
                    let strCheckPin = json["CheckPin"] as? String ?? ""
                    let strCheckAddress = json["CheckAddress"] as? String ?? ""
                    var strAccessToken = json["access_token"] as? String ?? ""
                    strAccessToken = "Bearer " + strAccessToken
                    userDefaults.set(strAccessToken, forKey: ACCESS_TOKEN)
                    
                    if strType == "NotRegister"
                    {
                        self.performSegue(withIdentifier: "SignIn_SignUp", sender: self)
                    }
//                    else if strCheckPin == "No"
//                    {
//                        let strEmail = json["email"] as? String ?? ""
//                        let strGender = json["gender"] as? String ?? ""
//                        let strDob = json["dob"] as? String ?? ""
//                        let strName = json["name"] as? String ?? ""
//                        let strMobileNo = json["mobile"] as? String ?? ""
//                        let strAlternateMobileNo = json["alternate_number"] as? String ?? ""
//                        let strProfileImage = json["image"] as? String ?? ""
//                        let strReferalCode = json["referral_code"] as? String ?? ""
//                        let ID = json["id"]
//                        let strID = String(describing: ID!)
//
//                        userDefaults.set(strName, forKey: USER_NAME)
//                        userDefaults.set(strMobileNo, forKey: USER_MOBILE)
//                        userDefaults.set(strAlternateMobileNo, forKey: USER_ALTERNATE_MOBILE)
//                        userDefaults.set(strID, forKey: USER_ID)
//                        userDefaults.set(strEmail, forKey: USER_EMAIL)
//                        userDefaults.set(strGender, forKey: USER_GENDER)
//                        userDefaults.set(strDob, forKey: USER_DOB)
//                        userDefaults.set(strProfileImage, forKey: USER_PROFILE_IMAGE)
//                        userDefaults.set(strReferalCode, forKey: USER_REFERAL_CODE)
//
//                        self.performSegue(withIdentifier: "SignIn_Location", sender: self)
//                    }
//                    else if strCheckAddress == "No"
//                    {
//                        let strEmail = json["email"] as? String ?? ""
//                        let strGender = json["gender"] as? String ?? ""
//                        let strDob = json["dob"] as? String ?? ""
//                        let strName = json["name"] as? String ?? ""
//                        let strMobileNo = json["mobile"] as? String ?? ""
//                        let strAlternateMobileNo = json["alternate_number"] as? String ?? ""
//                        let strProfileImage = json["image"] as? String ?? ""
//                        let strReferalCode = json["referral_code"] as? String ?? ""
//                        let ID = json["id"]
//                        let strID = String(describing: ID!)
//
//                        userDefaults.set(strName, forKey: USER_NAME)
//                        userDefaults.set(strMobileNo, forKey: USER_MOBILE)
//                        userDefaults.set(strAlternateMobileNo, forKey: USER_ALTERNATE_MOBILE)
//                        userDefaults.set(strID, forKey: USER_ID)
//                        userDefaults.set(strEmail, forKey: USER_EMAIL)
//                        userDefaults.set(strGender, forKey: USER_GENDER)
//                        userDefaults.set(strDob, forKey: USER_DOB)
//                        userDefaults.set(strProfileImage, forKey: USER_PROFILE_IMAGE)
//                        userDefaults.set(strReferalCode, forKey: USER_REFERAL_CODE)
//
//                        appDelegate.IsNewRegistration = true
//                        self.performSegue(withIdentifier: "SignIn_Address", sender: self)
//                    }
                    else
                    {
                        
                        let strEmail = json["email"] as? String ?? ""
                        let strGender = json["gender"] as? String ?? ""
                        let strDob = json["dob"] as? String ?? ""
                        let strName = json["name"] as? String ?? ""
                        let strMobileNo = json["mobile"] as? String ?? ""
                        let strAlternateMobileNo = json["alternate_number"] as? String ?? ""
                        let strProfileImage = json["image"] as? String ?? ""
                        let strReferalCode = json["referral_code"] as? String ?? ""
                        let ID = json["id"]
                        let strID = String(describing: ID!)
                        
                        userDefaults.set(strName, forKey: USER_NAME)
                        userDefaults.set(strMobileNo, forKey: USER_MOBILE)
                        userDefaults.set(strAlternateMobileNo, forKey: USER_ALTERNATE_MOBILE)
                        userDefaults.set(strID, forKey: USER_ID)
                        userDefaults.set(strEmail, forKey: USER_EMAIL)
                        userDefaults.set(strGender, forKey: USER_GENDER)
                        userDefaults.set(strDob, forKey: USER_DOB)
                        userDefaults.set(strReferalCode, forKey: USER_REFERAL_CODE)
                        userDefaults.set(strProfileImage, forKey: USER_PROFILE_IMAGE)
                        userDefaults.set("yes", forKey: IS_LOGIN)
                        
                        let story = UIStoryboard.init(name: "Main", bundle: nil)
                        let HomeVC = story.instantiateViewController(withIdentifier: "HomeVC")as! HomeVC
                        self.navigationController?.pushViewController(HomeVC, animated: false)
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
    }
    
    @IBAction func onResendOTP(_ sender: Any)
    {
        view.endEditing(true)
        self.txtField1.text = ""
        self.txtField2.text = ""
        self.txtField3.text = ""
        self.txtField4.text = ""
        
       self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let header:HTTPHeaders = ["Accept":"application/json"]
        
      //  let tokenFCM = Messaging.messaging().fcmToken
        //            print("FCM token: \(tokenFCM ?? "")")
        let strMobileNo = txtMobileNo.text as String?
        
        let param: [String: Any] = [
            "mobile":strMobileNo!,
        ]
        
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(RESEND_OTP, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
          
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                let otp = json.value(forKey: "Otp")
                self.strOTP = String(describing: otp!)
                
                self.btnResend.isHidden = true
                self.lblResend.isHidden = false
                self.lblResend.text = "RESEND OTP IN 30s"
                self.counterTimer = 30
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateResendOTP), userInfo: nil, repeats: true)
                
//                self.ShowAlert(msg: self.strOTP )
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
    @IBAction func onOTPEndEditing(_ sender: Any)
    {
        self.addBottomLineToTextField(textField: txtField1, color: "Light_Gray")
        self.addBottomLineToTextField(textField: txtField2, color: "Light_Gray")
        self.addBottomLineToTextField(textField: txtField3, color: "Light_Gray")
        self.addBottomLineToTextField(textField: txtField4, color: "Light_Gray")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: - CHANGE COLOR OF OTP TEXTFIELD BOTTOM LINE
    @objc
    private func onOTPVerificationBeginEditing(notification: Notification)
    {
        if notification.object as? UITextField == txtField1
        {
            self.addBottomLineToTextField(textField: txtField1, color: "green")
            self.addBottomLineToTextField(textField: txtField2, color: "Light_Gray")
            self.addBottomLineToTextField(textField: txtField3, color: "Light_Gray")
            self.addBottomLineToTextField(textField: txtField4, color: "Light_Gray")
        }
        else if notification.object as? UITextField == txtField2
        {
            self.addBottomLineToTextField(textField: txtField1, color: "Light_Gray")
            self.addBottomLineToTextField(textField: txtField2, color: "green")
            self.addBottomLineToTextField(textField: txtField3, color: "Light_Gray")
            self.addBottomLineToTextField(textField: txtField4, color: "Light_Gray")
        }
        else if notification.object as? UITextField == txtField3
        {
            self.addBottomLineToTextField(textField: txtField1, color: "Light_Gray")
            self.addBottomLineToTextField(textField: txtField2, color: "Light_Gray")
            self.addBottomLineToTextField(textField: txtField3, color: "green")
            self.addBottomLineToTextField(textField: txtField4, color: "Light_Gray")
        }
        else if notification.object as? UITextField == txtField4
        {
            self.addBottomLineToTextField(textField: txtField1, color: "Light_Gray")
            self.addBottomLineToTextField(textField: txtField2, color: "Light_Gray")
            self.addBottomLineToTextField(textField: txtField3, color: "Light_Gray")
            self.addBottomLineToTextField(textField: txtField4, color: "green")
        }
    }
    
    
    private func addBottomLineToTextField(textField : UITextField, color: String) {
        let border = CALayer()
        let borderWidth = CGFloat(2)
        if color == "green"
        {
            border.borderColor = UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0).cgColor
        }
        else
        {
            border.borderColor = UIColor.lightGray.cgColor
        }
        border.frame = CGRect.init(x: 0, y: textField.frame.size.height - borderWidth, width: textField.frame.size.width, height: textField.frame.size.height)
        border.borderWidth = borderWidth
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    // MARK: - TextField Delegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtMobileNo
        {
            
            let  maxLength = 10
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
            
        }
        else
        {
            if let text = textField.text as NSString?
            {
                let strChars = text.replacingCharacters(in: range, with: string)
               
                if strChars.count == 0
                {
                    switch textField{
                    case txtField1:
                        txtField1.text = " "
                        txtField1.becomeFirstResponder()
                    case txtField2:
                        txtField2.text = " "
                        txtField1.becomeFirstResponder()
                    case txtField3:
                        txtField3.text = " "
                        txtField2.becomeFirstResponder()
                    case txtField4:
                        txtField4.text = " "
                        txtField3.becomeFirstResponder()
                    default:
                        break
                    }
                }
                else
                {
                    switch textField{
                    case txtField1:
                        txtField1.text = string
                        txtField2.becomeFirstResponder()
                    case txtField2:
                        txtField2.text = string
                        txtField3.becomeFirstResponder()
                    case txtField3:
                        txtField3.text = string
                        txtField4.becomeFirstResponder()
                    case txtField4:
                        txtField4.text = string
                        txtField4.resignFirstResponder()
                    default:
                        break
                    }
                }
            }
        }
        
        return false
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
