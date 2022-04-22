//
//  MenuController.swift
//  HawkerBells
//
//  Created by Pyramidions Solution on 23/05/17.
//  Copyright © 2017 Pyramidions Solution. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import SideMenu
import Spring
import CircularRevealKit

class MenuController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var imgClose: UIImageView!
    @IBOutlet weak var viewDetails: UIView!
    @IBOutlet weak var imgLogo: SpringImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tableMenu: UITableView!      
    var loginStr = String()
    let del = UIApplication.shared.delegate as! AppDelegate
    var nameStr = String()
    var dict = NSDictionary()
    var ViewLogout = UIView()
    
    // "Refer and earn", "Offers",
    let segues = ["Accounts","Order history", "Rate card", "Address", "Refer and earn",  "Wallet",  "Customer support","About us","Logout"]
    private var previousIndex: NSIndexPath?
    var arrMenuItems: [String] = ["Accounts","Order history", "Rate card", "Address", "Refer and earn",   "Wallet", "Customer support","About us","Logout"]
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad()
    {
        super.viewDidLoad()
        imgLogo.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
        {
            self.imgLogo.isHidden = false
            self.imgLogo.animation = "squeezeLeft"
            self.imgLogo.curve = "easeIn"
            self.imgLogo.duration = 1.5
            self.imgLogo.repeatCount = 1
            self.imgLogo.animate()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.navigationBar.isHidden = true
        self.setImageAndName()
        NotificationCenter.default.addObserver(self, selector: #selector(MenuController.methodOfReceivedNotification(notification:)), name: Notification.Name("SETIMAGEANDNAME"), object: nil)
        
    }
    
    override func viewWillLayoutSubviews()
    {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - NOTIFICATION CENTER
    
    @objc func methodOfReceivedNotification(notification: Notification)
    {
        self.setImageAndName()
    }
    
    // MARK: - SET USER IMAGE AND NAME
    func setImageAndName()
    {
        let userDefaults = UserDefaults.standard
        self.tableMenu.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let strName = userDefaults.object(forKey: USER_NAME) as! String
        self.lblName.text = strName
        
        self.view.reloadInputViews()
        tableMenu.delegate=self;
        tableMenu.dataSource=self;
        
        viewDetails.layoutIfNeeded()
        btnClose.frame = CGRect(x: viewDetails.frame.size.width - 50, y: 0, width: 50, height: 50)
        imgClose.frame = CGRect(x: btnClose.frame.center.x - 7.5, y: btnClose.frame.center.y - 7.5, width: 15, height: 15)
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
            case 1334:
                print("iPhone 6/6S/7/8")
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                print("iPhone X")
                btnClose.frame = CGRect(x: viewDetails.frame.size.width - 50, y: 35, width: 50, height: 50)
                imgClose.frame = CGRect(x: btnClose.frame.center.x - 7.5, y: btnClose.frame.center.y - 7.5, width: 15, height: 15)
            default:
                print("unknown")
            }
        }
        
        
    }
    
    
    
    // MARK: - ACTIONS
    @IBAction func onCloseMenu(_ sender: Any)
    {
       dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onFacebook(_ sender: Any)
    {
        guard let url = URL(string: FACEBOOK_URL) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func onInstagram(_ sender: Any)
    {
        guard let url = URL(string: INSTAGRAM_URL) else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
   
    
    @IBAction func onLogout(_ sender: Any)
    {
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(LOGOUT, params: nil, headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            /* let err = json.value(forKey: "error") as? String ?? ""
             if (err == "false")
             {
             
             }
             else
             {
             let errorMessage = json.value(forKey: "error_message")as? String ?? ""
             self.ShowAlert(msg: errorMessage)
             } */
            
            self.ViewLogout.removeFromSuperview()
            userDefaults.set("", forKey: USER_NAME)
            userDefaults.set("", forKey: USER_MOBILE)
            userDefaults.set("", forKey: USER_ALTERNATE_MOBILE)
            userDefaults.set("", forKey: USER_ID)
            userDefaults.set("", forKey: USER_EMAIL)
            userDefaults.set("", forKey: USER_GENDER)
            userDefaults.set("", forKey: USER_DOB)
            userDefaults.set("", forKey: IS_LOGIN)
            userDefaults.set("", forKey: ACCESS_TOKEN)
            userDefaults.set("", forKey: USER_PROFILE_IMAGE)
            // self.performSegue(withIdentifier: "Menu_Logout", sender: self)
            
            let story = UIStoryboard.init(name: "Main", bundle: nil)
            let SignInVC = story.instantiateViewController(withIdentifier: "SignInVC")as! SignInVC
            self.navigationController?.pushViewController(SignInVC, animated: false)
            
            
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
        })
    }
    
    @IBAction func onLogoutCancel(_ sender: Any)
    {
       
        let viewControllerSize = UIScreen.main.bounds
        let width = viewControllerSize.width
        let height = viewControllerSize.height
        let rect = CGRect(
            origin: CGPoint(
                x: width/2,
                y: height/2),
            size: CGSize(
                width: 0,
                height: 0))
        
        ViewLogout.drawAnimatedCircularMask(
            startFrame: rect,
            duration: 0.33,
            revealType: RevealType.unreveal) { [weak self] in
                self?.ViewLogout.removeFromSuperview()
        }
    }
   
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - TABLE VIEW DATASOURCE & DELEGATE
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
     {
        return arrMenuItems.count
    }
    
     func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell
     {
        let identifier = self.arrMenuItems[indexPath.row]
        let cell:UITableViewCell = self.tableMenu.dequeueReusableCell(withIdentifier: identifier)!
        return cell
    }
    
     func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath)
     {
        
     if indexPath.row == 8
        {
            let screenSize: CGRect = UIScreen.main.bounds
            ViewLogout = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
            ViewLogout.backgroundColor = UIColor(red: 18/255, green: 24/255, blue: 38/255, alpha: 0.852)
            ViewLogout.isHidden = true
            self.navigationController?.view.addSubview(ViewLogout)
            
            let viewLogoutDialouge = SpringView()
            viewLogoutDialouge.frame = CGRect(x: 20, y:(screenSize.height / 2) - ((screenSize.height/4) - 100), width: screenSize.width-40, height: 200)
            viewLogoutDialouge.backgroundColor = UIColor.white
            viewLogoutDialouge.layoutIfNeeded() //This is important line
            viewLogoutDialouge.layer.cornerRadius = 5
            viewLogoutDialouge.layer.borderWidth = 1
            viewLogoutDialouge.layer.borderColor = UIColor.clear.cgColor
            ViewLogout.addSubview(viewLogoutDialouge)
            
            let lblSure = UILabel(frame: CGRect(x: 0, y: 40, width: viewLogoutDialouge.frame.size.width, height: 21))
           // lblSure.center = CGPoint(x: viewLogoutDialouge.frame.midX, y: viewLogoutDialouge.frame.midY)
            lblSure.textAlignment = .center
            lblSure.text = "Sure !"
            lblSure.font = UIFont(name: FONT_BOLD, size: 17)
            lblSure.textColor = UIColor(red: 49/255, green: 49/255, blue: 49/255, alpha: 1)
            viewLogoutDialouge.addSubview(lblSure)
            
            let lblDo = UILabel(frame: CGRect(x: 0, y: 70, width: viewLogoutDialouge.frame.size.width, height: 21))
            // lblSure.center = CGPoint(x: viewLogoutDialouge.frame.midX, y: viewLogoutDialouge.frame.midY)
            lblDo.textAlignment = .center
            lblDo.text = "Do you want to logout ?"
            lblDo.font = UIFont(name: FONT_REG, size: 16)
            lblDo.textColor = UIColor(red: 49/255, green: 49/255, blue: 49/255, alpha: 1)
            viewLogoutDialouge.addSubview(lblDo)
            
            let btnLogoutYes:UIButton = UIButton(frame:  CGRect(x: ((viewLogoutDialouge.frame.size.width / 2) -  110), y: 120, width: 90, height: 40))
            btnLogoutYes.backgroundColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1)
            btnLogoutYes.setTitleColor(UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1), for: .normal)
            btnLogoutYes.setTitle("YES", for: .normal)
            btnLogoutYes.titleLabel?.font =  UIFont(name: FONT_BOLD, size: 17)
            btnLogoutYes.addTarget(self, action: #selector(MenuController.onLogout(_:)), for:.touchUpInside)
            btnLogoutYes.layoutIfNeeded() //This is important line
            btnLogoutYes.layer.cornerRadius = 3
            btnLogoutYes.layer.borderWidth = 1
            btnLogoutYes.layer.borderColor = UIColor.clear.cgColor
            viewLogoutDialouge.addSubview(btnLogoutYes)
            
            let btnLogoutNo:UIButton = UIButton(frame:  CGRect(x: ((viewLogoutDialouge.frame.size.width / 2) +  20), y: 120, width: 90, height: 40))
            btnLogoutNo.backgroundColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1)
            btnLogoutNo.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1), for: .normal)
            btnLogoutNo.setTitle("NO", for: .normal)
            btnLogoutNo.titleLabel?.font =  UIFont(name: FONT_BOLD, size: 17)
            btnLogoutNo.addTarget(self, action: #selector(MenuController.onLogoutCancel(_:)), for:.touchUpInside)
            btnLogoutNo.layoutIfNeeded() //This is important line
            btnLogoutNo.layer.cornerRadius = 3
            btnLogoutNo.layer.borderWidth = 1
            btnLogoutNo.layer.borderColor = UIColor.clear.cgColor
            viewLogoutDialouge.addSubview(btnLogoutNo)
            
            ViewLogout.isHidden = false
            let viewControllerSize = UIScreen.main.bounds
            let width = viewControllerSize.width
            let height = viewControllerSize.height
            let rect = CGRect(
                origin: CGPoint(
                    x: width/2,
                    y: height/2),
                size: CGSize(
                    width: 0,
                    height: 0))
            
            viewLogoutDialouge.isHidden = true
            ViewLogout.drawAnimatedCircularMask(
                startFrame: rect,
                duration: 0.33,
                revealType: RevealType.reveal) { [weak self] in
                    viewLogoutDialouge.isHidden = false
                    viewLogoutDialouge.animation = "pop"
                    viewLogoutDialouge.curve = "easeIn"
                    viewLogoutDialouge.duration = 0.3
                    viewLogoutDialouge.repeatCount = 1
                    viewLogoutDialouge.animate()
                    
            }
            
        }
        else
        {
             self.performSegue(withIdentifier: segues[indexPath.row], sender: nil)
        }
    }
    
}
