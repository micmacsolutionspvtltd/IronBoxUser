//
//  MySubscriptionsVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 21/06/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Alamofire

class MySubscriptionsVC: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    
    var tableMyPackages = UITableView()
    var arrPackages = Array<Any>()
    
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        
        if DeviceType.iPhoneX
        {
            tableMyPackages.frame = CGRect(x: 0, y: 10, width: self.view.frame.size.width , height: self.view.frame.size.height - 200)
        }
        else
        {
            tableMyPackages.frame = CGRect(x: 0, y: 10, width: self.view.frame.size.width, height: self.view.frame.size.height - 150)
        }
        
        
        tableMyPackages.backgroundColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1)
        tableMyPackages.register(UINib(nibName: "MySubscriptionsTableViewCell", bundle: nil), forCellReuseIdentifier: "MySubscriptionsTableViewCell")
        tableMyPackages.separatorStyle = .none
        tableMyPackages.delegate = self
        tableMyPackages.dataSource = self
        view.addSubview(tableMyPackages)
        
        self.getMyPackages()

       
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - GET Packages
    func getMyPackages()
    {
        
        //  self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
       
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(GET_MY_PACKAGES, params: nil, headers: header, success: { (JSON) in
            //    UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                self.arrPackages = json.value(forKey: "response") as! Array<Any>
                if self.arrPackages.count != 0
                {
                    self.tableMyPackages.delegate = self
                    self.tableMyPackages.dataSource = self
                    self.tableMyPackages.reloadData()
                    self.tableMyPackages.isHidden = false
                    self.view.backgroundColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1)
                    
                }
                else
                {
                    self.tableMyPackages.isHidden = true
                    self.view.backgroundColor = UIColor.clear
                }
                
                
            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                // self.ShowAlert(msg: errorMessage)
                self.tableMyPackages.isHidden = true
                self.view.backgroundColor = UIColor.clear
            }
            
            
        }, failure: { (error) in
            //   UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
            self.tableMyPackages.isHidden = true
            self.view.backgroundColor = UIColor.clear
        })
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrPackages.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MySubscriptionsTableViewCell", for: indexPath) as! MySubscriptionsTableViewCell
        cell.selectionStyle = .none
        
        let dictPackages = self.arrPackages[indexPath.row] as! Dictionary<String, Any>
        cell.lblOriginalRate.text = dictPackages["actual_price"] as? String ?? ""
        cell.lblRatePerCloth.text = dictPackages["price"] as? String ?? ""
        cell.lblTotalClothes.text = dictPackages["no_of_clothes"] as? String ?? ""
        cell.lblPackageDetail.text = dictPackages["packages_cost"] as? String ?? ""
        cell.lblBalanceClothes.text = dictPackages["balance_clothes"] as? String ?? ""
        
        let strDate = dictPackages["end_date"] as? String ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let deliver: Date? = formatter.date(from: strDate)
        formatter.dateFormat = "dd MMM yyyy"
        let strExpDate = formatter.string(from: deliver!)
        cell.lblExpiry.text = "Expires on " + strExpDate
        
        cell.lblOriginalRate.layer.cornerRadius = cell.lblOriginalRate.frame.size.height/2
        cell.lblOriginalRate.clipsToBounds = true
      
        return cell
        
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let dictPackages = self.arrPackages[indexPath.row] as! Dictionary<String, Any>
        let nID = dictPackages["id"]
        let strID = String(describing: nID!)
        
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let MySubscriptionTransactionsVC = story.instantiateViewController(withIdentifier: "MySubscriptionTransactionsVC")as! MySubscriptionTransactionsVC
         MySubscriptionTransactionsVC.strPackageID = strID
        self.navigationController?.pushViewController(MySubscriptionTransactionsVC, animated: false)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 150
    }
    
    
}
