//
//  RateCardVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 06/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import Spring

class RateCardVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var viewBG: SpringView!
    @IBOutlet weak var tableRateCard: UITableView!
    @IBOutlet weak var lblTax: UILabel!
    var arrRateCard = Array<Any>()
    var arrCategory = Array<Any>()
    
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
        self.getRateCard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
     // MARK: - GET RATE CARD DETAILS
    func getRateCard()
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(GET_RATECARD, params: nil, headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
          //  print("Hello Swift",header)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                self.arrRateCard = json.value(forKey: "response") as! Array<Any>
                self.lblTax.text = json.value(forKey: "tax") as? String ?? ""
                for var i in 0..<self.arrRateCard.count
                {
                    var dictRateCard = self.arrRateCard[i] as! Dictionary<String, Any>
                    dictRateCard["isSelected"] = "0"
                    
                    var arrCateg =  dictRateCard["Category"] as! Array<Any>
                    for var j in 0..<arrCateg.count
                    {
                        var dictCateg = arrCateg[j] as! Dictionary<String, Any>
                        dictCateg["isSelectedCateg"] = "0"
                        arrCateg.remove(at: j)
                        arrCateg.insert(dictCateg, at: j)
                    }
                    
                    dictRateCard["Category"] = arrCateg
                    self.arrRateCard.remove(at: i)
                    self.arrRateCard.insert(dictRateCard, at: i)
                }
                
                if self.arrRateCard.count != 0
                {
                    self.tableRateCard.delegate = self
                    self.tableRateCard.dataSource = self
                    self.tableRateCard.reloadData()
                    self.tableRateCard.isHidden = false
                }
                else
                {
                    self.tableRateCard.isHidden = true
                }
                
                self.viewBG.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4)
                {
                    self.viewBG.isHidden = false
                    self.viewBG.animation = "fadeIn"
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
                self.tableRateCard.isHidden = true
            }
            
            
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
            self.tableRateCard.isHidden = true
        })
        
    }

    // MARK: - ACTIONS
    @objc func onExtendCategory(btn:UIButton)
    {
        let btnTag = btn.tag - 10000
        let indexpath = NSIndexPath(row:btnTag, section: 0)
        let cell = tableRateCard.cellForRow(at: indexpath as IndexPath) as! RateCardTableViewCell?
        var dict = self.arrRateCard[btnTag] as! Dictionary<String, Any>
        let isSelected = dict["isSelected"] as? String ?? ""
        if isSelected == "1"
        {
            dict["isSelected"] = "0"
            self.arrRateCard.remove(at: btnTag)
            self.arrRateCard.insert(dict, at: btnTag)
            self.tableRateCard.reloadRows(at: [indexpath as IndexPath], with: .automatic)
           
            
        }
        else
        {
            dict["isSelected"] = "1"
            self.arrRateCard.remove(at: btnTag)
            self.arrRateCard.insert(dict, at: btnTag)
            tableRateCard.reloadRows(at: [indexpath as IndexPath], with: .automatic)
        }
    }
    
    
    @objc func ClickonBackBtn()
    {
        _ = navigationController?.popViewController(animated: true)
    }
    @IBAction func onTop(_ sender: Any)
    {
        
    }
    
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let dict = arrRateCard[indexPath.row] as! NSDictionary
        let isSelected = dict["isSelected"] as? String ?? ""
        if isSelected == "1"
        {
            let arSts = dict["Category"] as! Array<Any>
            var nHeight = 0
            for var j in 0..<arSts.count
            {
                var dictCateg = arSts[j] as! Dictionary<String, Any>
                let isSelectedCateg = dictCateg["isSelectedCateg"] as? String ?? ""
                if isSelectedCateg == "1"
                {
                    let arCateg = dictCateg["arrSubCategory"] as! Array<Any>
                    nHeight = nHeight + (arCateg.count * 40)
                }
            }
             return CGFloat((arSts.count * 45) + 50 + nHeight)
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrRateCard.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RateCardTableViewCell", for: indexPath) as! RateCardTableViewCell
        cell.selectionStyle = .none
        
        cell.btnCategoryPlusMinus.tag = indexPath.row + 10000
        cell.btnCategoryPlusMinus.addTarget(self, action: #selector(self.onExtendCategory(btn:)), for: .touchUpInside)
        
        let dictRateCard = self.arrRateCard[indexPath.row] as! Dictionary<String, Any>
        cell.lblCategoryName.text = dictRateCard["CategoryName"] as? String ?? ""
        cell.lblPrice.text = dictRateCard["price"] as? String ?? ""
        let qty = dictRateCard["quantity"]
        cell.lblQuantity.text = String(describing: qty!)
     //   cell.lblExample.text = dictRateCard["description"] as? String ?? ""
        
         let arSts = dictRateCard["Category"] as! Array<Any>
        let isSelected = dictRateCard["isSelected"] as? String ?? ""
        if isSelected == "1"
        {
            cell.collectionViewHeight.constant = CGFloat(arSts.count * 43)
            cell.btnCategoryPlusMinus.setTitle("-", for: .normal)
        }
        else
        {
            cell.collectionViewHeight.constant = 0
            cell.btnCategoryPlusMinus.setTitle("+", for: .normal)
        }
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        guard let tableViewCell = cell as? RateCardTableViewCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? RateCardTableViewCell else { return }
        
    }
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
   
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let dict = arrRateCard[collectionView.tag] as! NSDictionary
        self.arrCategory = dict["Category"] as! Array<Any>
        return arrCategory.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RateCardCollectionViewCell", for: indexPath) as! RateCardCollectionViewCell
        let dict = arrRateCard[collectionView.tag] as! NSDictionary
        let arSts = dict["Category"] as! Array<Any>
        let dictSts = arSts[indexPath.row] as! NSDictionary
        let strStatusName = dictSts["SubCategoryName"] as? String ?? ""
        cell.lblName.text = strStatusName
        
        if dictSts["arrSubCategory"] != nil
        {
           // cell.lblName.textColor = UIColor.white
            cell.btnPlusMinus.isHidden = false
            
            let isSelected = dictSts["isSelectedCateg"] as? String ?? ""
            if isSelected == "1"
            {
                cell.btnPlusMinus.setTitle("-", for: .normal)
            }
            else
            {
                cell.btnPlusMinus.setTitle("+", for: .normal)
            }
            
            
            let arrSubCat = dictSts["arrSubCategory"] as! Array<Any>
            var yPos = 40
            for var j in 0..<arrSubCat.count
            {
                 let dictSubCat = arrSubCat[j] as! NSDictionary
                
                let viewDot = UIView(frame: CGRect(x: 40, y:Int(yPos + 17), width:5, height: 5))
                viewDot.backgroundColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1)
              //  viewDot.layoutIfNeeded() //This is important line
                viewDot.layer.cornerRadius = viewDot.frame.size.height / 2
                cell.contentView.addSubview(viewDot)
                
                let lblSure = UILabel(frame: CGRect(x: 53, y: yPos, width: Int(cell.contentView.frame.size.width), height: 40))
                // lblSure.center = CGPoint(x: viewLogoutDialouge.frame.midX, y: viewLogoutDialouge.frame.midY)
                lblSure.textAlignment = .left
                lblSure.text = dictSubCat["name"] as? String ?? ""
                lblSure.font = UIFont(name: FONT_BOLD, size: 14)
                lblSure.textColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1)
                cell.contentView.addSubview(lblSure)
                yPos = yPos + 40
            }
            
            let btnTop:UIButton = UIButton(frame:  CGRect(x: 0, y: 40, width: Int(cell.contentView.frame.size.width), height: yPos))
          //  btnTop.backgroundColor = UIColor.red
            btnTop.addTarget(self, action: #selector(self.onTop(_:)), for:.touchUpInside)
          //  btnTop.layoutIfNeeded() //This is important line
            cell.addSubview(btnTop)
            
           cell.lblName.sizeToFit()

        }
        else
        {
           // cell.lblName.textColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:1)
            cell.btnPlusMinus.isHidden = true
              cell.lblName.sizeToFit()
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
        var dict = arrRateCard[collectionView.tag] as! Dictionary<String, Any>
        var arSts = dict["Category"] as! Array<Any>
        var dictSts = arSts[indexPath.row] as! Dictionary<String, Any>
        if dictSts["arrSubCategory"] != nil
        {
            let isSelectedCateg = dictSts["isSelectedCateg"] as? String ?? ""
            if isSelectedCateg == "1"
            {
                 dictSts["isSelectedCateg"] = "0"
            }
            else
            {
                 dictSts["isSelectedCateg"] = "1"
            }
           
            arSts.remove(at: indexPath.row)
            arSts.insert(dictSts, at: indexPath.row)
            dict["Category"] = arSts
            arrRateCard.remove(at: collectionView.tag)
            arrRateCard.insert(dict, at: collectionView.tag)
            let indexpath = NSIndexPath(row:collectionView.tag, section: 0)
            self.tableRateCard.reloadRows(at: [indexpath as IndexPath], with: .automatic)
        }
        
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.invalidateLayout()
        var dict = arrRateCard[collectionView.tag] as! Dictionary<String, Any>
        var arSts = dict["Category"] as! Array<Any>
        var dictSts = arSts[indexPath.row] as! Dictionary<String, Any>
        let isSelectedCateg = dictSts["isSelectedCateg"] as? String ?? ""
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        if isSelectedCateg == "1"
        {
            let arSts = dictSts["arrSubCategory"] as! Array<Any>
            return CGSize(width:collectionView.bounds.width , height:CGFloat((arSts.count * 40) + 40))
            
        }
        
        return CGSize(width: collectionView.bounds.width, height:40)
    }
    
}
