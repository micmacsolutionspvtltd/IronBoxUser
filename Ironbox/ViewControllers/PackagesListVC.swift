//
//  PackagesListVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 21/06/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Alamofire

class PackagesListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tablePackagesList = UITableView()
    var arrPackages = Array<Any>()
    
    
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        
        if DeviceType.iPhoneX
        {
           tablePackagesList.frame = CGRect(x: 0, y: 10, width: self.view.frame.size.width , height: self.view.frame.size.height - 200)
        }
        else
        {
            tablePackagesList.frame = CGRect(x: 0, y: 10, width: self.view.frame.size.width , height: self.view.frame.size.height - 150)
        }
        
        
        tablePackagesList.backgroundColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1)
        tablePackagesList.register(UINib(nibName: "PackagesListTableViewCell", bundle: nil), forCellReuseIdentifier: "PackagesListTableViewCell")
        tablePackagesList.separatorStyle = .none
        tablePackagesList.delegate = self
        tablePackagesList.dataSource = self
        view.addSubview(tablePackagesList)
    
        self.getPackages()
        
    }
    
    required init?(coder: NSCoder)
    {
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
    
    // MARK: - GET PACKAGES
    func getPackages()
    {
       
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
       
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(GET_PACKAGES, params: nil, headers: header, success: { (JSON) in
            //    UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                self.arrPackages = json.value(forKey: "response") as! Array<Any>
                if self.arrPackages.count != 0
                {
                    self.tablePackagesList.delegate = self
                    self.tablePackagesList.dataSource = self
                    self.tablePackagesList.reloadData()
                    self.tablePackagesList.isHidden = false
                    self.view.backgroundColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1)
                }
                else
                {
                    self.tablePackagesList.isHidden = true
                    self.view.backgroundColor = UIColor.clear
                }
                
                
            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                // self.ShowAlert(msg: errorMessage)
                self.tablePackagesList.isHidden = true
                self.view.backgroundColor = UIColor.clear
            }
            
            
        }, failure: { (error) in
            //   UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
            self.tablePackagesList.isHidden = true
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackagesListTableViewCell", for: indexPath) as! PackagesListTableViewCell
        cell.selectionStyle = .none
       
        let dictPackages = self.arrPackages[indexPath.row] as! Dictionary<String, Any>
        cell.lblOriginalRate.text = dictPackages["actual_price"] as? String ?? ""
        cell.lblRatePerCloth.text = dictPackages["price"] as? String ?? ""
        cell.lblTotalClothes.text = dictPackages["no_of_clothes"] as? String ?? ""
        cell.lblPackageDetail.text = dictPackages["packages_cost"] as? String ?? ""
        
        cell.lblOriginalRate.layer.cornerRadius = cell.lblOriginalRate.frame.size.height/2
        cell.lblOriginalRate.clipsToBounds = true
        
        return cell
        
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let dictPackages = self.arrPackages[indexPath.row] as! Dictionary<String, Any>
        
        let story = UIStoryboard.init(name: "Main", bundle: nil)
        let PackageConfirmationVC = story.instantiateViewController(withIdentifier: "PackageConfirmationVC")as! PackageConfirmationVC
        PackageConfirmationVC.dictPackage = dictPackages
        self.navigationController?.pushViewController(PackageConfirmationVC, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 135
    }
    
    
}
