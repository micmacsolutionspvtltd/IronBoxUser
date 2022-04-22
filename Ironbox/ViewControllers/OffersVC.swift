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

class OffersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableOffers: UITableView!
    var arrOffers = Array<Any>()
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
    
        self.getOffers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - GET ALL OFFERS
    func getOffers()
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        let param: [String: Any] = [
            "offet_type":"All",
            "booked_areaid":"",
            "booked_date":"",
            "booked_timeslot":""
        ]
        
    
        
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(GET_OFFERS, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                
                self.arrOffers = json.value(forKey: "prmocode") as! Array<Any>
                if self.arrOffers.count != 0
                {
                    self.tableOffers.delegate = self
                    self.tableOffers.dataSource = self
                    self.tableOffers.reloadData()
                    self.tableOffers.isHidden = false
                    
                }
                else
                {
                    self.tableOffers.isHidden = true
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
                self.tableOffers.isHidden = true
            }
            
            
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
            self.tableOffers.isHidden = true
        })
        
    }
    
    // MARK: - ACTIONS
    @objc func ClickonBackBtn()
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
         return arrOffers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OffersTableViewCell", for: indexPath) as! OffersTableViewCell
        cell.selectionStyle = .none
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "dd-MMM-yyyy"
        
        let dictOffers = self.arrOffers[indexPath.row] as! Dictionary<String, Any>
        cell.lblOfferName.text = dictOffers["description"] as? String ?? ""
        cell.lblOfferValidity.text = dictOffers["validity"] as? String ?? ""
        
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
        
        let strProCode = dictOffers["promocode"] as? String ?? ""
        cell.lblOfferCode.text = "Use Code: " + strProCode
      
        if dictOffers["images"] as? String != nil
        {
            var strImageURL = dictOffers["images"] as? String ?? ""
            strImageURL = strImageURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            //  cell.imgDriver.sd_setImage(with: URL(string: strImageURL), placeholderImage: UIImage(named: "User"), options: .refreshCached)
            cell.imgOffer.imageFromServerURL(urlString: strImageURL)
        }
        else
        {
            //   cell.imgDriver.sd_setImage(with: URL(string: ""), placeholderImage: UIImage(named: "User"), options: .refreshCached)
            
            cell.imgOffer.image = UIImage(named: "OfferPlaceHolder")
        }
        
        
        return cell
        
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 120
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
//start


// End

        }





