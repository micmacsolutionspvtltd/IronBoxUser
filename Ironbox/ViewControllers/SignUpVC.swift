//
//  SignUpVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 22/03/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import DropDown
import DatePickerDialog
import Foundation
import AWSS3
import MobileCoreServices
import FBSDKCoreKit

class SignUpVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var lblAlterPhNo: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnDOB: UIButton!
    @IBOutlet weak var btnGender: UIButton!
    @IBOutlet weak var btnProfileImage: UIButton!
    @IBOutlet weak var txtAlternate_PhoneNumber: UITextField!
    @IBOutlet weak var lblReferralCode: UILabel!
    @IBOutlet weak var txtReferralCode: UITextField!
    
    let dropDown = DropDown()
    var strGender = ""
    var strMobile = ""
    var chosenImage = UIImage()
    let imagePicker = UIImagePickerController()
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var isImageSelected:Bool = false
     var strFileName = ""
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setFontFamilyAndSize()
        self.hideKeyboardWhenTappedAround()
        imagePicker.delegate = self
        
        let stringValue = "Alternate phone number (optional)"
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
        attributedString.setColorForText(textForAttribute: "Alternate phone number ", withColor: UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha:1))
        attributedString.setColorForText(textForAttribute: "(optional)", withColor: UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:1))
        lblAlterPhNo.font = UIFont(name: FONT_MEDIUM, size: 15)
        lblAlterPhNo.attributedText = attributedString
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let stringValue = "Referral code (optional)"
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
        attributedString.setColorForText(textForAttribute: "Referral code ", withColor: UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha:1))
        attributedString.setColorForText(textForAttribute: "(optional)", withColor: UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:1))
        lblReferralCode.font = UIFont(name: FONT_MEDIUM, size: 15)
        lblReferralCode.attributedText = attributedString
        
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillLayoutSubviews()
    {
        btnProfileImage.layer.cornerRadius = btnProfileImage.frame.size.height/2
        btnProfileImage.clipsToBounds = true
        
        btnDOB.layer.borderWidth = 1
        btnDOB.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnDOB.layer.masksToBounds = false
        btnDOB.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnDOB.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnDOB.layer.shadowOpacity = 0.2
        
        btnGender.layer.borderWidth = 1
        btnGender.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnGender.layer.masksToBounds = false
        btnGender.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnGender.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnGender.layer.shadowOpacity = 0.2
        
        txtName.layer.borderWidth = 1
        txtName.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        txtName.layer.masksToBounds = false
        txtName.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        txtName.layer.shadowOffset = CGSize(width: 0, height: 0)
        txtName.layer.shadowOpacity = 0.2
        
        txtEmail.layer.borderWidth = 1
        txtEmail.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        txtEmail.layer.masksToBounds = false
        txtEmail.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        txtEmail.layer.shadowOffset = CGSize(width: 0, height: 0)
        txtEmail.layer.shadowOpacity = 0.2
        
        txtAlternate_PhoneNumber.layer.borderWidth = 1
        txtAlternate_PhoneNumber.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        txtAlternate_PhoneNumber.layer.masksToBounds = false
        txtAlternate_PhoneNumber.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        txtAlternate_PhoneNumber.layer.shadowOffset = CGSize(width: 0, height: 0)
        txtAlternate_PhoneNumber.layer.shadowOpacity = 0.2
        
        txtName.setLeftPaddingPoints(15)
        txtEmail.setLeftPaddingPoints(15)
        txtAlternate_PhoneNumber.setLeftPaddingPoints(15)
        
        dropDown.anchorView = btnGender // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y: btnGender.bounds.height)
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.dataSource = ["Male","Female"]
        dropDown.selectionAction = { [unowned self] (index, item) in
            self.btnGender.setTitle(item, for: .normal)
            if item == "Male"
            {
                self.strGender = item
            }
            else
            {
                self.strGender = item
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ACTIONS
    @IBAction func onDOB(_ sender: Any)
    {
        
        let calendar = Calendar.current
        let min = calendar.date(byAdding: .year, value: -100, to: Date())
        
        DatePickerDialog().show("Date Of Birth", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: min, maximumDate: Date(), datePickerMode: .date) { (date) in
            if date != nil
            {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                let strDate = dateFormatter.string(from: date!)
                
                self.btnDOB.setTitle(strDate, for: .normal)
                
            }
            
        }
    }
    @IBAction func onGender(_ sender: Any)
    {
        dropDown.show()
    }
    
    @IBAction func onClose(_ sender: Any)
    {
       // self.dismiss(animated: true, completion: nil)
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onConfirm(_ sender: Any)
    {
        view.endEditing(true)
        let isEmailAddressValid = isValidEmailAddress(emailAddressString: txtEmail.text!)
        let strDob = btnDOB.currentTitle
        

        if txtName.text == "" || (txtName.text?.trimmingCharacters(in: .whitespaces).isEmpty)!
        {
            ShowAlert(msg: "Please enter your name")
        }
//        else if strDob == " "
//        {
//            ShowAlert(msg: "Please select your date of birth")
//        }
//        else if txtEmail.text == "" || (txtEmail.text?.trimmingCharacters(in: .whitespaces).isEmpty)!
//        {
//            ShowAlert(msg: "Please enter your email address")
//        }
//        else if isEmailAddressValid == false
//        {
//            ShowAlert(msg: "Please enter valid email address")
//        }
        else
        {
            if isImageSelected == false
            {
                self.registerAPICall()
            }
            else
            {
                self.startUploadImage()
            }
        }
        
        
    }
    
    // MARK: - AWS UPLOAD IMAGE
    func startUploadImage()
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let imgData = UIImageJPEGRepresentation(chosenImage, 0.2)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmssSSS"
        strFileName = formatter.string(from: Date())
        strFileName = strFileName + ".jpg"
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = {(task, progress) in DispatchQueue.main.async(execute: {
            // Do something e.g. Update a progress bar.
            print(progress)
        })
        }
        
        self.completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
                
                if error == nil
                {
                    self.registerAPICall()
                }
                
            })
        }
        
        let  transferUtility = AWSS3TransferUtility.default()
        
        transferUtility.uploadData(imgData,
                                   bucket: PROFILE_BUCKET_NAME,
                                   key: strFileName,
                                   contentType: "image/png",
                                   expression: expression,
                                   completionHandler: completionHandler).continueWith { (task) -> AnyObject? in
                                    if let error = task.error {
                                        print("Error: \(error.localizedDescription)")
                                    }
                                    
                                    if let _ = task.result {
                                        // Do something with uploadTask.
                                    }
                                    
                                    return nil;
        }
        
        
    }
    
    // MARK: - API PROFILE UPDATE
    func registerAPICall()
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        if strFileName != ""
        {
            strFileName = PROFILE_IMG_BASE_URL + strFileName
        }
       
        let strDob = btnDOB.currentTitle
        
        let param: [String: Any] = [
            "email":self.txtEmail.text!,
            "dob":strDob ?? "",
            "gender":self.strGender,
            "name":self.txtName.text ?? "",
            "alternate_number":self.txtAlternate_PhoneNumber.text ?? "",
            "keyvalue":"1",
            "image":strFileName,
            "referral_code":txtReferralCode.text ?? ""
        ]
       
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(EDIT_USER_PROFILE, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                let dictUserDetail = json.value(forKey: "UserDetails") as! NSDictionary
                
                let strEmail = dictUserDetail["email"] as? String ?? ""
                let strGender = dictUserDetail["gender"] as? String ?? ""
                let strDob = dictUserDetail["dob"] as? String ?? ""
                let strName = dictUserDetail["name"] as? String ?? ""
                let strMobileNo = dictUserDetail["mobile"] as? String ?? ""
                let strAlternateMobileNo = dictUserDetail["alternate_number"] as? String ?? ""
                let strProfileImage = dictUserDetail["image"] as? String ?? ""
                let strReferalCode = dictUserDetail["referral_code"] as? String ?? ""
                let ID = dictUserDetail["id"]
                let strID = String(describing: ID!)
                self.logCompletedRegistrationEvent("Signup")
                
                userDefaults.set(strName, forKey: USER_NAME)
                userDefaults.set(strMobileNo, forKey: USER_MOBILE)
                userDefaults.set(strAlternateMobileNo, forKey: USER_ALTERNATE_MOBILE)
                userDefaults.set(strID, forKey: USER_ID)
                userDefaults.set(strEmail, forKey: USER_EMAIL)
                userDefaults.set(strGender, forKey: USER_GENDER)
                userDefaults.set(strDob, forKey: USER_DOB)
                userDefaults.set(strProfileImage, forKey: USER_PROFILE_IMAGE)
                userDefaults.set(strReferalCode, forKey: USER_REFERAL_CODE)
                userDefaults.set("yes", forKey: IS_LOGIN)
                
//                let strCheckPin = json.value(forKey: "CheckPin") as? String ?? ""
//                if strCheckPin == "No"
//                {
//                    self.performSegue(withIdentifier: "Register_Location", sender: self)
//                }
//                else
//                {
                    let story = UIStoryboard.init(name: "Main", bundle: nil)
                if #available(iOS 13.0, *) {
                    let HomeVC = story.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                    self.navigationController?.pushViewController(HomeVC, animated: false)

                } else {
                    // Fallback on earlier versions
                }
