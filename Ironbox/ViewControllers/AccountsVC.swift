//
//  AccountsVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 05/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import DropDown
import DatePickerDialog
import NVActivityIndicatorView
import Alamofire
import Foundation
import AWSS3
import MobileCoreServices
import Spring

class AccountsVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var viewSpring: SpringView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDob: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var lblAlterPhoneNumber: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblAlterPhNo: UILabel!
    @IBOutlet weak var lblAlterPhNoEdit: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewEdit: UIView!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnDOB: UIButton!
    @IBOutlet weak var btnGender: UIButton!
    @IBOutlet weak var txtAlternate_PhoneNumber: UITextField!
    let dropDown = DropDown()
    var strGender = ""
    var strDob = ""
    var strFileName = ""
    
     @IBOutlet weak var imgProfileEdit: UIImageView!
    @IBOutlet weak var btnProfileImage: UIButton!
    var chosenImage = UIImage()
    let imagePicker = UIImagePickerController()
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    var isImageSelected:Bool = false
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setFontFamilyAndSize()
        self.hideKeyboardWhenTappedAround()
        imagePicker.delegate = self
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]
        
        let btnBack = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItems([item], animated: true)
        
        let btnEdit = UIButton(type: .custom)
        btnEdit.setImage(UIImage(named: "Edit"), for: .normal)
        btnEdit.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnEdit.addTarget(self, action: #selector(self.ClickonEditBtn), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btnEdit)
        self.navigationItem.setRightBarButtonItems([item1], animated: true)
        
        let stringValue = "Alternate phone number (optional)"
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringValue)
        attributedString.setColorForText(textForAttribute: "Alternate phone number ", withColor: UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha:1))
        attributedString.setColorForText(textForAttribute: "(optional)", withColor: UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:1))
        lblAlterPhNo.font = UIFont(name: FONT_MEDIUM, size: 15)
        lblAlterPhNo.attributedText = attributedString
        
        lblAlterPhNoEdit.font = UIFont(name: FONT_MEDIUM, size: 15)
        lblAlterPhNoEdit.attributedText = attributedString
        
        viewBG.backgroundColor = UIColor(red: 18/255, green: 24/255, blue: 38/255, alpha: 0.852)
        viewBG.isHidden = true
        
        lblName.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        lblDob.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        lblGender.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        lblPhoneNumber.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        lblAlterPhoneNumber.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        lblEmail.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
       self.getProfile()
        
    }

    override func viewWillLayoutSubviews()
    {
        imgProfile.layer.cornerRadius = imgProfile.frame.size.height/2
        imgProfile.clipsToBounds = true
        imgProfile.layer.borderWidth = 1
        imgProfile.layer.borderColor = UIColor.clear.cgColor
        //  btnProfileImage.layer.masksToBounds = false
        imgProfile.layer.shadowColor = UIColor.lightGray.cgColor
        imgProfile.layer.shadowOffset = CGSize(width: 0, height: 0)
        imgProfile.layer.shadowOpacity = 0.1
        
        imgProfileEdit.layer.cornerRadius = imgProfileEdit.frame.size.height/2
        imgProfileEdit.clipsToBounds = true
        imgProfileEdit.layer.borderWidth = 1
        imgProfileEdit.layer.borderColor = UIColor.lightGray.cgColor
        //  btnProfileImage.layer.masksToBounds = false
        imgProfileEdit.layer.shadowColor = UIColor.lightGray.cgColor
        imgProfileEdit.layer.shadowOffset = CGSize(width: 0, height: 0)
        imgProfileEdit.layer.shadowOpacity = 0.1
    
        btnProfileImage.layer.cornerRadius = btnProfileImage.frame.size.height/2
        btnProfileImage.clipsToBounds = true
        
        btnDOB.layer.borderWidth = 1
        btnDOB.layer.borderColor = UIColor.lightGray.cgColor
        btnDOB.layer.masksToBounds = false
        btnDOB.layer.shadowColor = UIColor.lightGray.cgColor
        btnDOB.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnDOB.layer.shadowOpacity = 0.1
        
        btnGender.layer.borderWidth = 1
        btnGender.layer.borderColor = UIColor.lightGray.cgColor
        btnGender.layer.masksToBounds = false
        btnGender.layer.shadowColor = UIColor.lightGray.cgColor
        btnGender.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnGender.layer.shadowOpacity = 0.1
        
        txtName.layer.borderWidth = 1
        txtName.layer.borderColor = UIColor.lightGray.cgColor
        txtName.layer.masksToBounds = false
        txtName.layer.shadowColor = UIColor.lightGray.cgColor
        txtName.layer.shadowOffset = CGSize(width: 0, height: 0)
        txtName.layer.shadowOpacity = 0.1
        
        txtAlternate_PhoneNumber.layer.borderWidth = 1
        txtAlternate_PhoneNumber.layer.borderColor = UIColor.lightGray.cgColor
        txtAlternate_PhoneNumber.layer.masksToBounds = false
        txtAlternate_PhoneNumber.layer.shadowColor = UIColor.lightGray.cgColor
        txtAlternate_PhoneNumber.layer.shadowOffset = CGSize(width: 0, height: 0)
        txtAlternate_PhoneNumber.layer.shadowOpacity = 0.1
        
        txtName.setLeftPaddingPoints(15)
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
    
    // MARK: - GET PROFILE DETAILS
    func getProfile()
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(GET_USERDETAILS, params: nil, headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                let strEmail = json["email"] as? String ?? ""
                let strGender = json["gender"] as? String ?? ""
                let strDob = json["dob"] as? String ?? ""
                let strName = json["name"] as? String ?? ""
                let strMobileNo = json["mobile"] as? String ?? ""
                let strAlternateMobileNo = json["alternate_number"] as? String ?? ""
                let strProfileImage = json["image"] as? String ?? ""
                let ID = json["id"]
                let strID = String(describing: ID!)
                
                userDefaults.set(strName, forKey: USER_NAME)
                userDefaults.set(strMobileNo, forKey: USER_MOBILE)
                userDefaults.set(strAlternateMobileNo, forKey: USER_ALTERNATE_MOBILE)
                userDefaults.set(strID, forKey: USER_ID)
                userDefaults.set(strEmail, forKey: USER_EMAIL)
                userDefaults.set(strGender, forKey: USER_GENDER)
                userDefaults.set(strDob, forKey: USER_DOB)
                userDefaults.set(strProfileImage, forKey: USER_PROFILE_IMAGE)
                
                self.showPersonalDetails()
                
                self.viewSpring.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4)
                {
                    self.viewSpring.isHidden = false
                    self.viewSpring.animation = "fadeIn"
                    self.viewSpring.curve = "easeIn"
                    self.viewSpring.duration = 1.5
                    self.viewSpring.repeatCount = 1
                    self.viewSpring.animate()
                    
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

    
    // MARK: - DISPLAY PROFILE
    func showPersonalDetails()
    {
        lblName.text = userDefaults.object(forKey: USER_NAME) as? String
        lblDob.text = userDefaults.object(forKey: USER_DOB) as? String
        lblGender.text = userDefaults.object(forKey: USER_GENDER) as? String
        lblPhoneNumber.text = userDefaults.object(forKey: USER_MOBILE) as? String
        lblAlterPhoneNumber.text = userDefaults.object(forKey: USER_ALTERNATE_MOBILE) as? String
        lblEmail.text = userDefaults.object(forKey: USER_EMAIL) as? String
        
        if userDefaults.object(forKey: USER_PROFILE_IMAGE) as? String != nil
        {
            var strImageURL = userDefaults.object(forKey: USER_PROFILE_IMAGE) as? String ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            {
                 strImageURL = strImageURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
               // self.imgProfile.sd_setImage(with: URL(string: strImageURL), placeholderImage: UIImage(named: "ProfilePlaceholder"), options: .refreshCached)
                
                self.imgProfile.imageFromServerURL(urlString: strImageURL)
            }
            
        }
        
    }
    
    // MARK: - ACTIONS
    @objc func ClickonBackBtn()
    {
        _ = navigationController?.popViewController(animated: true)
    }

    @objc func ClickonEditBtn()
    {
        viewBG.isHidden = true
        
        viewEdit.roundCorners([.topLeft, .topRight], radius: 15)
        self.viewEdit.frame.origin.y += ((self.view.frame.size.height/10) * 7)
        viewBG.isHidden = false
        UIView.animate(withDuration: 0.4, animations: {
            self.viewEdit.frame.origin.y -= ((self.view.frame.size.height/10) * 7)
        }, completion: nil)
        
        txtName.text = userDefaults.object(forKey: USER_NAME) as? String
        strDob = (userDefaults.object(forKey: USER_DOB) as? String)!
        self.btnDOB.setTitle(strDob, for: .normal)
        strGender = (userDefaults.object(forKey: USER_GENDER) as? String)!
        self.btnGender.setTitle(strGender, for: .normal)
        txtAlternate_PhoneNumber.text = userDefaults.object(forKey: USER_ALTERNATE_MOBILE) as? String
        
        if userDefaults.object(forKey: USER_PROFILE_IMAGE) as? String != nil
        {
            var strImageURL = userDefaults.object(forKey: USER_PROFILE_IMAGE) as? String ?? ""
            strImageURL = strImageURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
          //  imgProfileEdit.sd_setImage(with: URL(string: strImageURL), placeholderImage: UIImage(named: "ProfilePlaceholder"), options: .refreshCached)
            
            self.imgProfileEdit.imageFromServerURL(urlString: strImageURL)
        }
        
    }

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
    
    @IBAction func onCloseEdit(_ sender: Any)
    {
        view.endEditing(true)
       
        UIView.animate(withDuration: 0.4, animations: {
            self.viewEdit.frame.origin.y += ((self.view.frame.size.height/10) * 7)
        }, completion: {
            (value: Bool) in
            self.viewBG.isHidden = true
            self.viewEdit.frame.origin.y -= ((self.view.frame.size.height/10) * 7)
        })
        
    }
    @IBAction func onSave(_ sender: Any)
    {
        view.endEditing(true)
        let strDob = btnDOB.currentTitle
        let strAltNo = txtAlternate_PhoneNumber.text?.replacingOccurrences(of: " ", with: "")
        if txtName.text == "" || (txtName.text?.trimmingCharacters(in: .whitespaces).isEmpty)!
        {
            ShowAlert(msg: "Please enter name")
        }
        else if strDob == " "
        {
            ShowAlert(msg: "Please select date of birth")
        }
        else  if strAltNo != ""
        {
            if strAltNo?.count != 10
            {
                ShowAlert(msg: "Please enter valid moblie number")
            }
            else
            {
                if isImageSelected == false
                {
                    self.profileUpdateAPICall()
                }
                else
                {
                    self.startUploadImage()
                }
                
            }
            
        }
        else
        {
            if isImageSelected == false
            {
                self.profileUpdateAPICall()
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
                    self.profileUpdateAPICall()
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
    func profileUpdateAPICall()
    {
         let strDob = btnDOB.currentTitle
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        
        if strFileName == ""
        {
            strFileName = userDefaults.object(forKey: USER_PROFILE_IMAGE) as? String ?? ""
        }
        else
        {
             strFileName = PROFILE_IMG_BASE_URL + strFileName
        }
        let param: [String: Any] = [
            "dob":strDob!,
            "gender":strGender,
            "name":txtName.text!,
            "alternate_number":txtAlternate_PhoneNumber.text!,
            "keyvalue":"2",
            "image":strFileName
        ]
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(EDIT_USER_PROFILE, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
        
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                self.isImageSelected = false
                self.strFileName = ""
                let dictUserDetail = json.value(forKey: "UserDetails") as! NSDictionary
                
                let strEmail = dictUserDetail["email"] as? String ?? ""
                let strGender = dictUserDetail["gender"] as? String ?? ""
                let strDob = dictUserDetail["dob"] as? String ?? ""
                let strName = dictUserDetail["name"] as? String ?? ""
                let strMobileNo = dictUserDetail["mobile"] as? String ?? ""
                let strAlternateMobileNo = dictUserDetail["alternate_number"] as? String ?? ""
                let strProfileImage = dictUserDetail["image"] as? String ?? ""
                let ID = dictUserDetail["id"]
                let strID = String(describing: ID!)
                
                userDefaults.set(strName, forKey: USER_NAME)
                userDefaults.set(strMobileNo, forKey: USER_MOBILE)
                userDefaults.set(strAlternateMobileNo, forKey: USER_ALTERNATE_MOBILE)
                userDefaults.set(strID, forKey: USER_ID)
                userDefaults.set(strEmail, forKey: USER_EMAIL)
                userDefaults.set(strGender, forKey: USER_GENDER)
                userDefaults.set(strDob, forKey: USER_DOB)
                userDefaults.set(strProfileImage, forKey: USER_PROFILE_IMAGE)
                userDefaults.set("yes", forKey: IS_LOGIN)
                
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                let alertController = UIAlertController(title: ALERT_TITLE, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    self.onCloseEdit(self)
                    self.showPersonalDetails()
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
    
    // MARK: - Image Handling
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        isImageSelected = true
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        imgProfileEdit.image = chosenImage  //4
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
