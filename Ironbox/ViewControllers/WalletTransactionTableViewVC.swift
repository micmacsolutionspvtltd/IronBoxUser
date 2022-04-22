//
//  WalletTransactionTableViewVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 31/05/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Alamofire

class WalletTransactionTableViewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableTransactions = UITableView()
    var arrTransactions = Array<Any>()
    
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
       
        if DeviceType.iPhoneX
        {
             tableTransactions.frame = CGRect(x: 10, y: 10, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 200)
        }
        else
        {
             tableTransactions.frame = CGRect(x: 10, y: 10, width: self.view.frame.size.width - 20, height: self.view.frame.size.height - 150)
        }
        
        
       
        tableTransactions.backgroundColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1)
        tableTransactions.register(UINib(nibName: "TransactionsTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionsTableViewCell")
        tableTransactions.separatorStyle = .none
        tableTransactions.delegate = self
        tableTransactions.dataSource = self
        
        view.addSubview(tableTransactions)
       // view.constrainCentered(tableTransactions)
     //   view.backgroundColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1)
        let strTitle = title.capitalized
        if strTitle == "Spent"{
            self.getTransactions(type: "Debit")
        }else{
        self.getTransactions(type: strTitle)
        }
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
    
    // MARK: - GET HISTORY
    func getTransactions(type:String)
    {
        
      //  self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        let param: [String: Any] = [
            "type":type
        ]
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(GET_TRANSACTIONS_WALLET, params: param as [String : AnyObject], headers: header, success: { (JSON) in
        //    UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
             self.arrTransactions = json.value(forKey: "response") as! Array<Any>
                if self.arrTransactions.count != 0
                {
                    self.tableTransactions.delegate = self
                    self.tableTransactions.dataSource = self
                    self.tableTransactions.reloadData()
                    self.tableTransactions.isHidden = false
                    self.view.backgroundColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1)
                    
                }
                else
                {
                    self.tableTransactions.isHidden = true
                    self.view.backgroundColor = UIColor.clear
                }
            
                
            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
               // self.ShowAlert(msg: errorMessage)
                self.tableTransactions.isHidden = true
                self.view.backgroundColor = UIColor.clear
            }
            
            
        }, failure: { (error) in
         //   UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
            self.tableTransactions.isHidden = true
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
        
        return arrTransactions.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionsTableViewCell", for: indexPath) as! TransactionsTableViewCell
        cell.selectionStyle = .none
        cell.viewType.layoutIfNeeded()
        
        let dictTrans = self.arrTransactions[indexPath.row] as! Dictionary<String, Any>
        cell.lblOrderId.text = dictTrans["orderId"] as? String ?? ""
        let strType = dictTrans["type"] as? String ?? ""
        cell.lblType.text = strType.uppercased()
        
        let nAmount = dictTrans["amount"]
        let strAmount = String(describing: nAmount!)
        cell.lblAmount.text = "Rs. " + strAmount
        
        let strDate = dictTrans["createdAt"] as? String ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let deliver: Date? = formatter.date(from: strDate)
        formatter.dateFormat = "dd/MM/yyyy \n h:mm a"
      //  formatter.timeZone = "HH:mm"
        let strTransDate = formatter.string(from: deliver!)
        cell.lblDate.text = strTransDate
        
        if strType.lowercased() == "credit"
        {
            cell.viewType.topColor = UIColor(red: 0/255, green: 211/255, blue: 172/255, alpha: 1.0)
            cell.viewType.bottomColor = UIColor(red: 0/255, green: 177/255, blue: 138/255, alpha: 1.0)
            
            let strCreditFrom = dictTrans["bank_name"] as? String ?? ""
            cell.lblOrderFor.text = "Via " + strCreditFrom
        }
        else
        {
            cell.viewType.topColor = UIColor(red: 90/255, green: 207/255, blue: 245/255, alpha: 1.0)
            cell.viewType.bottomColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1.0)
            
            let strDebitFor = dictTrans["book_id"] as? String ?? ""
            cell.lblOrderFor.text = "For " + strDebitFor
        }
        
        return cell
        
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 90
    }
    
    
}