//                }
                
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
    func logCompletedRegistrationEvent(_ registrationMethod: String?) {
        let params = [AppEvents.ParameterName.registrationMethod.rawValue: registrationMethod ?? ""]
        AppEvents.logEvent(AppEvents.Name.completedRegistration, parameters: params)
    }
    
    // MARK: - Image Handling
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        isImageSelected = true
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        btnProfileImage.setBackgroundImage(chosenImage, for: .normal)  //4
        dismiss(animated:true, completion: nil) //5
        
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func onProfileImage(_ sender: Any)
    {
        
        let otherAlert = UIAlertController(title: "Ironbox", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let Choose = UIAlertAction(title: "Choose From Camera Roll", style: UIAlertActionStyle.default, handler: ChooseFromGallery)
        
        let take = UIAlertAction(title: "Take Picture", style: UIAlertActionStyle.default, handler: TakePicture)
        
        let dismiss = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        // relate actions to controllers
        otherAlert.addAction(Choose)
        otherAlert.addAction(take)
        otherAlert.addAction(dismiss)
        
        present(otherAlert, animated: true, completion: nil)
    }
    
    func ChooseFromGallery(alert: UIAlertAction)
    {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func TakePicture(alert: UIAlertAction)
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            present(imagePicker, animated: true, completion: nil)
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

    // MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtAlternate_PhoneNumber
        {
            let  maxLength = 10
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
            
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
