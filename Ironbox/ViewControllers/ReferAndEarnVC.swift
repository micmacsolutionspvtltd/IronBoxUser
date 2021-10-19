//
//  ReferAndEarnVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 07/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Spring
import Alamofire

class ReferAndEarnVC: UIViewController,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var viewBG: SpringView!
    @IBOutlet weak var referlist: UITableView!
    var referfullnamelist = Array<Any>()
    var referfulldetaillist = Array<Any>()

    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.referlist.delegate = self
        self.referlist.dataSource = self
        
        self.setFontFamilyAndSize()
        self.hideKeyboardWhenTappedAround()
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]
        
        let btnBack = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItems([item], animated: true)
        let strCode = userDefaults.object(forKey: USER_REFERAL_CODE) as? String ?? ""
        lblCode.text = "CODE: " + strCode
       // referlist.allowsSelection = true

        self.viewBG.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4)
        {
            self.viewBG.isHidden = false
            self.viewBG.animation = "fadeInUp"
            self.viewBG.curve = "easeIn"
            self.viewBG.duration = 1.3
            self.viewBG.repeatCount = 1
            self.viewBG.animate()
        }
        
        let strUser = userDefaults.object(forKey: USER) as? String ?? ""
        
        if (strUser == "0")
        {
            self.referlist.isHidden = true
        }
        else
        {
            self.referlist.isHidden = false
            self.referlist.delegate = self
            self.referlist.dataSource = self
            self.referlist.reloadData()
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    // MARK: - ACTIONS
    @objc func ClickonBackBtn()
    {
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func onSahre(_ sender: Any)
    {
        let strRefAmount = userDefaults.object(forKey: REFERRAL_AMOUNT) as? String ?? ""
        let strCode = userDefaults.object(forKey: USER_REFERAL_CODE) as? String ?? ""
        let shareText = "Use my referral code " +  strCode + " to sign up and get Rs." + strRefAmount + " in your Ironbox wallet. \niOS: " + APP_STORE_URL +  strCode + "\nAndroid: " + PLAY_STORE_URL
        let vc = UIActivityViewController(activityItems: [shareText], applicationActivities: [])
        present(vc, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
       {
            return 1
       }
    
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
       {
           
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReferTableViewCell", for: indexPath)
         
//           let dictOffers = self.referfullnamelist[indexPath.row] as! Dictionary<String, Any>
//
        let strUser = userDefaults.object(forKey: USER) as? String ?? ""

        let strAmount = userDefaults.object(forKey: AMOUNT) as? String ?? ""

        let Name:UILabel = self.view.viewWithTag(1) as! UILabel
        let Detail:UILabel = self.view.viewWithTag(2) as! UILabel
        
        Name.text = strUser + " " + "Users joined"
        Detail.text = "Cash bonus to be earned : $" + strAmount
        return cell
           
       }
    
       // MARK: - TableView Delegate
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
       {
        print("getting")
       
       }
    
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
       {
           return 73
       }

}
