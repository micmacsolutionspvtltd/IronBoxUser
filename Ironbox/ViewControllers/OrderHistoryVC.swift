//
//  OrderHistoryVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 07/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView

class OrderHistoryVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    

    @IBOutlet weak var tableOrders: UITableView!
    var arrHistory = Array<Any>()
    var arrStatus = Array<Any>()
    var currentPageNumber = Int()
    var totalPages = Int()
    var strBookingIdForBillingDetails = ""
    var ViewTutorial = UIView()
    var ImgTutorial = UIImageView()
    var isOrderHistoryCalledOnce:Bool = false
    
    let yourAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont(name: FONT_MEDIUM, size: 14)!,
        NSAttributedStringKey.foregroundColor : UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0),
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
    
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
        
        self.tableOrders.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        currentPageNumber = 1
    }

    override func viewWillAppear(_ animated: Bool)
    {
        if ((userDefaults.value(forKey: IS_HISTORY_TUTORIAL_SHOWN) as? String) == nil)
        {
            self.showTutorialScreen()
        }
        else
        {
            if isOrderHistoryCalledOnce == false
            {
                self.getOrderHistory()
            }
            
        }
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TUTORIAL SCREEN
    func showTutorialScreen()
    {
        ViewTutorial.removeFromSuperview()
        let screenSize: CGRect = UIScreen.main.bounds
        ViewTutorial = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        ViewTutorial.backgroundColor = UIColor(red: 18/255, green: 24/255, blue: 38/255, alpha: 0.852)
        self.navigationController?.view.addSubview(ViewTutorial)
        
        ImgTutorial  = UIImageView(frame:CGRect(x:0, y:0, width:screenSize.width, height:screenSize.height));
        ImgTutorial.image = UIImage(named:"TutoHistory1")
        ViewTutorial.addSubview(ImgTutorial)
        
        let btnNxt:UIButton = UIButton(frame:  CGRect(x: screenSize.width - 100, y: screenSize.height - 50, width: 100, height: 50))
        btnNxt.backgroundColor = UIColor.white
        btnNxt.addTarget(self, action: #selector(self.onTutorialNext(_:)), for:.touchUpInside)
        ViewTutorial.addSubview(btnNxt)
    }
    @IBAction func onTutorialNext(_ sender: Any)
    {
        userDefaults.set("yes", forKey: IS_HISTORY_TUTORIAL_SHOWN)
        ViewTutorial.removeFromSuperview()
        self.getOrderHistory()
    }

     // MARK: - GET HISTORY
    func getOrderHistory()
    {
        isOrderHistoryCalledOnce = true
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        let param: [String: Any] = [
            "page_number":currentPageNumber
        ]
        
        self.CheckNetwork()
        
        if currentPageNumber == 1
        {
            self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        }
        
        AlamofireHC.requestPOST(BOOKING_HISTORY, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            if self.currentPageNumber == 1
            {
                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            }
           
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                self.totalPages = json.value(forKey: "pages") as! Int
                var arrBookingList = json.value(forKey: "BookingList") as! Array<Any>
                for var i in 0..<arrBookingList.count
                {
                    var dictBookings = arrBookingList[i] as! Dictionary<String, Any>
                    let strOrdStatus = dictBookings["Status"] as? String ?? ""
                    
                    if strOrdStatus == "CANCELLED"
                    {
                        var dictBookings = arrBookingList[i] as! Dictionary<String, Any>
                        dictBookings["isSelected"] = "0"
                        
                        var arrOrdSts = dictBookings["OrderStatus"] as! Array<Any>
                        var arrOrderStatus = Array<Any>()
                        for var j in 0..<arrOrdSts.count
                        {
                            var dictStatus = arrOrdSts[j] as! Dictionary<String, Any>
                            let strStatus = dictStatus["Status"] as? String ?? ""
                            if strStatus == "Yes"
                            {
                                arrOrderStatus.append(dictStatus)
                            }
                        }
                        var dictCanceledStatus =  Dictionary<String, Any>()
                        dictCanceledStatus["name"] = "Order Cancelled"
                        dictCanceledStatus["Status"] = "Yes"
                        dictCanceledStatus["date"] = dictBookings["CancelDate"] as? String ?? ""
                        arrOrderStatus.append(dictCanceledStatus)
                        
                        dictBookings["OrderStatus"] = arrOrderStatus
                        arrBookingList.remove(at: i)
                        arrBookingList.insert(dictBookings, at: i)
                    }
                    else
                    {
                        dictBookings["isSelected"] = "0"
                        arrBookingList.remove(at: i)
                        arrBookingList.insert(dictBookings, at: i)
                    }
                   
                    
                }
                
                self.arrHistory += arrBookingList
                if self.arrHistory.count != 0
                {
                    self.tableOrders.delegate = self
                    self.tableOrders.dataSource = self
                    self.tableOrders.reloadData()
                    self.tableOrders.isHidden = false
                }
                else
                {
                    self.tableOrders.isHidden = true
                }
                
            }
            else
            {
                if self.arrHistory.count == 0
                {
                    self.tableOrders.isHidden = true
                }
                
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
            }
            
            
        }, failure: { (error) in
            if self.currentPageNumber == 1
            {
                UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            }
            print(error)
            if self.arrHistory.count == 0
            {
                self.tableOrders.isHidden = true
            }
        })
        
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrHistory.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let dict = arrHistory[indexPath.row] as! NSDictionary
        let isSelected = dict["isSelected"] as? String ?? ""
        
        if isSelected == "1"
        {
            self.arrStatus = dict["OrderStatus"] as! Array<Any>
        
            return CGFloat((arrStatus.count * 43) + 230)
            //    return 485
        }
        return 210
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryTableViewCell", for: indexPath) as! OrderHistoryTableViewCell
        cell.selectionStyle = .none
        let dictBooking = self.arrHistory[indexPath.row] as! Dictionary<String, Any>
        
//        let bookingID = dictBooking["id"]
//        let strBookingID = String(describing: bookingID!)
        cell.lblBookingId.text = dictBooking["bookingId"] as? String ?? ""
        
        let strPaymentType = dictBooking["paymentType"] as? String ?? ""
        cell.lblPaymentMode.text = strPaymentType.uppercased()
        
        let Qty = dictBooking["quantity"]
        let strQty = String(describing: Qty!)
        
        if strQty == ""
        {
            cell.lblQuantity.text = "Not updated"
        }
        else
        {
            cell.lblQuantity.text = strQty
        }
        
        
        
        
        let strStatus = dictBooking["Status"] as? String ?? ""
        cell.lblStatus.text = strStatus
        var strDescription = dictBooking["description"] as? String ?? ""
        strDescription = "\"" + strDescription + "\""
        cell.lblDescription.text = strDescription
        let strTime = dictBooking["TimeSlot"] as? String ?? ""
        cell.lblTimeSlot.text =  strTime
        let strDate = dictBooking["bookingDate"] as? String ?? ""
        var dateArr = strDate.components(separatedBy: "-")
        let strDat: String = dateArr[0]
        let strMon: String = dateArr[1]
        cell.lblDate.text = strDat + "/" + strMon
        
        if strStatus == "CANCELLED"
        {
            cell.viewDetailsWithColor.topColor = UIColor(red: 249/255, green: 169/255, blue: 95/255, alpha: 1.0)
            cell.viewDetailsWithColor.bottomColor = UIColor(red: 248/255, green: 111/255, blue: 92/255, alpha: 1.0)
            cell.imgStatusIcon.image = UIImage(named: "Cancelled")
        }
        else
        {
            cell.viewDetailsWithColor.topColor = UIColor(red: 90/255, green: 207/255, blue: 245/255, alpha: 1.0)
            cell.viewDetailsWithColor.bottomColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1.0)
            cell.imgStatusIcon.image = UIImage(named: "Confirmed")
        }
        cell.viewDetailsWithColor.layoutIfNeeded()
        cell.btnTrackYourOrder.tag = indexPath.row + 10000
        cell.btnTrackYourOrder.addTarget(self, action: #selector(self.onTrackOrder(btn:)), for: .touchUpInside)
        
        cell.btnTrackYourOrder1.tag = indexPath.row + 15000
        cell.btnTrackYourOrder1.addTarget(self, action: #selector(self.onTrackOrder(btn:)), for: .touchUpInside)
        
        cell.btnBillingDetails.tag = indexPath.row + 25000
        cell.btnBillingDetails.addTarget(self, action: #selector(self.onBillingDetails(btn:)), for: .touchUpInside)
        let attributeString1 = NSMutableAttributedString(string: "VIEW BILLING DETAILS",
                                                         attributes: yourAttributes)
        cell.btnBillingDetails.setAttributedTitle(attributeString1, for: .normal)
        
        let isSelected = dictBooking["isSelected"] as? String ?? ""
        
        if isSelected == "1"
        {
            let isPickupSuccess = dictBooking["PickupSuccess"]
            let strisPickupSuccess = String(describing: isPickupSuccess!)
            if strisPickupSuccess == "0"
            {
                 cell.btnBillingDetails.isHidden = true
            }
            else
            {
                 cell.btnBillingDetails.isHidden = false
            }
            
            cell.viewTracking.frame.size.height = 50
            cell.progressBar.isHidden = false
            cell.lblTrackYourOrder.isHidden = true
            cell.btnTrackYourOrder.isHidden = true
            UIView.animate(withDuration: 0.4, animations: {
                let arSts = dictBooking["OrderStatus"] as! Array<Any>
                cell.viewTracking.frame.size.height = CGFloat((arSts.count * 43) + 75)
                cell.heightCollectionView.constant = CGFloat(arSts.count * 43)
              
                cell.imgArrow.image = UIImage(named: "UpArrow")
                cell.viewTracking.layoutIfNeeded()
                cell.progressBar.layoutIfNeeded()
                
                cell.OrderStatusShapeLayer?.removeFromSuperlayer()
                
                // create whatever path you want
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 2, y: 0))
                path.addLine(to: CGPoint(x: 2, y: 0))
                path.addLine(to: CGPoint(x: 2, y: cell.progressBar.frame.size.height))
                //path.addLine(to: CGPoint(x: 200, y: 240))
                
                // create shape layer for that path
                let shapeLayer = CAShapeLayer()
                shapeLayer.fillColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 0.4).cgColor
                shapeLayer.strokeColor = #colorLiteral(red: 0.09019607843, green: 0.7254901961, blue: 0.4705882353, alpha: 1).cgColor
                shapeLayer.lineWidth = 4
                shapeLayer.path = path.cgPath
                
                // animate it
                cell.progressBar.layer.addSublayer(shapeLayer)
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = 0
                animation.duration = 2
                shapeLayer.add(animation, forKey: "MyAnimation")
                
                // save shape layer
                cell.OrderStatusShapeLayer = shapeLayer
                
            }, completion: {
                (value: Bool) in
            })
        }
        else
        {
            cell.viewTracking.frame.size.height = 50
            cell.imgArrow.image = UIImage(named: "DownArrow")
            cell.progressBar.isHidden = true
            cell.btnBillingDetails.isHidden = true
            cell.lblTrackYourOrder.isHidden = false
            cell.btnTrackYourOrder.isHidden = false
        }
       // cell.viewTracking.layoutIfNeeded()
        //  cell.contentView.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? OrderHistoryTableViewCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        
        let lastCell = self.arrHistory.count - 1
        if indexPath.row == lastCell {
            if currentPageNumber <  totalPages{
                currentPageNumber = currentPageNumber + 1
                self.getOrderHistory()
            }
        }
        
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animate(withDuration: 0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1.05, 1.05, 1)
        },completion: { finished in
            UIView.animate(withDuration: 0.1, animations: {
                cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
            })
        }) 
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? OrderHistoryTableViewCell else { return }
        
    }
    
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
    
     // MARK: - ACTIONS
    @objc func ClickonBackBtn()
    {
        _ = navigationController?.popViewController(animated: true)
    }
    @objc func onTrackOrder(btn:UIButton)
    {
        var btnTag = btn.tag - 10000
        if btn.tag >= 15000
        {
            btnTag = btn.tag - 15000
        }
        else
        {
            btnTag = btn.tag - 10000
        }
        
        let indexpath = NSIndexPath(row:btnTag, section: 0)
        var dictBookings = self.arrHistory[btnTag] as! Dictionary<String, Any>
        let isSelected = dictBookings["isSelected"] as? String ?? ""
        if isSelected == "1"
        {
            dictBookings["isSelected"] = "0"
            let cell = tableOrders.cellForRow(at: indexpath as IndexPath) as! OrderHistoryTableViewCell?
            let arSts = dictBookings["OrderStatus"] as! Array<Any>
            cell?.viewTracking.frame.size.height = CGFloat((arSts.count * 43) + 75)
            UIView.animate(withDuration: 0.4, animations: {
                cell?.viewTracking.frame.size.height = 50
            }, completion: {
                (value: Bool) in
                cell?.imgArrow.image = UIImage(named: "DownArrow")
                cell?.progressBar.isHidden = true
                self.arrHistory.remove(at: btnTag)
                self.arrHistory.insert(dictBookings, at: btnTag)
                self.tableOrders.reloadRows(at: [indexpath as IndexPath], with: .automatic)
            })
            
        }
        else
        {
            dictBookings["isSelected"] = "1"
            self.arrHistory.remove(at: btnTag)
            self.arrHistory.insert(dictBookings, at: btnTag)
            tableOrders.reloadRows(at: [indexpath as IndexPath], with: .automatic)
        }
        
        
        
    }
    
    
    @objc func onBillingDetails(btn:UIButton)
    {
        let btnTag = btn.tag - 25000
        let dict = self.arrHistory[btnTag] as! Dictionary<String, Any>
        let bookingID = dict["id"]
        strBookingIdForBillingDetails = String(describing: bookingID!)
        self.performSegue(withIdentifier: "History_Billing", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "History_Billing")
        {
            let billingVC = segue.destination as! BillingDetailsVC
            billingVC.strBookingId = strBookingIdForBillingDetails
            
        }
    }

    
    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let dict = arrHistory[collectionView.tag] as! NSDictionary
        self.arrStatus = dict["OrderStatus"] as! Array<Any>
        return arrStatus.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpandDataCollectionViewCell", for: indexPath) as! ExpandDataCollectionViewCell
        let dict = arrHistory[collectionView.tag] as! NSDictionary
        
        let isSelected = dict["isSelected"] as? String ?? ""
        if isSelected == "1"
        {
            let arSts = dict["OrderStatus"] as! Array<Any>
            let dictSts = arSts[indexPath.row] as! NSDictionary
            let strStatusName = dictSts["name"] as? String ?? ""
            cell.lblStatus.text = strStatusName
            
            if strStatusName  == "Order Cancelled"
            {
                cell.lblStatus.textColor = UIColor(red: 247/255, green: 89/255, blue: 64/255, alpha: 1.0) // Orange
                cell.viewDot.backgroundColor = UIColor(red: 247/255, green: 89/255, blue: 64/255, alpha: 1.0) // Orange
            }
            else
            {
                cell.lblStatus.textColor = UIColor(red: 23/255, green: 185/255, blue: 120/255, alpha: 1.0) // Green
                cell.viewDot.backgroundColor = UIColor(red: 23/255, green: 185/255, blue: 120/255, alpha: 1.0) // Green
            }
        }
        else
        {
            cell.lblStatus.textColor = UIColor.clear
            cell.viewDot.backgroundColor = UIColor.clear
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
       
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.invalidateLayout()
        return CGSize(width: collectionView.frame.width , height:40)
    }
    
}


/*

 {
 var dictBookings = self.arrHistory[i] as! Dictionary<String, Any>
 dictBookings["isSelected"] = "0"
 
 var arrOrdSts = dictBookings["OrderStatus"] as! Array<Any>
 var arrOrderStatus = Array<Any>()
 for var j in 0..<arrOrdSts.count
 {
 var dictStatus = arrOrdSts[j] as! Dictionary<String, Any>
 let strStatus = dictStatus["Status"] as? String ?? ""
 if strStatus == "Yes"
 {
 arrOrderStatus.append(dictStatus)
 }
 }
 dictBookings["OrderStatus"] = arrOrderStatus
 self.arrHistory.remove(at: i)
 self.arrHistory.insert(dictBookings, at: i)
 print(json)
 print(self.arrHistory)
 }

*/
