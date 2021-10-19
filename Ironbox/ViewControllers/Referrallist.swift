//
//  OffersVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 15/05/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import Spring

class Referrallist: UITableViewController {

    @IBOutlet weak var tableReferral: UITableView!
    var arrRefers = Array<Any>()
   // @IBOutlet weak var viewBG: SpringView!
    
     // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableReferral.delegate = self
        self.tableReferral.dataSource = self
        self.tableReferral.reloadData()
        self.setFontFamilyAndSize()
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]
        
        let btnBack = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItems([item], animated: true)
    
        self.getReferfulldetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - GET ALL OFFERS
    func getReferfulldetail()
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        let param: [String: Any] = [
            "offet_type":"All"
        ]
        
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(GET_OFFERS, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                
                self.arrRefers = json.value(forKey: "prmocode") as! Array<Any>
                
                if self.arrRefers.count != 0
                {
                    self.tableReferral.delegate = self
                    self.tableReferral.dataSource = self
                    self.tableReferral.reloadData()
                    self.tableReferral.isHidden = false
                    
                }
                else
                {
                    self.tableReferral.isHidden = false
                    
                }
                
                //  self.viewBG.isHidden = true
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
//                {
//                    self.viewBG.isHidden = false
//                    self.viewBG.animation = "zoomIn"
//                    self.viewBG.curve = "easeIn"
//                    self.viewBG.duration = 1
//                    self.viewBG.repeatCount = 1
//                    self.viewBG.animate()
//                }
                
            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
                self.tableReferral.isHidden = false
            }
            
            
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
            self.tableReferral.isHidden = false
        })
        
    }
    
    // MARK: - ACTIONS
    @objc func ClickonBackBtn()
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TableView DataSource
    func tableview(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
         return 1
    }
    
    func tableview(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReferrallistTableViewCell", for: indexPath) as! ReferlistTableviewcell
        
        cell.selectionStyle = .none
        
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd-MM-yyyy"
//        let formatter1 = DateFormatter()
//        formatter1.dateFormat = "dd-MMM-yyyy"
        
//        let dictOffers = self.arrRefers[indexPath.row] as! Dictionary<String, Any>
//        cell.lblRefername.text = dictOffers["description"] as? String ?? ""
//        cell.lblReferdate.text = dictOffers["validity"] as? String ?? ""
        
        /*
        let strFrom = dictOffers["expiry_from"] as? String ?? ""
        let strTo = dictOffers["expiry_to"] as? String ?? ""
        
        if strTo != "" && strFrom != ""
        {
            let fromDate: Date? = formatter.date(from: strFrom)
            let strFromDate = formatter1.string(from: fromDate!)
            
            
            let toDate: Date? = formatter.date(from: strTo)
            let strToDate = formatter1.string(from: toDate!)
            
            cell.lblOfferValidity.text = "Valid from " + strFromDate + " to " + strToDate
        }
        else
        {
            cell.lblOfferValidity.text = "Validity: nill"
        }
        */
        
        return cell

    }
    
    // MARK: - TableView Delegate
    func tableview(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    
    func tableview(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 133
    }
    
    
}
