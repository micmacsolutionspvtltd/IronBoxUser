//
//  ChooseLocationVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 18/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView

class ChooseLocationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tablePincode: UITableView!
    var arrPincodes = Array<Any>()
    var strSelectedPinCode = ""
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
         userDefaults.set("", forKey: IS_LOGIN) 
        // Do any additional setup after loading the view.
         self.setFontFamilyAndSize()
        self.getPinCodes()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.isNavigationBarHidden = true
        
        if appDelegate.IsNewRegistration == true{
            appDelegate.IsNewRegistration = false
            userDefaults.set("yes", forKey: IS_LOGIN)
            let story = UIStoryboard.init(name: "Main", bundle: nil)
            if #available(iOS 13.0, *) {
                let HomeVC = story.instantiateViewController(withIdentifier: "HomeVC")as! HomeVC
                self.navigationController?.pushViewController(HomeVC, animated: false)
            }else {
                
                // Fallback on earlier versions
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    // MARK: - GET PINCODE FROM SERVER
    func getPinCodes()
    {
       self.view.addSubview(UIView().customActivityIndicator(view: (self.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(GET_PINCODE, params: nil, headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                
                self.arrPincodes = json.value(forKey: "response") as! Array<Any>
                
                if self.arrPincodes.count != 0
                {
                    var dictOthers =  Dictionary<String, Any>()
                    dictOthers["code"] = "Others"
                    self.arrPincodes.append(dictOthers)
                    
                    self.tablePincode.delegate = self
                    self.tablePincode.dataSource = self
                    self.tablePincode.reloadData()
                    self.tablePincode.isHidden = false
                }
                else
                {
                    self.tablePincode.isHidden = true
                }
                
            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
                self.tablePincode.isHidden = true
            }
            
            
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.view)!)
            print(error)
            self.tablePincode.isHidden = true
        })
        
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrPincodes.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PinCodeTableViewCell", for: indexPath) as! PinCodeTableViewCell
        cell.selectionStyle = .none
        
        let dictPinCode = self.arrPincodes[indexPath.row] as! Dictionary<String, Any>
        cell.lblPincode.text = dictPinCode["code"] as? String ?? ""
        
        let strPinCode = dictPinCode["code"] as? String ?? ""
        if strSelectedPinCode == strPinCode
        {
            cell.imgRadio.image = UIImage(named: "RadioLocationOn")
        }
        else
        {
            cell.imgRadio.image = UIImage(named: "RadioLocationOff")
        }
        
        return cell
        
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let dictPinCode = self.arrPincodes[indexPath.row] as! Dictionary<String, Any>
        strSelectedPinCode = dictPinCode["code"] as? String ?? ""
        tablePincode.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 40
    }
    

    // MARK: - ACTIONS
    @IBAction func onClose(_ sender: Any)
    {
        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is SignInVC {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
    }
    
    @IBAction func onNext(_ sender: Any)
    {
       
        if strSelectedPinCode == ""
        {
            ShowAlert(msg: "Please select pincode")
        }
        else
        {
            if strSelectedPinCode != "Others"
            {
                view.endEditing(true)
               self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
                
                let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
                
                let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
                
                let param: [String: Any] = [
                    "pincode":strSelectedPinCode,
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
                        self.performSegue(withIdentifier: "Pincode_AddAddress", sender: self)
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
            else
            {
                 self.performSegue(withIdentifier: "Location_EnterLocation", sender: self)
            }
           
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

}
