//
//  MySubscriptionTransactionsVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 22/06/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Alamofire

class MySubscriptionTransactionsVC: UIViewController ,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableMySubscriptionTransactions: UITableView!
    var arrTransactions = Array<Any>()
    var strPackageID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setFontFamilyAndSize()
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]
        
        self.navigationItem.hidesBackButton = true
        let btnBack = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItems([item], animated: true)
        
        self.getTransactions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - ACTIONS
    
    @objc func ClickonBackBtn()
    {
        appDelegate.IsfromPackageConfirmation = false
        _ = navigationController?.popViewController(animated: true)
    }
    
    func getTransactions()
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        let param: [String: Any] = [
            "packageId":strPackageID
        ]
        
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(MY_PACKAGE_TRANSACTIONS, params: param as [String : AnyObject], headers: header, success: { (JSON) in
                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                self.arrTransactions = json.value(forKey: "response") as! Array<Any>
                if self.arrTransactions.count != 0
                {
                    self.tableMySubscriptionTransactions.delegate = self
                    self.tableMySubscriptionTransactions.dataSource = self
                    self.tableMySubscriptionTransactions.reloadData()
                    self.tableMySubscriptionTransactions.isHidden = false
                    
                }
                else
                {
                    self.tableMySubscriptionTransactions.isHidden = true
                }
                
                
            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                // self.ShowAlert(msg: errorMessage)
                self.tableMySubscriptionTransactions.isHidden = true
            }
            
            
        }, failure: { (error) in
               UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
            self.tableMySubscriptionTransactions.isHidden = true
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MySubscriptionTransactionsTableViewCell", for: indexPath) as! MySubscriptionTransactionsTableViewCell
        cell.selectionStyle = .none
        
        
         let dictTrans = self.arrTransactions[indexPath.row] as! Dictionary<String, Any>
         cell.lblBookingID.text = dictTrans["bookingId"] as? String ?? ""

         
         let nAmount = dictTrans["amount"]
         let strAmount = String(describing: nAmount!)
         cell.lblAmount.text = "Rs." + strAmount
        
        let nClothes = dictTrans["total_clothes"]
        let strClothes = String(describing: nClothes!)
        cell.lblTotalClothes.text =  strClothes
        
         let strDate = dictTrans["payment_date"] as? String ?? ""
         let formatter = DateFormatter()
         formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
         let deliver: Date? = formatter.date(from: strDate)
         formatter.dateFormat = "dd/MM/yyyy"
         let strTransDate = formatter.string(from: deliver!)
         cell.lblDate.text = strTransDate
         
        
        
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
