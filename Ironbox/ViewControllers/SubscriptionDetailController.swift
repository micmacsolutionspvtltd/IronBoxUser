//
//  SubscriptionDetailController.swift
//  Ironbox
//
//  Created by MAC on 21/05/22.
//  Copyright © 2022 Gopalsamy A. All rights reserved.
//

import UIKit
import Alamofire

class SubscriptionDetailController: UIViewController {

    @IBOutlet weak var noHistoryLbl: UILabel!
    @IBOutlet weak var seeAllLbl: UILabel!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var totalCreditBalanceLbl: UILabel!
    
    @IBOutlet weak var expiryDateLbl: UILabel!
    @IBOutlet weak var rechargeDateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var packageNameLbl: UILabel!
    @IBOutlet weak var availableBalanceLbl: UILabel!
    @IBOutlet weak var topItemContentView: UIView!
    @IBOutlet weak var seeAllBtn: UIButton!
    var viewAll : Bool? = false
    var subscriptionDetails : SubscriptionDetailModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prePareViews()
        
    }
    private func prePareViews(){
        historyTableView?.register(AddPackageTableViewCell.nib, forCellReuseIdentifier: AddPackageTableViewCell.identifier)
        navigationController?.navigationBar.isHidden = true
        historyTableView.delegate = self
        historyTableView.dataSource = self
        getSubscriptionDetailsApi()
    }
    @IBAction func viewPackageAtn(_ sender: Any) {
        let subscriptionVc = self.storyboard?.instantiateViewController(withIdentifier: "AddPackageViewController") as! AddPackageViewController
               navigationController?.pushViewController(subscriptionVc, animated: true)
    }
    
    @IBAction func backBtnAtn(_ sender: Any) {
        if viewAll ?? false{
            viewAll = false
            seeAllLbl.text = "Show all"
            topItemContentView.isHidden = false
            historyTableView.reloadData()
        }else{
            navigationController?.popViewController(animated: true)
        }

    }
    
    @IBAction func seeAllAtn(_ sender: Any) {
        if viewAll ?? false{
            viewAll = false
            seeAllLbl.text = "Show all"
            topItemContentView.isHidden = false
            historyTableView.reloadData()
        }else{
            viewAll = true
            seeAllLbl.text = "Show less"
            topItemContentView.isHidden = true
            historyTableView.reloadData()
        }
        
    }
    func getSubscriptionDetailsApi(){
        view.addSubview(UIView().customActivityIndicator(view: (self.view)!, widthView: nil, message: "Loading"))

        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        var param: [String: Any] = ["":""]
       
        AlamofireHC.requestPOSTMethod(SUBSCRIPTION_DETAILS, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            let results : Data? = JSON
            UIView().hideLoader(removeFrom: (self.view)!)

            if results != nil{
                do
                {
                let response = try JSONDecoder().decode(SubscriptionDetailModel.self, from: results!)
                    if response.status == "true"{
                        self.subscriptionDetails = response
                        self.subscriptionDetailData(data: response)
                    }else{
                        
                    }
               
                }  catch let error as NSError
                {
                    print(error)
                }
            }else{
               
                print("Something Went wrong")
            }

       
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.view)!)
            print(error)
        })
    }
    func subscriptionDetailData(data : SubscriptionDetailModel){
        totalCreditBalanceLbl.text = ((data.totalPoints ?? ""))
        availableBalanceLbl.text = ((data.remainingPoints ?? ""))
        packageNameLbl.text = data.subscribtionname
        rechargeDateLbl.text = "Recharge Date \(changeFormatMonthAndYear(date: data.subscribers?.paymentdate ?? ""))"
        expiryDateLbl.text = "Expiry Date \(changeFormatMonthAndYear(date: data.subscribers?.expiryDate ?? ""))"
        descriptionLbl.text = data.subscribers?.description ?? ""
        if data.bookHistory?.count == 0{
            noHistoryLbl.isHidden = false
        }else{
            noHistoryLbl.isHidden = true
        }
        historyTableView.reloadData()
    }
}

extension SubscriptionDetailController :
    UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewAll ?? false{
            return subscriptionDetails?.bookHistory?.count ?? 0
        }else{
            if (subscriptionDetails?.bookHistory?.count ?? 0) < 5{
                return subscriptionDetails?.bookHistory?.count ?? 0
            }else{
                return 5
            }

        }
 //  return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

//        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "bookHistoryCell")as? BookingHistoryCell
        else{return UITableViewCell()}
        cell.clothCountLbl.text = String(subscriptionDetails?.bookHistory?[indexPath.row].quantity ?? 0)
        cell.bookingDateLbl.text = subscriptionDetails?.bookHistory?[indexPath.row].bookingDate ?? ""
        cell.bookingIdLbl.text = subscriptionDetails?.bookHistory?[indexPath.row].bookingId ?? ""
        cell.creditPonitsLbl.text = subscriptionDetails?.bookHistory?[indexPath.row].subPoints ?? ""
        return cell
    }
    
    
}
