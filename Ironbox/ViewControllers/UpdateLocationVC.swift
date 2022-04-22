//
//  UpdateLocationVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 18/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import CircularRevealKit

class UpdateLocationVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtPincode: UITextField!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblReason: UILabel!
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setFontFamilyAndSize()
        self.hideKeyboardWhenTappedAround()
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]
        
        let btnBack = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItems([item], animated: true)
        
        txtPincode.setLeftPaddingPoints(10)
        userDefaults.set("", forKey: IS_LOGIN)
        viewBG.isHidden = true
        viewBG.backgroundColor = UIColor(red: 18/255, green: 24/255, blue: 38/255, alpha: 0.852)
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        if appDelegate.IsNewRegistration == true
        {
            appDelegate.IsNewRegistration = false
            userDefaults.set("yes", forKey: IS_LOGIN)
            let story = UIStoryboard.init(name: "Main", bundle: nil)
            if #available(iOS 13.0, *) {
                let HomeVC = story.instantiateViewController(withIdentifier: "HomeVC")as! HomeVC
                self.navigationController?.pushViewController(HomeVC, animated: false)
            } else {
                // Fallback on earlier versions
            }
        }
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
    
    @IBAction func onOK(_ sender: Any)
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
        
        viewBG.drawAnimatedCircularMask(
            startFrame: rect,
            duration: 0.33,
            revealType: RevealType.unreveal) { [weak self] in
                self?.viewBG.isHidden = true
        }
    }
    
    
    @IBAction func onCheck(_ sender: Any)
    {
        view.endEditing(true)
        if txtPincode.text == "" || (txtPincode.text?.trimmingCharacters(in: .whitespaces).isEmpty)!
        {
            ShowAlert(msg: "Please enter pincode")
        }
        else if (txtPincode.text?.count)! < 6
        {
            ShowAlert(msg: "Please enter valid pincode")
        }
        else
        {
           self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
            
            let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
            
            let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
            
            let param: [String: Any] = [
                "pincode":txtPincode.text!,
                ]
           
            self.CheckNetwork()
            
            AlamofireHC.requestPOST(CHECK_PINCODE, params: param as [String : AnyObject], headers: header, success: { (JSON) in
                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
                let  result = JSON.dictionaryObject
                let json = result! as NSDictionary
               
                let err = json.value(forKey: "error") as? String ?? ""
                if (err == "false")
                {
                    appDelegate.IsNewRegistration = true
                    self.performSegue(withIdentifier: "UpdateLocation_AddAddress", sender: self)
                }
                else
                {
                    self.lblReason.text = json.value(forKey: "error_message") as? String ?? ""
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
                    
                    self.viewBG.isHidden = false
                    self.viewBG.drawAnimatedCircularMask(
                        startFrame: rect,
                        duration: 0.33,
                        revealType: RevealType.reveal) { [weak self] in
                        
                    }
//                    let errorMessage = json.value(forKey: "error_message")as? String ?? ""
//                    self.ShowAlert(msg: errorMessage)
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
    
    // MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtPincode
        {
            let  maxLength = 6
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
