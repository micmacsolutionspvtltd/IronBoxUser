//
//  AddressVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 31/03/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import Spring

class AddressVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableAddress: UITableView!
    var arrAddress = Array<Any>()
    var dictAddress = Dictionary<String,Any>()
     @IBOutlet weak var viewBG: SpringView!
    
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
        
        self.viewBG.isHidden = true
        appDelegate.isNewAddressAdded = false
        self.getAddress()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        if(appDelegate.isNewAddressAdded)
        {
            self.getAddress()
            appDelegate.isNewAddressAdded = false
        }
        dictAddress.removeAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - GET ALL ADDED ADDRESS
    func getAddress()
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(GET_ADDRESS, params: nil, headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                
                let arrHomeAddress = json.value(forKey: "Home") as! Array<Any>
                let arrWorkAddress = json.value(forKey: "Work") as! Array<Any>
                let arrOtherAddress = json.value(forKey: "Other") as! Array<Any>
                self.arrAddress.removeAll()
                self.arrAddress.append(contentsOf: arrHomeAddress)
                self.arrAddress.append(contentsOf: arrWorkAddress)
                self.arrAddress.append(contentsOf: arrOtherAddress)
                
                if self.arrAddress.count != 0
                {
                    self.tableAddress.delegate = self
                    self.tableAddress.dataSource = self
                    self.tableAddress.reloadData()
                    self.tableAddress.isHidden = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { self.tableAddress.setContentOffset(.zero, animated: false) })
                    
                }
                else
                {
                     self.tableAddress.isHidden = true
                }
                
                
              //  self.viewBG.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
                {
                    self.viewBG.isHidden = false
                    self.viewBG.animation = "zoomIn"
                    self.viewBG.curve = "easeIn"
                    self.viewBG.duration = 1
                    self.viewBG.repeatCount = 1
                    self.viewBG.animate()
                }
                
            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
                appDelegate.isNewAddressAdded = false
                 self.tableAddress.isHidden = true
            }
            
            
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
            appDelegate.isNewAddressAdded = false
            self.tableAddress.isHidden = true
        })
        
    }
    
    // MARK: - ACTIONS
    @objc func ClickonBackBtn()
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    @objc func onEdit(btn:UIButton)
    {
        let btnTag = btn.tag - 10000
        dictAddress = self.arrAddress[btnTag] as! Dictionary<String,Any>
        self.performSegue(withIdentifier: "EditAddress", sender: self)
    }
    
    @objc func onDelete(btn:UIButton)
    {
        let alertController = UIAlertController(title: ALERT_TITLE, message: "Are you sure want to delete \n the address?", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            let btnTag = btn.tag - 20000
            let dictAdrs = self.arrAddress[btnTag] as! Dictionary<String,Any>
            let AdrsId = dictAdrs["id"]
            let strAdrsId = String(describing: AdrsId!)
            self.deleteAddress(strAdrsId: strAdrsId)
        }
        
        // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
        let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) {
            (result : UIAlertAction) -> Void in
            
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteAddress(strAdrsId: String)
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        let param: [String: Any] = [
            "addressId":strAdrsId
        ]
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(DELETE_ADDRESS, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                
                self.getAddress()
                
            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
                appDelegate.isNewAddressAdded = false
                self.tableAddress.isHidden = true
            }
            
            
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
            appDelegate.isNewAddressAdded = false
            self.tableAddress.isHidden = true
        })
        
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrAddress.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressDisplayTableViewCell", for: indexPath) as! AddressDisplayTableViewCell
        cell.selectionStyle = .none
        
        let dictAdrs = self.arrAddress[indexPath.row] as! Dictionary<String, Any>
        cell.lblAddressType.text = dictAdrs["title"] as? String ?? ""
        let strFlatNo = dictAdrs["flatNo"] as? String ?? ""
        let strAddress = dictAdrs["address"] as? String ?? ""
        cell.lblAddress.text = strFlatNo + " " + strAddress
        
        let strLandmark = dictAdrs["landmark"] as? String ?? ""
        if strLandmark != ""
        {
            cell.lblLandmark.text = "Landmark : " + strLandmark
        }
        else
        {
            cell.lblLandmark.text = ""
        }
        
        cell.lblCountry.text = "India"
     
        cell.btnEdit.tag = indexPath.row + 10000
        cell.btnEdit.addTarget(self, action: #selector(self.onEdit(btn:)), for: .touchUpInside)

        cell.btnDelete.tag = indexPath.row + 20000
        cell.btnDelete.addTarget(self, action: #selector(self.onDelete(btn:)), for: .touchUpInside)
       
        return cell
        
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 200
    }
    
  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "EditAddress")
        {
            let addAddress = segue.destination as! AddAddressVC
            addAddress.dictAddress = dictAddress
        }
    }
   

}
