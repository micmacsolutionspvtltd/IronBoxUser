//
//  HomeVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 22/03/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import SideMenu
import Alamofire
import NVActivityIndicatorView
import Toaster
import Foundation
import CircularRevealKit
import Spring
import ImageSlideshow
import FBSDKCoreKit
import SwiftUI
import SnapKit
import Cosmos

@available(iOS 13.0, *)
class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, ObservableObject, DelegateUpdateLocation{
    
    @IBOutlet weak var startingImgView: UIImageView!
    @IBOutlet weak var startingPopup: UIView!
    @IBOutlet weak var updateView: UIView!
    @IBOutlet weak var updateLbl: UILabel!
    @IBOutlet weak var notNowView: UIView!
    @IBOutlet weak var notNowLbl: UILabel!
    @IBOutlet weak var alertContentLbl: UILabel!
    @IBOutlet weak var alertTittleName: UILabel!
    @IBOutlet weak var backGroundBlurView: UIView!
    @IBOutlet weak var viewOnGoingServicesCount: SpringView!
    
    @IBOutlet weak var alertsView: UIView!
    @IBOutlet weak var btnOrder: UIButton!
    @IBOutlet weak var tableAddress: UITableView!
    @IBOutlet weak var dateCollectionView: UICollectionView!
    @IBOutlet weak var timeCollectionView: UICollectionView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblActiveOrders: UILabel!
    @IBOutlet weak var viewNewBooking: SpringView!
    @IBOutlet weak var viewOnGoing: SpringView!
    @IBOutlet weak var viewPackages: SpringView!
    @IBOutlet weak var viewOffers: SpringView!
    
    @IBOutlet weak var subscriptionsView: SpringView!
    @IBOutlet weak var viewBooking: UIView!
    @IBOutlet weak var viewBookingSuccess: UIView!
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var viewTime: UIView!
    @IBOutlet weak var viewAddress: UIView!
    @IBOutlet weak var viewAddressShow: UIView!
    @IBOutlet weak var viewClothes: UIView!
    @IBOutlet weak var lblDateInDate: UILabel!
    @IBOutlet weak var lblTimeInDate: UILabel!
    @IBOutlet weak var lblDateInTime: UILabel!
    @IBOutlet weak var lblTimeInTime: UILabel!
    @IBOutlet weak var lblDateInAddress: UILabel!
    @IBOutlet weak var lblTimeInAddress: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    
    @IBOutlet weak var btnDateNext: UIButton!
    @IBOutlet weak var btnTimeNext: UIButton!
    @IBOutlet weak var btnAddressNext: UIButton!
    @IBOutlet weak var btnAddressForUnderLine: UIButton!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnWork: UIButton!
    @IBOutlet weak var btnOthers: UIButton!
    
    @IBOutlet weak var lblClothesCount: UILabel!
    @IBOutlet weak var txtClothesCount: UITextField!
    @IBOutlet weak var txtPromoCode: UITextField!
    @IBOutlet weak var btnCash: UIButton!
    @IBOutlet weak var btnCard: UIButton!
    @IBOutlet weak var btnWallet: UIButton!
    @IBOutlet weak var btnOffers: UIButton!
    
    @IBOutlet weak var lblBSBookingID: UILabel!
    @IBOutlet weak var lblBSPaymentType: UILabel!
    @IBOutlet weak var lblBSBookedDate: UILabel!
    @IBOutlet weak var lblBSBookedTime: UILabel!
    @IBOutlet weak var lblBSQuantity: UILabel!
    @IBOutlet weak var ImgBSTick: SpringImageView!
    
    @IBOutlet weak var imgSlide: ImageSlideshow!
    
    var ViewTutorial = UIView()
    var ImgTutorial = UIImageView()
    var arrDate = Array<Any>()
    var arrleaveDate = Array<Any>()
    var arrTime = Array<Any>()
    var arrHomeAddress = Array<Any>()
    var arrWorkAddress = Array<Any>()
    var arrOtherAddress = Array<Any>()
    var arrAddress = Array<Any>()
    var  selectedDateIndex = Int()
    var  selectedTimeIndex = Int()
    var strBookingDate = ""
    var strAddressId = ""
    var strAddresspassId = ""
    @Published var strTimeSlot = ""
    var strTimeSlotID = ""
    var strPaymentType = ""
    var strQuantity = ""
    var nTutorialNumber = Int()
    var strPackageSubscribed = ""
    var frameLblClothesCount = CGRect()
    var frameTxtClothesCount = CGRect()
    var CurrentDate = ""
    var deliverytype = ""
    var moveToPackagePage = false
  var subscriptionMinimumOrderQuantity = ""
    var remainingPoints = ""
    var subscriptionBalanceLow = false
    
    let yourAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont(name: FONT_LIGHT, size: 14)!,
        NSAttributedStringKey.foregroundColor : UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0),
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
    
    var isShowLocationConfirmationAlert = false {
        didSet {
            showOrHideLocationConfirmationAlert()
        }
    }
    
    func didupdateLocation(isUpdated: Bool) {
//        isShowLocationConfirmationAlert = !isUpdated
    }
    
    lazy var locationConfirmationAlertView: UIView = {
        let v = LocationConfirmationAlertView(onTap: { [unowned self] in
            isShowLocationConfirmationAlert = false
            let addAddressVC = storyboard?.instantiateViewController(withIdentifier: "AddAddressVC") as! AddAddressVC
            addAddressVC.editAddressID = editAddressID
            addAddressVC.isForSpecialUpdate = true
            addAddressVC.delegateDidUpdateLocation = self
            self.navigationController?.present(addAddressVC, animated: true)
        } ).uiView()
        return v
    }()
    
    lazy var viewClothes2: UIView = {
        let v = ScheduleMyPickupScreen(data: self).uiView()
        return v
    }()
    let fieldCount = TextFieldCoordinator()
    let fieldPromoCode = TextFieldCoordinator()
    let fieldVoucherCode = TextFieldCoordinator()
    let fieldInstruction = TextFieldCoordinator()
    
    @Published var selectedAddressName = ""
    @Published var dSelectedDate = ""
    @Published var isCash = true {
        didSet {
            strPaymentType = isCash ? "Cash" : "Wallet"
        }
    }
    @Published var isNormalDeliveryType = true {
        didSet {
            deliverytype = isNormalDeliveryType ? "0" : "1"
        }
    }
    
    struct MLocationStatus: Codable {
        let error, errorMessage, checkAddress: String
        
        enum CodingKeys: String, CodingKey {
            case error
            case errorMessage = "error_message"
            case checkAddress = "CheckAddress"
            
        }
    }
    
    
//    private func scCheckLocationUpdate(completion: @escaping ((Bool) -> Void)) {
////        CheckAddress
//        guard CheckNetwork() else {
//            completion(false)
//            return
//        }
//        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
//        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
////        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
//
////        let defaultErrorMessage = "Something went wrong. please try again"
//        SessionManager.default.request("\(BASEURL)UserCheckOpt", method: .post, headers: header).responseJSON { res in
////            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            do {
//                if let dataObject = res.data {
//                    let model = try JSONDecoder().decode(MLocationStatus.self, from: dataObject)
//                    self.isShowLocationConfirmationAlert = model.checkAddress.lowercased() == "no"
//                }
//            } catch {
//                self.isShowLocationConfirmationAlert = true
//            }
//            completion(!self.isShowLocationConfirmationAlert)
//        }
//    }
    
//    private var cancellables = Set<Cancellable>()
    
    private func showOrHideLocationConfirmationAlert() {
        if !(navigationController!.view.subviews.contains(where: {$0 == locationConfirmationAlertView})) && isShowLocationConfirmationAlert == true {
            navigationController?.view.addSubview(locationConfirmationAlertView)
            locationConfirmationAlertView.snp.makeConstraints { c in
                c.edges.equalToSuperview()
            }
        } else if (navigationController!.view.subviews.contains(where: {$0 == locationConfirmationAlertView})) && isShowLocationConfirmationAlert == false {
            locationConfirmationAlertView.removeFromSuperview()
        }
    }
    
    //    enum PopupType: Int {
    //        case address
    //        case date
    //        case time
    //    }
    
    func showPopup(leftView: UIView?, rightView: UIView?, isMoveRight: Bool) {
        viewAddress.isHidden = true
        viewDate.isHidden = true
        viewTime.isHidden = true
        viewBooking.isHidden = true
        
        if leftView != nil || rightView != nil {
            viewBooking.isHidden = false
        }
        
        let viewWidth = view.frame.width
        if let leftView = leftView {
            if !isMoveRight {
                view.bringSubview(toFront: leftView)
            }
            leftView.layer.opacity = 1
            leftView.isHidden = false
            leftView.center.y = self.navigationController!.view.center.y - 20
            leftView.center.x = isMoveRight ? view.center.x : -viewWidth
            //            leftView.frame.origin.y = 0
            UIView.animate(withDuration: 0.4, animations: {
                leftView.center.x = isMoveRight ? -viewWidth : self.view.center.x
                if isMoveRight {
                    leftView.layer.opacity = 0
                }
                
            }) { _ in
                leftView.isHidden = isMoveRight
            }
        }
        
        if let rightView = rightView {
            if isMoveRight {
                view.bringSubview(toFront: rightView)
            }
            rightView.layer.opacity = 1
            rightView.isHidden = false
            rightView.center.y = self.navigationController!.view.center.y - 20
            rightView.center.x = isMoveRight ? viewWidth : view.center.x
            //            rightView.frame.origin.y = 0
            UIView.animate(withDuration: 0.4, animations: {
                rightView.center.x = isMoveRight ? self.view.center.x : viewWidth
                if !isMoveRight {
                    rightView.layer.opacity = 0
                }
            }) { _ in
                rightView.isHidden = !isMoveRight
            }
        }
    }
    
    @objc private func onBack() {
        showPopup(leftView: nil, rightView: nil, isMoveRight: true)
        setupNavigationBar(isDefault: true)
        fieldCount.setText("")
        fieldPromoCode.setText("")
        viewClothes2.isHidden = true
    }
    
    private func setupNavigationBar(isDefault: Bool) {
        if isDefault {
            self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor.white]
            
            let btnMenu = UIButton(type: .custom)
            btnMenu.setImage(UIImage(named: "Menu Icon"), for: .normal)
           
            btnMenu.imageView?.contentMode = .scaleAspectFit
            btnMenu.imageEdgeInsets = UIEdgeInsetsMake(8.0, 0.0, 8.0, 0.0)
            btnMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btnMenu.tintColor = .white
            navigationController?.navigationBar.barTintColor =  UIColor.primaryColor
            btnMenu.addTarget(self, action: #selector(self.onMenuClick), for: .touchUpInside)
            let item = UIBarButtonItem(customView: btnMenu)
            self.title = "Ironbox"
            self.navigationItem.setLeftBarButtonItems([item], animated: true)
        } else {
            self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor.white]
            
            let btnMenu = UIButton(type: .custom)
            btnMenu.setImage(UIImage(named: "BackButton"), for: .normal)
            btnMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btnMenu.tintColor = .white
            navigationController?.navigationBar.barTintColor =  UIColor.primaryColor
            btnMenu.addTarget(self, action: #selector(self.onBack), for: .touchUpInside)
            let item = UIBarButtonItem(customView: btnMenu)
            self.title = "Schedule My Pickup"
            self.navigationItem.setLeftBarButtonItems([item], animated: true)
        }
    }
    
    
    var editAddressID = ""
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fieldPromoCode.textField.text = appDelegate.strOfferCode
        navigationController?.navigationBar.isHidden = false
    }

    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startingPopup.isHidden = true
        fieldPromoCode.textField.placeholder = "Enter promo code"
        fieldVoucherCode.textField.placeholder = "Enter voucher code"
        fieldCount.textField.placeholder = ""
        viewClothes2.backgroundColor = .white
        viewClothes2.isHidden = true
        view.insertSubview(viewClothes2, belowSubview: viewBooking)
        
        viewClothes2.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        self.setFontFamilyAndSize()
        self.addDoneButtonOnKeyboard()
        
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuAllowPushOfSameClassTwice = true
        SideMenuManager.default.menuWidth = view.frame.width * 0.8
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuAnimationFadeStrength = 0.6
        
        deliverytype = "0"
        
        appDelegate.strOfferCode = ""
        nTutorialNumber = 1
        setupNavigationBar(isDefault: true)
        imgSlide.pageControlPosition = PageControlPosition.underScrollView
        imgSlide.pageControl.currentPageIndicatorTintColor = UIColor.white
        imgSlide.pageControl.pageIndicatorTintColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.250)
        imgSlide.contentScaleMode = UIViewContentMode.scaleAspectFill
        imgSlide.clipsToBounds = true
        imgSlide.circular = false
        imgSlide.slideshowInterval = 5
        imgSlide.activityIndicator = DefaultActivityIndicator(style: .white, color: UIColor.black)
        imgSlide.currentPageChanged = { page in
            print("current page:", page)
        }
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapImgSlide))
        imgSlide.addGestureRecognizer(recognizer)
        
        //    imgSlide.setImageInputs([ KingfisherSource(urlString: BANNER_URL_1)!, KingfisherSource(urlString: BANNER_URL_2)!, KingfisherSource(urlString: BANNER_URL_3)! , KingfisherSource(urlString: BANNER_URL_4)!])
        
        let attributeString1 = NSMutableAttributedString(string: "Add new address",
                                                         attributes: yourAttributes)
        btnAddressForUnderLine.setAttributedTitle(attributeString1, for: .normal)
        
        viewBooking.backgroundColor = UIColor(red: 18/255, green: 24/255, blue: 38/255, alpha: 0.5)
        viewBooking.isHidden = true
        viewBookingSuccess.isHidden = true
        appDelegate.isNewAddressAdded = false
        
        let Delivery = Notification.Name("DeliverySuccess")
        NotificationCenter.default.addObserver(self, selector: #selector(self.onHomeAPI), name: Delivery, object: nil)
        
        let strName = userDefaults.object(forKey: USER_NAME) as! String
        lblName.text = "Hello " + strName + "," + " Welcome to Ironbox."
        lblActiveOrders.isHidden = true
        viewNewBooking.isHidden = true
        viewOnGoing.isHidden = true
        viewPackages.isHidden = true
        viewOffers.isHidden = true
        
        tableAddress.backgroundColor = UIColor.white
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
        {
            self.viewNewBooking.isHidden = false
            self.viewNewBooking.animation = "zoomIn"
            self.viewNewBooking.curve = "easeIn"
            self.viewNewBooking.duration = 1
            self.viewNewBooking.repeatCount = 1
            self.viewNewBooking.animate()
            
            self.viewOnGoing.isHidden = false
            self.viewOnGoing.animation = "zoomIn"
            self.viewOnGoing.curve = "easeIn"
            self.viewOnGoing.duration = 1
            self.viewOnGoing.repeatCount = 1
            self.viewOnGoing.animate()
            
            
            self.viewPackages.isHidden = false
            self.viewPackages.animation = "zoomIn"
            self.viewPackages.curve = "easeIn"
            self.viewPackages.duration = 1
            self.viewPackages.repeatCount = 1
            self.viewPackages.animate()
            
            self.viewOffers.isHidden = true
            self.viewOffers.animation = "zoomIn"
            self.viewOffers.curve = "easeIn"
            self.viewOffers.duration = 1
            self.viewOffers.repeatCount = 1
            self.viewOffers.animate()
            
            self.subscriptionsView.isHidden = false
            self.subscriptionsView.animation = "zoomIn"
            self.subscriptionsView.curve = "easeIn"
            self.subscriptionsView.duration = 1
            self.subscriptionsView.repeatCount = 1
            self.subscriptionsView.animate()
            
            self.viewOnGoingServicesCount.isHidden = false
            self.viewOnGoingServicesCount.animation = "pop"
            self.viewOnGoingServicesCount.curve = "easeOutCric"
            self.viewOnGoingServicesCount.duration = 1
            self.viewOnGoingServicesCount.repeatCount = 1
            self.viewOnGoingServicesCount.animate()
            
        }
        
        frameLblClothesCount = lblClothesCount.frame
        frameTxtClothesCount = txtClothesCount.frame
        alertsView.isHidden=true
        backGroundBlurView.isHidden = true
        notNowView.isHidden = true
     
    }

    override func viewWillAppear(_ animated: Bool)
    {
        self.onHomeAPI()
        txtPromoCode.text = appDelegate.strOfferCode
        
        if (appDelegate.isNewAddressAdded)
        {
            self.onAddOrder(self)
        }
        
        if ((userDefaults.value(forKey: IS_HOME_TUTORIAL_SHOWN) as? String) == nil)
        {
            self.showTutorialScreen()
        }
        
        self.checkPendingPaytmResponse()
        showOrHideLocationConfirmationAlert()
        versionCheckvalue()
        versionUpdateApi()
    }
    override func viewWillLayoutSubviews()
    {
        
    }
    func versionUpdateApi(){
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        let strVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        
        let param: [String: Any] = ["":""]
        let url = "http://43.205.221.246/Ironbox_new/public/IroningVendor/versioncheck?id=6&version=\(strVersion ?? "")"
        self.CheckNetwork()
      
        AlamofireHC.newRequestPOST(url, params: (param  ) as [String : AnyObject], headers: header, success: { (JSON) in
            
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
               
                self.updateAlertPopup()
                
            }
        
            
            
        }, failure: { (error) in
            
            print(error)
            appDelegate.isNewAddressAdded = false
        })
    }
    func versionCheckvalue() -> Bool {
        VersionCheck.shared.checkAppStore() { isNew, version in
            print("IS NEW VERSION AVAILABLE: \(isNew), APP STORE VERSION: \(version)")
       
            if isNew == true {
                print("New Version is available")
            }
            else {

            }
        }
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TUTORIAL SCREEN
    func showTutorialScreen()
    {
        ViewTutorial.removeFromSuperview()
        nTutorialNumber = 1
        let screenSize: CGRect = UIScreen.main.bounds
        ViewTutorial = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        ViewTutorial.backgroundColor = UIColor(red: 18/255, green: 24/255, blue: 38/255, alpha: 0.852)
        self.navigationController?.view.addSubview(ViewTutorial)
        
        ImgTutorial  = UIImageView(frame:CGRect(x:0, y:0, width:screenSize.width, height:screenSize.height));
        if DeviceType.iPhoneX
        {
            ImgTutorial.image = UIImage(named:"TutoBooking1iPhX")
        }
        else
        {
            ImgTutorial.image = UIImage(named:"TutoBooking1")
        }
        
        ViewTutorial.addSubview(ImgTutorial)
        
        let btnNxt:UIButton = UIButton(type: .custom)
        if DeviceType.iPhoneX
        {
            btnNxt.frame = CGRect(x: screenSize.width - 110, y: screenSize.height - 80, width: 110, height: 50)
        }
        else
        {
            btnNxt.frame = CGRect(x: screenSize.width - 130, y: screenSize.height - 50, width: 130, height: 50)
        }
        btnNxt.backgroundColor = UIColor.clear
        btnNxt.addTarget(self, action: #selector(self.onTutorialNext(_:)), for:.touchUpInside)
        ViewTutorial.addSubview(btnNxt)
    }
    
    @IBAction func startPopupHideBtnAtn(_ sender: Any) {
        startingPopup.isHidden = true
    }
    @IBAction func onTutorialNext(_ sender: Any)
    {
        if nTutorialNumber == 1
        {
            if DeviceType.iPhoneX
            {
                ImgTutorial.image = UIImage(named:"TutoBooking2iPhX")
            }
            else
            {
                ImgTutorial.image = UIImage(named:"TutoBooking2")
            }
            nTutorialNumber = 2
        }
        else if nTutorialNumber == 2
        {
            if DeviceType.iPhoneX
            {
                ImgTutorial.image = UIImage(named:"TutoBooking3iPhX")
            }
            else
            {
                ImgTutorial.image = UIImage(named:"TutoBooking3")
            }
            nTutorialNumber = 3
        }
        else if nTutorialNumber == 3
        {
            if DeviceType.iPhoneX
            {
                ImgTutorial.image = UIImage(named:"TutoBooking4iPhX")
            }
            else
            {
                ImgTutorial.image = UIImage(named:"TutoBooking4")
            }
            nTutorialNumber = 4
        }
        else if nTutorialNumber == 4
        {
            if DeviceType.iPhoneX
            {
                ImgTutorial.image = UIImage(named:"TutoBooking5iPhX")
            }
            else
            {
                ImgTutorial.image = UIImage(named:"TutoBooking5")
            }
            nTutorialNumber = 5
        }
        else if nTutorialNumber == 5
        {
            userDefaults.set("yes", forKey: IS_HOME_TUTORIAL_SHOWN)
            ViewTutorial.removeFromSuperview()
            nTutorialNumber = 1
            
            self.viewNewBooking.isHidden = false
            self.viewNewBooking.animation = "zoomIn"
            self.viewNewBooking.curve = "easeIn"
            self.viewNewBooking.duration = 1
            self.viewNewBooking.repeatCount = 1
            self.viewNewBooking.animate()
            
            self.viewOnGoing.isHidden = false
            self.viewOnGoing.animation = "zoomIn"
            self.viewOnGoing.curve = "easeIn"
            self.viewOnGoing.duration = 1
            self.viewOnGoing.repeatCount = 1
            self.viewOnGoing.animate()
            
            self.viewPackages.isHidden = false
            self.viewPackages.animation = "zoomIn"
            self.viewPackages.curve = "easeIn"
            self.viewPackages.duration = 1
            self.viewPackages.repeatCount = 1
            self.viewPackages.animate()
            
            self.viewOffers.isHidden = true
            self.viewOffers.animation = "zoomIn"
            self.viewOffers.curve = "easeIn"
            self.viewOffers.duration = 1
            self.viewOffers.repeatCount = 1
            self.viewOffers.animate()
            
            self.viewOnGoingServicesCount.isHidden = false
            self.viewOnGoingServicesCount.animation = "pop"
            self.viewOnGoingServicesCount.curve = "easeOutCric"
            self.viewOnGoingServicesCount.duration = 1
            self.viewOnGoingServicesCount.repeatCount = 1
            self.viewOnGoingServicesCount.animate()
            
        }
    }
    // MARK: - POUP ACTIONS
    
    @IBAction func notNowAtn(_ sender: Any) {
        backGroundBlurView.isHidden = true
        alertsView.isHidden = true
    }
    
    @IBAction func updateAtn(_ sender: Any) {
        if updateLbl.text == "Confirm"{
            oneClickBooking()
        }else{
            if let url = URL(string: "https://apps.apple.com/in/app/ironbox/id1396394518") {
                UIApplication.shared.open(url)
            }
        }
       
        backGroundBlurView.isHidden = true
        alertsView.isHidden = true
    }
    // MARK: - ACTIONS
    
    @objc func onMenuClick()
    {
        self.performSegue(withIdentifier: "Home_Menu", sender: self)
    }
    
    @objc func onHomeAPI()
    {
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        let strVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        
        let param: [String: Any] = [
            "version":strVersion!,
            "app_os":"ios"
        ]
        
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(HOME_API, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                if let addressID = json["user_home_address_id"] as? Int {
                    self.editAddressID = "\(addressID)"
//                    self.isShowLocationConfirmationAlert = ((json["is_address_updated"] as? String ?? "") != "1")
                }
                let refAmount = json["referral_amount"] as? Int ?? 0
                let strRefAmount = String(describing: refAmount)
                userDefaults.set(strRefAmount, forKey: REFERRAL_AMOUNT)
                
                let Amount = json["amount"] as? Int ?? 0
                let strAmount = String(describing: Amount)
                userDefaults.set(strAmount, forKey: AMOUNT)
                
                //  let User = json["users"] as? Int ?? 0
                let User = 1
                let strUser = String(describing: User)
                userDefaults.set(strUser, forKey: USER)
//
//                print("amount,user",Amount,User)
                
                let arrImageSlide = json.value(forKey: "response") as! Array<Any>
                var inputs = [KingfisherSource]()
                for var i in 0..<arrImageSlide.count
                {
                    let dict = arrImageSlide[i] as! Dictionary<String,Any>
                    var strImage = dict["images"] as! String
                    strImage = strImage.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                    let input = KingfisherSource(urlString: strImage, placeholder: nil, options:nil)
                    inputs.append(input!)
                }
                
                self.imgSlide.setImageInputs(inputs)
                let strName = json["Username"] as? String ?? ""
                userDefaults.set(strName, forKey: USER_NAME)
                let setNameInMenu = Notification.Name("SETIMAGEANDNAME")
                NotificationCenter.default.post(name: setNameInMenu, object: nil)
                
                self.lblName.text = "Hello " + strName + "," + " Welcome to Ironbox."
                self.lblActiveOrders.isHidden = false
                let nActiveOrder = json.value(forKey: "service_count")
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .spellOut
                let strActiveOrder = numberFormatter.string(from: nActiveOrder as! NSNumber)
                self.lblActiveOrders.text = "You have " + strActiveOrder!.capitalized + "(\(nActiveOrder!))" + " active order(s)."
                
                let version = json.value(forKey: "version")
                let strversion = String(describing: version!)
                
                let rating = json.value(forKey: "rating")
                let strRating = String(describing: rating!)
                let remainingPoint = json.value(forKey: "remaining_points")
                
                self.remainingPoints = String(describing: remainingPoint ?? "")
                let subscribers = json.value(forKey: "subscribers")
                let startingPopupImg = json.value(forKey: "home_img")
                if UserDefaults.standard.value(forKey: "enterFirstTime") as! String == "true"{
                    if startingPopupImg as! String != ""{
                        self.startingPopup.isHidden = false
                        var strImageURL = String(describing: startingPopupImg)
                        strImageURL = strImageURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                        self.startingImgView.imageFromServerURL(urlString: startingPopupImg as! String)
                    }
                   
                }
                UserDefaults.standard.set("false", forKey: "enterFirstTime")
                if let subscribeValues = subscribers as? Dictionary<String,Any>{
                    if let minorderQty = Int(subscribeValues["minimum_order_quantity"] as? String ?? ""){
                        if (Int(self.remainingPoints) ?? 0 < Int(minorderQty)){
                            self.subscriptionMinimumOrderQuantity = String(minorderQty)
                            self.btnCash.isHidden = false
                            self.btnWallet.isHidden = false
                            self.subscriptionBalanceLow = true
                        }else{
                            self.subscriptionMinimumOrderQuantity = String(minorderQty)
                            self.btnCash.isHidden = true
                            self.btnWallet.isHidden = true
                            self.strPaymentType = "Subscribtion"
                            self.subscriptionBalanceLow = false
                        }
                        self.moveToPackagePage = false
                    }else{
                        self.moveToPackagePage = true
                        self.subscriptionBalanceLow = true
                    }
                    print("allValues" , subscribeValues["minimum_order_quantity"])
                  
                }else{
                    self.moveToPackagePage = true
                    self.subscriptionBalanceLow = true
                }
            
                
                //                if strversion == "1"
                //                {
                //                    appDelegate.strUpdateMsg = json["update_message"] as? String ?? ""
                //                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppUpdateVC") as! AppUpdateVC
                //                    self.present(vc, animated: true, completion: nil)
                //
                //                }
                //                else if strRating == "1"
                //                {
                //                    appDelegate.dictServiceSuccess = json.value(forKey: "Booking") as! Dictionary<String,Any>
                //                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServiceSuccessfullVC") as! ServiceSuccessfullVC
                //                    self.present(vc, animated: true, completion: nil)
                //
                //                }
                
            }
            else if (err == "Unauthenticated.")
            {
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
            }
            else
            {
                //                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                //                self.ShowAlert(msg: errorMessage)
            }
            
            
        }, failure: { (error) in
            
            print(error)
            appDelegate.isNewAddressAdded = false
        })
        
    }
    
    @IBAction func onGoingServices(_ sender: Any)
    {
        self.performSegue(withIdentifier: "Home_OnGoingServices", sender: self)
    }
    
    @objc func didTapImgSlide()
    {
        
    }
    
    @IBAction func onPackages(_ sender: Any)
    {
        //self.performSegue(withIdentifier: "Home_Package", sender: self)
        if moveToPackagePage{
            oneClickBooking()
        }else{
           packagesAlert()
        }
       
    }
    fileprivate func updateAlertPopup(){
        alertsView.isHidden = false
        backGroundBlurView.isHidden = false
        notNowView.isHidden = true
        updateLbl.text = "Update"
        alertTittleName.text = "Version Update"
        alertContentLbl.text = "Here's an Update for you with new Version Click to grab the updated feautures"
    }
    fileprivate func packagesAlert(){
        alertsView.isHidden = false
        backGroundBlurView.isHidden = false
        notNowView.isHidden = false
        notNowLbl.text = "Cancel"
        updateLbl.text = "Confirm"
        alertTittleName.text = "One Click Booking"
        alertContentLbl.text = "Minimum order quantity for subscriber is \(subscriptionMinimumOrderQuantity)"
    }
    @IBAction func subscriptionAtn(_ sender: Any) {
//
        if (moveToPackagePage && subscriptionBalanceLow) || (moveToPackagePage == false && subscriptionBalanceLow){
            let packageVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPackageViewController") as! AddPackageViewController
            packageVC.buyBtnShow = subscriptionBalanceLow
                  navigationController?.pushViewController(packageVC, animated: true)
        }else{
            let subscriptionVc = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionDetailController") as! SubscriptionDetailController
            subscriptionVc.buyBtnShow = subscriptionBalanceLow
            navigationController?.pushViewController(subscriptionVc, animated: true)
        }
      
       // self.performSegue(withIdentifier: "addPackage", sender: self)
    }
    @IBAction func onMainOffers(_ sender: Any)
    {
        self.performSegue(withIdentifier: "Home_Offers", sender: self)
    }
    
    // MARK: - NEW ORDER
    @IBAction func onAddOrder(_ sender: Any)
    {
        
//        scCheckLocationUpdate { isAllow in
//            if isAllow {
                self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
                
                let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
                let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
                
                self.CheckNetwork()
                
                AlamofireHC.requestPOST(GET_ADDRESS, params: nil, headers: header, success: { (JSON) in
                    UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
                    let  result = JSON.dictionaryObject
                    let json = result! as NSDictionary
                    
                    let err = json.value(forKey: "error") as? String ?? ""
                    if (err == "false")
                    {
                        self.arrDate.removeAll()
                        self.arrTime.removeAll()
                        self.arrleaveDate.removeAll()
                        
                        
                        self.arrTime = json.value(forKey: "Slots") as? Array ?? []
                        self.arrHomeAddress = json.value(forKey: "Home") as? Array ?? []
                        self.arrWorkAddress = json.value(forKey: "Work") as? Array ?? []
                        self.arrOtherAddress = json.value(forKey: "Other") as? Array ?? []
                        self.arrDate = json.value(forKey: "order_date") as? Array ?? []
                        self.arrleaveDate = json.value(forKey: "leave_dates") as? Array ?? []
                        
                        
                        if(appDelegate.isNewAddressAdded)
                        {
                            if self.arrHomeAddress.count != 0
                            {
                                self.onHome(self)
                            }
                            else if self.arrWorkAddress.count != 0
                            {
                                self.onWork(self)
                            }
                            else if self.arrOtherAddress.count != 0
                            {
                                self.onOthers(self)
                            }
                            
                            appDelegate.isNewAddressAdded = false
                        }
                        else
                        {
                            self.startBookingProcess()
                            
                            appDelegate.isNewAddressAdded = false
                            
                            
                            
                        }
                    }
                    else
                    {
                        let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                        self.ShowAlert(msg: errorMessage)
                        appDelegate.isNewAddressAdded = false
                    }
                    
                    
                }, failure: { (error) in
                    UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
                    print(error)
                    appDelegate.isNewAddressAdded = false
                })
//            }
//        }
    }
    
    func startBookingProcess()
    {
        /*   arrDate.removeAllObjects()
         let currDate = Date()
         for i in 0...22
         {
         let interval = TimeInterval(60 * 60 * 24 * i)
         let newDate = currDate.addingTimeInterval(interval)
         
         let weekday = Calendar.current.component(.weekday, from: newDate)
         if weekday != 1
         {
         arrDate.add(newDate)
         }
         
         }
         
         let calendar = Calendar.current
         let now = Date()
         
         let four_fifty_nine_today = calendar.date(
         bySettingHour: 16,
         minute: 59,
         second: 59,
         of: now)!
         
         if now > four_fifty_nine_today
         {
         arrDate.removeAllObjects()
         for i in 1...22
         {
         let interval = TimeInterval(60 * 60 * 24 * i)
         let newDate = currDate.addingTimeInterval(interval)
         let weekday = Calendar.current.component(.weekday, from: newDate)
         if weekday != 1
         {
         arrDate.add(newDate)
         }
         
         
         }
         
         } */
        
        //call ServerTimeReturn function
        serverTimeReturn { (getResDate) -> Void in
            let dFormatter = DateFormatter()
            dFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            self.CurrentDate = dFormatter.string(from: getResDate! as Date)
            //            print("Formatted Time : \(self.CurrentDate)")
        }
        
        strBookingDate = ""
        strAddressId = ""
        strAddresspassId = ""
        strTimeSlot = ""
        strQuantity = ""
        fieldCount.setText("")
        strPaymentType = "Cash"
        strTimeSlotID = ""
        lblYear.text = ""
        lblDateInDate.text = ""
        lblDateInTime.text = ""
        lblTimeInDate.text = ""
        lblTimeInTime.text = ""
        lblDateInAddress.text = ""
        lblTimeInAddress.text = ""
        txtClothesCount.text = ""
        selectedDateIndex = -1
        selectedTimeIndex = -1
        appDelegate.strOfferCode = ""
        txtPromoCode.text = ""
        
        btnDateNext.isUserInteractionEnabled = false
        btnDateNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2), for: .normal)
        btnTimeNext.isUserInteractionEnabled = false
        btnTimeNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2), for: .normal)
        btnAddressNext.isUserInteractionEnabled = false
        btnAddressNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2), for: .normal)
        
        if arrDate.count != 0
        {
            let strDate = self.arrDate[0] as? String ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            //   dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            let date = dateFormatter.date(from: strDate)!
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            let strYear = formatter.string(from: date as Date)
            lblYear.text = strYear
            
            dateCollectionView.delegate = self
            dateCollectionView.dataSource = self
            dateCollectionView.reloadData()
            
        }
        
        
        if arrTime.count != 0
        {
            timeCollectionView.delegate = self
            timeCollectionView.dataSource = self
            timeCollectionView.reloadData()
        }
        
        viewAddressShow.isHidden = true
        viewAddressShow.backgroundColor = (UIColor.white .withAlphaComponent(1))
        btnHome.backgroundColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1.0) // light blue
        btnHome.setTitleColor(UIColor.white, for: .normal)
        btnHome.layer.borderWidth = 0
        btnHome.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnHome.layer.masksToBounds = false
        btnHome.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnHome.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnHome.layer.shadowOpacity = 0
        btnHome.layer.cornerRadius = 4
        btnHome.clipsToBounds = true
        
        btnWork.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnWork.backgroundColor = UIColor.white
        btnWork.layer.borderWidth = 1
        btnWork.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWork.layer.masksToBounds = false
        btnWork.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWork.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnWork.layer.shadowOpacity = 0.2
        btnWork.layer.cornerRadius = 4
        btnWork.clipsToBounds = true
        
        btnOthers.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnOthers.backgroundColor = UIColor.white
        btnOthers.layer.borderWidth = 1
        btnOthers.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnOthers.layer.masksToBounds = false
        btnOthers.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnOthers.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnOthers.layer.shadowOpacity = 0.2
        btnOthers.layer.cornerRadius = 4
        btnOthers.clipsToBounds = true
        tableAddress.isHidden = true
        tableAddress.backgroundColor = UIColor.white
        
        
        if arrHomeAddress.count != 0
        {
            self.onHome(self)
        }
        else if arrWorkAddress.count != 0
        {
            self.onWork(self)
        }
        else if arrOtherAddress.count != 0
        {
            self.onOthers(self)
        }
        
        self.addBottomLineToTextField(textField: txtPromoCode, color: "")
        btnCash.backgroundColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1.0) // light blue
        btnCash.setTitleColor(UIColor.white, for: .normal)
        btnCash.layer.borderWidth = 0
        btnCash.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCash.layer.masksToBounds = false
        btnCash.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCash.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnCash.layer.shadowOpacity = 0
        btnCash.layer.cornerRadius = 4
        btnCash.clipsToBounds = true
        
        btnCard.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnCard.backgroundColor = UIColor.white
        btnCard.layer.borderWidth = 1
        btnCard.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCard.layer.masksToBounds = false
        btnCard.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCard.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnCard.layer.shadowOpacity = 0.2
        btnCard.layer.cornerRadius = 4
        btnCard.clipsToBounds = true
        
        btnWallet.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnWallet.backgroundColor = UIColor.white
        btnWallet.layer.borderWidth = 1
        btnWallet.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWallet.layer.masksToBounds = false
        btnWallet.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWallet.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnWallet.layer.shadowOpacity = 0.2
        btnWallet.layer.cornerRadius = 4
        btnWallet.clipsToBounds = true
        
        [viewAddress, viewDate, viewTime].forEach { each in
            each?.roundCorners(.allCorners, radius: 10)
        }
//        viewDate.roundCorners([.topLeft, .topRight], radius: 15)
//        viewTime.roundCorners([.topLeft, .topRight], radius: 15)
//        viewAddress.roundCorners([.topLeft, .topRight], radius: 15)
        viewClothes.roundCorners([.topLeft, .topRight], radius: 15)
        viewTime.frame.origin.x += self.view.frame.size.width
        viewDate.frame.origin.x += self.view.frame.size.width
        viewClothes.frame.origin.x += self.view.frame.size.width
        viewTime.isHidden = true
        viewDate.isHidden = true
        viewClothes.isHidden = true
        
        //        viewAddress.frame.origin.y += (self.view.frame.size.height/2)
        //        viewAddress.isHidden = false
        //        viewBooking.isHidden = false
        //        UIView.animate(withDuration: 0.4, animations: {
        //            self.viewAddress.frame.origin.y -= (self.view.frame.size.height/2)
        //        }, completion: nil)
        showPopup(leftView: nil, rightView: viewAddress, isMoveRight: true)
        setupNavigationBar(isDefault: false)
        viewClothes2.isHidden = false
    }
    
    @IBAction func Prevfrmdate(_ sender: Any)
    {
        showPopup(leftView: viewAddress, rightView: viewDate, isMoveRight: false)
//        self.viewAddress.isHidden = false
//        UIView.animate(withDuration: 0.4, animations: {
//            self.viewAddress.frame.origin.x += self.view.frame.size.width
//            self.viewDate.frame.origin.x += self.view.frame.size.width
//        }, completion: {
//            (value: Bool) in
//            self.viewDate.isHidden = true
//
//        })
    }
    
    @IBAction func onClose(_ sender: Any)
    {
        view.endEditing(true)
        UIView.animate(withDuration: 0.4, animations: {
            self.viewDate.frame.origin.y += (self.view.frame.size.height/10) * 6
            self.viewTime.frame.origin.y += (self.view.frame.size.height/10) * 6
            self.viewAddress.frame.origin.y += (self.view.frame.size.height/10) * 6
            self.viewClothes.frame.origin.y += (self.view.frame.size.height/10) * 6
        }, completion: { [weak self] _ in
            self?.showPopup(leftView: nil, rightView: nil, isMoveRight: true)
//            self.viewBooking.isHidden = true
//            self.viewDate.frame.origin.y -= (self.view.frame.size.height/10) * 6
//            self.viewTime.frame.origin.y -= (self.view.frame.size.height/10) * 6
//            self.viewAddress.frame.origin.y -= (self.view.frame.size.height/10) * 6
//            self.viewClothes.frame.origin.y -= (self.view.frame.size.height/10) * 6
//
//            self.viewDate.frame.origin.x = self.viewBooking.frame.origin.x
//            self.viewTime.frame.origin.x = self.viewBooking.frame.origin.x
//            self.viewAddress.frame.origin.x = self.viewBooking.frame.origin.x
//            self.viewClothes.frame.origin.x = self.viewBooking.frame.origin.x
        })
    }
    
    @IBAction func onDateNext(_ sender: Any)
    {
        selectedTimeIndex = -1
        lblTimeInTime.text = ""
        lblTimeInDate.text = ""
        lblTimeInAddress.text = ""
        btnTimeNext.isUserInteractionEnabled = false
        btnTimeNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2), for: .normal)
        
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        let param: [String: Any] = [
            "order_date":strBookingDate,
            "pin_id":strAddresspassId
        ]
        print("values:", strBookingDate,strAddresspassId)
        
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(GET_TIMESLOTS, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                
                let nPackage = json.value(forKey: "Is_package") as? Int ?? 0
                self.strPackageSubscribed = String(describing: nPackage)
                self.onHandlePackages()
                
                self.arrTime = json.value(forKey: "time_slot") as! Array<Any>
                
                if self.arrTime.count != 0
                {
                    self.timeCollectionView.reloadData()
                    
                    //                    self.viewTime.isHidden = false
                    //                    UIView.animate(withDuration: 0.4, animations: {
                    //                        self.viewDate.frame.origin.x -= self.view.frame.size.width
                    //                        self.viewTime.frame.origin.x -= self.view.frame.size.width
                    //                    }, completion: {
                    //                        (value: Bool) in
                    //                        self.viewDate.isHidden = true
                    //                    })
                    self.showPopup(leftView: self.viewDate, rightView: self.viewTime, isMoveRight: true)
                }
                else
                {
                    let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                    self.ShowAlert(msg: errorMessage)
                }
                
            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
                
            }
            
            
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
            
        })
        
    }
    
    @IBAction func onTimePrevious(_ sender: Any)
    {
        showPopup(leftView: viewDate, rightView: viewTime, isMoveRight: false)
        //        self.viewDate.isHidden = false
        //        UIView.animate(withDuration: 0.4, animations: {
        //            self.viewDate.frame.origin.x += self.view.frame.size.width
        //            self.viewTime.frame.origin.x += self.view.frame.size.width
        //        }, completion: {
        //            (value: Bool) in
        //            self.viewTime.isHidden = true
        //
        //        })
    }
    
    @IBAction func onTimeNext(_ sender: Any)
    {
        onClose(sender)
//        self.viewBooking.isHidden = true
//        UIView.animate(withDuration: 0.4, animations: {
//            self.viewTime.frame.origin.x -= self.view.frame.size.width
//            //            self.viewClothes2.frame.origin.x -= self.view.frame.size.width
//        }, completion: {
//            (value: Bool) in
//            self.viewTime.isHidden = true
//
//        })
    }
    
    @IBAction func onAddressPrevious(_ sender: Any)
    {
        onClose(sender)
        return
//        selectedTimeIndex = -1
//        lblTimeInTime.text = ""
//        lblTimeInDate.text = ""
//        lblTimeInAddress.text = ""
//        btnTimeNext.isUserInteractionEnabled = false
//        btnTimeNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2), for: .normal)
//
//        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
//
//        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
//        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
//
//        let param: [String: Any] = [
//            "order_date":strBookingDate
//        ]
//
//        self.CheckNetwork()
//
//        AlamofireHC.requestPOST(GET_TIMESLOTS, params: param as [String : AnyObject], headers: header, success: { (JSON) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            let  result = JSON.dictionaryObject
//            let json = result! as NSDictionary
//
//            let err = json.value(forKey: "error") as? String ?? ""
//            if (err == "false")
//            {
//                let nPackage = json.value(forKey: "Is_package") as? Int ?? 0
//                self.strPackageSubscribed = String(describing: nPackage)
//                self.onHandlePackages()
//
//                self.arrTime = json.value(forKey: "time_slot") as! Array<Any>
//
//                if self.arrTime.count != 0
//                {
//                    self.timeCollectionView.reloadData()
//
//                    self.viewTime.isHidden = false
//                    UIView.animate(withDuration: 0.4, animations: {
//                        self.viewTime.frame.origin.x += self.view.frame.size.width
//                        self.viewAddress.frame.origin.x += self.view.frame.size.width
//                    }, completion: {
//                        (value: Bool) in
//                        self.viewAddress.isHidden = true
//                    })
//
//                }
//                else
//                {
//                    let errorMessage = json.value(forKey: "error_message")as? String ?? ""
//                    self.ShowAlert(msg: errorMessage)
//                }
//
//            }
//            else
//            {
//                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
//                self.ShowAlert(msg: errorMessage)
//
//            }
//
//
//        }, failure: { (error) in
//            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
//            print(error)
//
//        })
        
    }
    
    @IBAction func onAddressNext(_ sender: Any)
    {
        showPopup(leftView: viewAddress, rightView: viewDate, isMoveRight: true)
        //        viewDate.isHidden = false
        //        viewBooking.isHidden = false
        //        UIView.animate(withDuration: 0.4, animations: {
        //            self.viewAddress.frame.origin.x = -self.view.frame.size.width// self.view.frame.size.width
        //            self.viewDate.frame.origin.x = 0
        //        }, completion: {
        //            (value: Bool) in
        //            self.viewAddress.isHidden = true
        //        })
    }
    
    @IBAction func onClothesPrevious(_ sender: Any)
    {
        view.endEditing(true)
        self.viewTime.isHidden = false
        UIView.animate(withDuration: 0.4, animations: {
            self.viewTime.frame.origin.x += self.view.frame.size.width
            //            self.viewClothes2.frame.origin.x += self.view.frame.size.width
        }, completion: {
            (value: Bool) in
            //            self.viewClothes2.isHidden = true
        })
    }
    
    
    @IBAction func onAddAddress(_ sender: Any)
    {
        
    }
    
    @IBAction func onHome(_ sender: Any)
    {
        btnHome.backgroundColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1.0) // light blue
        btnHome.setTitleColor(UIColor.white, for: .normal)
        btnHome.layer.borderWidth = 0
        btnHome.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnHome.layer.masksToBounds = false
        btnHome.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnHome.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnHome.layer.shadowOpacity = 0
        btnHome.layer.cornerRadius = 4
        btnHome.clipsToBounds = true
        
        btnWork.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnWork.backgroundColor = UIColor.white
        btnWork.layer.borderWidth = 1
        btnWork.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWork.layer.masksToBounds = false
        btnWork.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWork.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnWork.layer.shadowOpacity = 0.2
        btnWork.layer.cornerRadius = 4
        btnWork.clipsToBounds = true
        
        btnOthers.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnOthers.backgroundColor = UIColor.white
        btnOthers.layer.borderWidth = 1
        btnOthers.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnOthers.layer.masksToBounds = false
        btnOthers.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnOthers.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnOthers.layer.shadowOpacity = 0.2
        btnOthers.layer.cornerRadius = 4
        btnOthers.clipsToBounds = true
        
        if arrHomeAddress.count != 0
        {
            viewAddressShow.isHidden = false
            arrAddress = arrHomeAddress
            tableAddress.isHidden = false
            tableAddress.delegate = self
            tableAddress.dataSource = self
            tableAddress.reloadData()
            
            let dictAddress = self.arrAddress[0] as! Dictionary<String, Any>
            let addressId = dictAddress["id"]
            strAddressId = String(describing: addressId!)
            
            let addresspassId = dictAddress["serviceAreaId"]
            strAddresspassId = String(describing: addresspassId!)
            
            let address = dictAddress["address"]
            selectedAddressName = address as? String ?? ""
            
            btnAddressNext.isUserInteractionEnabled = true
            btnAddressNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), for: .normal)
            
        }
        else
        {
            tableAddress.isHidden = true
            strAddressId = ""
            strAddresspassId = ""
            btnAddressNext.isUserInteractionEnabled = false
            btnAddressNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2), for: .normal)
        }
    }
    
    @IBAction func onWork(_ sender: Any)
    {
        btnWork.backgroundColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1.0) // light blue
        btnWork.setTitleColor(UIColor.white, for: .normal)
        btnWork.layer.borderWidth = 0
        btnWork.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWork.layer.masksToBounds = false
        btnWork.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWork.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnWork.layer.shadowOpacity = 0
        btnWork.layer.cornerRadius = 4
        btnWork.clipsToBounds = true
        
        
        btnHome.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnHome.backgroundColor = UIColor.white
        btnHome.layer.borderWidth = 1
        btnHome.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnHome.layer.masksToBounds = false
        btnHome.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnHome.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnHome.layer.shadowOpacity = 0.2
        btnHome.layer.cornerRadius = 4
        btnHome.clipsToBounds = true
        
        btnOthers.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnOthers.backgroundColor = UIColor.white
        btnOthers.layer.borderWidth = 1
        btnOthers.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnOthers.layer.masksToBounds = false
        btnOthers.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnOthers.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnOthers.layer.shadowOpacity = 0.2
        btnOthers.layer.cornerRadius = 4
        btnOthers.clipsToBounds = true
        
        if arrWorkAddress.count != 0
        {
            viewAddressShow.isHidden = false
            arrAddress = arrWorkAddress
            tableAddress.isHidden = false
            tableAddress.delegate = self
            tableAddress.dataSource = self
            tableAddress.reloadData()
            
            let dictAddress = self.arrAddress[0] as! Dictionary<String, Any>
            let addressId = dictAddress["id"]
            strAddressId = String(describing: addressId!)
            
            let addresspassId = dictAddress["serviceAreaId"]
            strAddresspassId = String(describing: addresspassId!)
            
            let address = dictAddress["address"]
            selectedAddressName = address as? String ?? ""
            
            btnAddressNext.isUserInteractionEnabled = true
            btnAddressNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), for: .normal)
        }
        else
        {
            tableAddress.isHidden = true
            strAddressId = ""
            strAddresspassId = ""
            btnAddressNext.isUserInteractionEnabled = false
            btnAddressNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2), for: .normal)
        }
    }
    @IBAction func onOthers(_ sender: Any)
    {
        btnOthers.backgroundColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1.0) // light blue
        btnOthers.setTitleColor(UIColor.white, for: .normal)
        btnOthers.layer.borderWidth = 0
        btnOthers.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnOthers.layer.masksToBounds = false
        btnOthers.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnOthers.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnOthers.layer.shadowOpacity = 0
        btnOthers.layer.cornerRadius = 4
        btnOthers.clipsToBounds = true
        
        btnWork.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnWork.backgroundColor = UIColor.white
        btnWork.layer.borderWidth = 1
        btnWork.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWork.layer.masksToBounds = false
        btnWork.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWork.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnWork.layer.shadowOpacity = 0.2
        btnWork.layer.cornerRadius = 4
        btnWork.clipsToBounds = true
        
        btnHome.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnHome.backgroundColor = UIColor.white
        btnHome.layer.borderWidth = 1
        btnHome.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnHome.layer.masksToBounds = false
        btnHome.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnHome.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnHome.layer.shadowOpacity = 0.2
        btnHome.layer.cornerRadius = 4
        btnHome.clipsToBounds = true
        
        if arrOtherAddress.count != 0
        {
            arrAddress = arrOtherAddress
            let dictAddress = self.arrAddress[0] as! Dictionary<String, Any>
            let addressId = dictAddress["id"]
            strAddressId = String(describing: addressId!)
            let addresspassId = dictAddress["serviceAreaId"]
            strAddresspassId = String(describing: addresspassId!)
            let address = dictAddress["address"]
            selectedAddressName = address as? String ?? ""
            
            viewAddressShow.isHidden = false
            tableAddress.isHidden = false
            tableAddress.delegate = self
            tableAddress.dataSource = self
            tableAddress.reloadData()
            
            btnAddressNext.isUserInteractionEnabled = true
            btnAddressNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), for: .normal)
            
        }
        else
        {
            tableAddress.isHidden = true
            strAddressId = ""
            strAddresspassId = ""
            btnAddressNext.isUserInteractionEnabled = false
            btnAddressNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2), for: .normal)
        }
    }
    
    @IBAction func onCash(_ sender: Any)
    {
        strPaymentType = "Cash"
        
        btnCash.backgroundColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1.0) // light blue
        btnCash.setTitleColor(UIColor.white, for: .normal)
        btnCash.layer.borderWidth = 0
        btnCash.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCash.layer.masksToBounds = false
        btnCash.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCash.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnCash.layer.shadowOpacity = 0
        btnCash.layer.cornerRadius = 4
        btnCash.clipsToBounds = true
        
        btnCard.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnCard.backgroundColor = UIColor.white
        btnCard.layer.borderWidth = 1
        btnCard.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCard.layer.masksToBounds = false
        btnCard.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCard.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnCard.layer.shadowOpacity = 0.2
        btnCard.layer.cornerRadius = 4
        btnCard.clipsToBounds = true
        
        btnWallet.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnWallet.backgroundColor = UIColor.white
        btnWallet.layer.borderWidth = 1
        btnWallet.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWallet.layer.masksToBounds = false
        btnWallet.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWallet.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnWallet.layer.shadowOpacity = 0.2
        btnWallet.layer.cornerRadius = 4
        btnWallet.clipsToBounds = true
        
        
    }
    
    @IBAction func onCard(_ sender: Any)
    {
        strPaymentType = "Card"
        
        btnCard.backgroundColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1.0) // light blue
        btnCard.setTitleColor(UIColor.white, for: .normal)
        btnCard.layer.borderWidth = 0
        btnCard.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCard.layer.masksToBounds = false
        btnCard.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCard.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnCard.layer.shadowOpacity = 0
        btnCard.layer.cornerRadius = 4
        btnCard.clipsToBounds = true
        
        
        btnCash.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnCash.backgroundColor = UIColor.white
        btnCash.layer.borderWidth = 1
        btnCash.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCash.layer.masksToBounds = false
        btnCash.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCash.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnCash.layer.shadowOpacity = 0.2
        btnCash.layer.cornerRadius = 4
        btnCash.clipsToBounds = true
        
        btnWallet.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnWallet.backgroundColor = UIColor.white
        btnWallet.layer.borderWidth = 1
        btnWallet.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWallet.layer.masksToBounds = false
        btnWallet.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWallet.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnWallet.layer.shadowOpacity = 0.2
        btnWallet.layer.cornerRadius = 4
        btnWallet.clipsToBounds = true
        
        
    }
    
    @IBAction func onWallet(_ sender: Any)
    {
        strPaymentType = "Wallet"
        
        btnWallet.backgroundColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1.0) // light blue
        btnWallet.setTitleColor(UIColor.white, for: .normal)
        btnWallet.layer.borderWidth = 0
        btnWallet.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWallet.layer.masksToBounds = false
        btnWallet.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnWallet.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnWallet.layer.shadowOpacity = 0
        btnWallet.layer.cornerRadius = 4
        btnWallet.clipsToBounds = true
        
        btnCard.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnCard.backgroundColor = UIColor.white
        btnCard.layer.borderWidth = 1
        btnCard.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCard.layer.masksToBounds = false
        btnCard.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCard.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnCard.layer.shadowOpacity = 0.2
        btnCard.layer.cornerRadius = 4
        btnCard.clipsToBounds = true
        
        btnCash.setTitleColor(UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1.0), for: .normal)
        btnCash.backgroundColor = UIColor.white
        btnCash.layer.borderWidth = 1
        btnCash.layer.borderColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCash.layer.masksToBounds = false
        btnCash.layer.shadowColor = UIColor(red: 43/255, green: 79/255, blue: 103/255, alpha:1).cgColor
        btnCash.layer.shadowOffset = CGSize(width: 0, height: 0)
        btnCash.layer.shadowOpacity = 0.2
        btnCash.layer.cornerRadius = 4
        btnCash.clipsToBounds = true
        
        
    }
    @IBAction func onOffers(_ sender: Any)
    {
        view.endEditing(true)
        appDelegate.strOfferType = "Booking"
        guard let myVC = self.storyboard?.instantiateViewController(withIdentifier: "ApplyOffersVC") as? ApplyOffersVC else { return }
        myVC.bookedTimeSlot = strTimeSlotID
        myVC.bookedAreaId = strAddresspassId
        myVC.bookedDate =  strBookingDate
        myVC.homeVc = self
        let navController = UINavigationController(rootViewController: myVC)
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    func onHandlePackages()
    {
        if strPackageSubscribed == "1"
        {
            txtClothesCount.frame = CGRect(x: (viewClothes.frame.size.width/2) - (txtClothesCount.frame.size.width/2) , y: btnOffers.frame.origin.y, width: txtClothesCount.frame.size.width, height: txtClothesCount.frame.size.height)
            
            lblClothesCount.frame = CGRect(x: (viewClothes.frame.size.width/2) - (lblClothesCount.frame.size.width/2) , y: lblClothesCount.frame.origin.y, width: lblClothesCount.frame.size.width, height: lblClothesCount.frame.size.height)
            
            txtPromoCode.isHidden = true
            btnOffers.isHidden = true
            
        }
        else
        {
            txtClothesCount.frame = CGRect(x: (viewClothes.frame.size.width) - (txtClothesCount.frame.size.width + 35) , y: (viewClothes.frame.size.height/4) - 17.5, width: txtClothesCount.frame.size.width, height: txtClothesCount.frame.size.height)
            
            lblClothesCount.frame = CGRect(x: 35 , y: (viewClothes.frame.size.height/4) - 17.5, width: lblClothesCount.frame.size.width, height: lblClothesCount.frame.size.height)
            
            txtPromoCode.isHidden = false
            btnOffers.isHidden = false
            
        }
    }
    
    func isValid(isWithCount: Bool) -> Bool {
        guard selectedAddressName != "" else {
            ToastCenter.default.cancelAll()
            Toast(text: "Please choose address", duration: 2.5).show()
            return false
        }
        
        guard dSelectedDate != "" && strTimeSlot != ""  else {
            ToastCenter.default.cancelAll()
            Toast(text: "Please choose date and time", duration: 2.5).show()
            return false
        }
        
        if isWithCount {
            guard fieldCount.trimmedText.count > 0 else {
                ToastCenter.default.cancelAll()
                Toast(text: "Please enter your clothes count", duration: 2.5).show()
                return false
            }
            
            guard let count = Int(fieldCount.text) else {
                ToastCenter.default.cancelAll()
                Toast(text: "Enter valid clothes count", duration: 2.5).show()
                return false
            }
            
            if (moveToPackagePage && subscriptionBalanceLow) || (moveToPackagePage == false && subscriptionBalanceLow){
                guard count >= 10 else {
                    ToastCenter.default.cancelAll()
                    Toast(text: "Clothes minimum 10 numbers only accepted", duration: 2.5).show()
                    return false
                }
            }else{
                guard count >= (Int(subscriptionMinimumOrderQuantity) ?? 0) else{
                    ToastCenter.default.cancelAll()
                    Toast(text: "Subscribe user Clothes minimum \(subscriptionMinimumOrderQuantity) numbers only accepted", duration: 2.5).show()
                    return false
                }
                guard count <= (Int(remainingPoints) ?? 0) else{
                    ToastCenter.default.cancelAll()
                    Toast(text: "Subscribe user only \(remainingPoints) available please Recharge", duration: 2.5).show()
                    return false
                }
              
                
            }
           
        }
        
        if fieldPromoCode.trimmedText.count > 0 && fieldVoucherCode.trimmedText.count > 0 {
            ToastCenter.default.cancelAll()
            Toast(text: "Please apply either promocode or voucher code", duration: 2.5).show()
            return false
        }
        return true
    }
    
    @IBAction func onConfirmBooking(_ sender: UIButton)
    {
        view.endEditing(true)
        strQuantity = fieldCount.text
//        if (Int(remainingPoints) ?? 0) <= (Int(strQuantity) ?? 0){
//            print("true")
//        }else{
//            print("false")
//        }
        
        
        self.bookingConfirmationAPICall()
        
//        if txtClothesCount.text == "" || (txtClothesCount.text?.trimmingCharacters(in: .whitespaces).isEmpty)!
//        {
//            sender.shake()
//            // ShowAlert(msg: "Please enter your clothes count")
//            ToastCenter.default.cancelAll()
//            Toast(text: "Please enter your clothes count", duration: 2.5).show()
//            let appearance = ToastView.appearance()
//            appearance.backgroundColor =  UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 0.80)
//            appearance.textColor = UIColor.white
//            appearance.font = UIFont(name: FONT_REG, size: 15)
//            appearance.textInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
//            appearance.bottomOffsetPortrait = 20
//            appearance.cornerRadius = 15
//        }
//        else if nCount! < 10
//        {
//            sender.shake()
//            // ShowAlert(msg: "Please enter your clothes count")
//            ToastCenter.default.cancelAll()
//            Toast(text: "Clothes minimum 10 numbers only accepted", duration: 2.5).show()
//            let appearance = ToastView.appearance()
//            appearance.backgroundColor =  UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 0.80)
//            appearance.textColor = UIColor.white
//            appearance.font = UIFont(name: FONT_REG, size: 15)
//            appearance.textInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
//            appearance.bottomOffsetPortrait = 20
//            appearance.cornerRadius = 15
//        }
//        else
//        {
//            strQuantity = txtClothesCount.text!
//            self.bookingConfirmationAPICall()
//        }
    }
    
    @IBAction func onSkipClothesCount(_ sender: Any)
    {
        view.endEditing(true)
        
        let alertController = UIAlertController(title: ALERT_TITLE, message: "Minimum count of clothes should \n be 10. Continue to confirm booking?", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
        let yesAction = UIAlertAction(title: "continue", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
            self.strQuantity = "10"
//            self.fieldCount.setText("10")
            self.bookingConfirmationAPICall()
        }
        
        // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
        let noAction = UIAlertAction(title: "go back", style: UIAlertActionStyle.cancel) {
            (result : UIAlertAction) -> Void in
            
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    }

    func bookingConfirmationAPICall()
    {
        view.endEditing(true)
//        guard isValid() else { return }
        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        if moveToPackagePage == false && subscriptionBalanceLow == false{
            strPaymentType = "Subscribtion"
        }
        
        let param: [String: Any] = [
            "addressId":strAddressId,
            "TimeSlotId":strTimeSlotID,
            "bookingDate":strBookingDate,
            "payment_type":strPaymentType,
            "promode_code":fieldPromoCode.text,
            "quantity":strQuantity,
            "bookingType":deliverytype,
            "voucher_code": fieldVoucherCode.text
        ]
        //        print("addressId,TimeSlotId,bookingDate,payment_type,promode_code,quantity,bookingType", strAddressId,strTimeSlotID,strBookingDate,strPaymentType,txtPromoCode.text,strQuantity) strQuantiity is more than some items 
        print("Params",param)
        print("token", accessToken)
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(USER_BOOKING, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                self.onClose(self)
                //                let ID = json.value(forKey: "bookingId")
                //                let strID = String(describing: ID!)
                
                let qty = json.value(forKey: "quantity")
                let strQty = String(describing: qty!)
                
                if strQty == ""
                {
                    self.lblBSQuantity.text = "Will be updated post pickup"
                }
                else
                {
                    self.lblBSQuantity.text = strQty
                }
                
                self.lblBSBookingID.text = json.value(forKey: "bookId") as? String ?? ""
                self.lblBSBookedDate.text = json.value(forKey: "bookingDate") as? String ?? ""
                self.lblBSBookedTime.text = json.value(forKey: "TimeSlots") as? String ?? ""
                let strPaymentMode = json.value(forKey: "paymentType") as? String ?? ""
                self.lblBSPaymentType.text = strPaymentMode.uppercased()
                
                self.viewBookingSuccess.isHidden = false
                self.showPopup(leftView: nil, rightView: nil, isMoveRight: true)
                self.setupNavigationBar(isDefault: true)
                self.fieldCount.setText("")
                self.viewClothes2.isHidden = true
                self.logAdded(toCartEvent: "Success", contentId: "", contentType: "Booking", currency: "Rs", valueToSum: 0)
                
                let viewControllerSize = self.view.frame.size
                let width = viewControllerSize.width
                let height = viewControllerSize.height
                let rect = CGRect(
                    origin: CGPoint(
                        x: width/2,
                        y: height/2),
                    size: CGSize(
                        width: 0,
                        height: 0))
                
                self.viewBookingSuccess.drawAnimatedCircularMask(
                    startFrame: rect,
                    duration: 0.33,
                    revealType: RevealType.reveal) { [weak self] in
                        self?.ImgBSTick.animation = "pop"
                        self?.ImgBSTick.curve = "easeIn"
                        self?.ImgBSTick.duration = 1.0
                        self?.ImgBSTick.repeatCount = 1
                        self?.ImgBSTick.animate()
                    }
                
            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
            }
            
            
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
        })
    }
    
    
    func oneClickBooking() {
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        AlamofireHC.requestPOST(ON_CLICK_BOOKING, params: nil, headers: header, success: { (JSON) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                
                self.onClose(self)
                
                let qty = json.value(forKey: "quantity")
                let strQty = String(describing: qty!)
                
                if strQty == ""
                {
                    self.lblBSQuantity.text = "Will be updated post pickup"
                }
                else
                {
                    self.lblBSQuantity.text = strQty
                }
                
                self.lblBSBookingID.text = json.value(forKey: "bookId") as? String ?? ""
                self.lblBSBookedDate.text = json.value(forKey: "bookingDate") as? String ?? ""
                self.lblBSBookedTime.text = json.value(forKey: "TimeSlots") as? String ?? ""
                let strPaymentMode = json.value(forKey: "paymentType") as? String ?? ""
                self.lblBSPaymentType.text = strPaymentMode.uppercased()
                
                self.viewBookingSuccess.isHidden = false
                self.logAdded(toCartEvent: "Success", contentId: "", contentType: "Booking", currency: "Rs", valueToSum: 0)
                
                let viewControllerSize = self.view.frame.size
                let width = viewControllerSize.width
                let height = viewControllerSize.height
                let rect = CGRect(
                    origin: CGPoint(
                        x: width/2,
                        y: height/2),
                    size: CGSize(
                        width: 0,
                        height: 0))
                
                self.viewBookingSuccess.drawAnimatedCircularMask(
                    startFrame: rect,
                    duration: 0.33,
                    revealType: RevealType.reveal) { [weak self] in
                        self?.ImgBSTick.animation = "pop"
                        self?.ImgBSTick.curve = "easeIn"
                        self?.ImgBSTick.duration = 1.0
                        self?.ImgBSTick.repeatCount = 1
                        self?.ImgBSTick.animate()
                    }
            }
            else
            {
                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                self.ShowAlert(msg: errorMessage)
            }
            
            
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
        })
    }
    
    func logAdded(toCartEvent contentData: String?, contentId: String?, contentType: String?, currency: String?, valueToSum price: Double) {
        let params = [AppEvents.ParameterName.content.rawValue: contentData ?? "", AppEvents.ParameterName.contentID.rawValue: contentId ?? "", AppEvents.ParameterName.contentType.rawValue: contentType ?? "", AppEvents.ParameterName.currency.rawValue: currency ?? ""]
        
        AppEvents.logEvent(AppEvents.Name.completedRegistration, valueToSum: price, parameters: params)
    }
    
    @IBAction func onGoHome(_ sender: Any)
    {
        
        fieldPromoCode.setText("")
        self.onHomeAPI()
        let viewControllerSize = view.frame.size
        let width = viewControllerSize.width
        let height = viewControllerSize.height
        let rect = CGRect(
            origin: CGPoint(
                x: width/2,
                y: height/2),
            size: CGSize(
                width: 0,
                height: 0))
        
        viewBookingSuccess.drawAnimatedCircularMask(
            startFrame: rect,
            duration: 0.33,
            revealType: RevealType.unreveal) { [weak self] in
                self?.viewBookingSuccess.isHidden = true
            }
        
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrAddress.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell", for: indexPath) as! AddressTableViewCell
        cell.selectionStyle = .none
        
        let dictAddress = self.arrAddress[indexPath.row] as! Dictionary<String, Any>
        let strFlatNo = dictAddress["flatNo"] as? String ?? ""
        let strAddress = dictAddress["address"] as? String ?? ""
        cell.lblAddress.text = strAddress
        
        let strLandmark = dictAddress["landmark"] as? String ?? ""
        if strLandmark != ""
        {
            cell.lblLandmark.text = "Landmark : " + strLandmark
        }
        else
        {
            cell.lblLandmark.text = ""
        }
        
        
        let strTitle = dictAddress["title"] as? String ?? ""
        if strTitle == "Other"
        {
            cell.imgRadio.isHidden = false
            cell.viewLine.isHidden = false
        }
        else
        {
            cell.imgRadio.isHidden = true
            cell.viewLine.isHidden = true
        }
        
        let adrsId = dictAddress["id"]
        let strAdrsId = String(describing: adrsId!)
        if strAddressId == strAdrsId
        {
            cell.imgRadio.image = UIImage(named: "RadioOn")
        }
        else
        {
            cell.imgRadio.image = UIImage(named: "RadioOff")
        }
        
        return cell
        
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let dictAddress = self.arrAddress[indexPath.row] as! Dictionary<String, Any>
        let addressId = dictAddress["id"]
        strAddressId = String(describing: addressId!)
        
        let addresspassId = dictAddress["serviceAreaId"]
        strAddresspassId = String(describing: addresspassId!)
        
        let address = dictAddress["address"]
        selectedAddressName = address as? String ?? ""
        
        tableAddress.reloadData()
    }
    
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == dateCollectionView
        {
            return arrDate.count
        }
        else
        {
            return arrTime.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == dateCollectionView
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCollectionViewCell", for: indexPath) as! DateCollectionViewCell
            
            let strDa = self.arrDate[indexPath.row] as? String ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            //   dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            let date = dateFormatter.date(from: strDa)!
            
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd"
            let strDate = formatter.string(from: date as Date)
            cell.lblDate.text = strDate
            
            formatter.dateFormat = "EEEEEEE"
            let strDay = formatter.string(from: date as Date)
            cell.lblDay.text = strDay
            
            formatter.dateFormat = "MMM"
            let strMonth = formatter.string(from: date as Date)
            cell.lblMonth.text = strMonth
            
            //leave days
            
            //            let strDa1 = self.arrleaveDate[indexPath.row] as? String ?? ""
            //
            //            let dateFormatter1 = DateFormatter()
            //            dateFormatter1.dateFormat = "dd-MM-yyyy"
            //            //   dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            //            let date1 = dateFormatter1.date(from: strDa1)!
            //
            //            if (Calendar.current.isDate(date, inSameDayAs:date1))
            //            {
            //                cell.contentView.frame = cell.bounds //This is important line
            //                let viewBG = cell.contentView.viewWithTag(10900) as! UIView
            //                viewBG.layoutIfNeeded() //This is important line
            //                viewBG.layer.cornerRadius = 5
            //                viewBG.layer.borderWidth = 1
            //                viewBG.layer.borderColor = UIColor.clear.cgColor
            //                viewBG.backgroundColor =  UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1)
            //                cell.lblDate.textColor = UIColor.white
            //                cell.lblDay.textColor = UIColor.white
            //                cell.lblMonth.textColor = UIColor.white
            //            }
            
            //            let formatter1 = DateFormatter()
            //            formatter1.dateFormat = "dd"
            //            let strDate1 = formatter1.string(from: date1 as Date)
            //
            //            formatter1.dateFormat = "EEEEEEE"
            //            let strDay1 = formatter1.string(from: date1 as Date)
            //
            //            formatter1.dateFormat = "MMM"
            //            let strMonth1 = formatter1.string(from: date1 as Date)
            
            ///leave days end
            
            let calendar = Calendar.current
            
            if (calendar.isDateInToday(date))
            {
                cell.lblDay.text = "Today"
            }
            
            
            //            if (calendar.isDateInTomorrow(date))
            //            {
            //                cell.lblDay.text = "Tomorrow"
            //            }
            
            
            if selectedDateIndex == indexPath.row
            {
                cell.contentView.frame = cell.bounds //This is important line
                let viewBG = cell.contentView.viewWithTag(10900) as! UIView
                viewBG.layoutIfNeeded() //This is important line
                viewBG.layer.cornerRadius = 5
                viewBG.layer.borderWidth = 1
                viewBG.layer.borderColor = UIColor.clear.cgColor
                viewBG.backgroundColor =  UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1)
                cell.lblDate.textColor = UIColor.white
                cell.lblDay.textColor = UIColor.white
                cell.lblMonth.textColor = UIColor.white
                
            }
            else
            {
                cell.contentView.frame = cell.bounds //This is important line
                let viewBG = cell.contentView.viewWithTag(10900) as! UIView
                viewBG.layoutIfNeeded() //This is important line
                viewBG.layer.cornerRadius = 5
                viewBG.layer.borderWidth = 1
                viewBG.layer.borderColor = UIColor.black.cgColor
                viewBG.backgroundColor =  UIColor.white
                cell.lblDate.textColor = UIColor(red: 114/255, green: 114/255, blue: 114/255, alpha: 1)
                cell.lblDay.textColor = UIColor(red: 114/255, green: 114/255, blue: 114/255, alpha: 1)
                cell.lblMonth.textColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1)
            }
            
            
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCollectionViewCell", for: indexPath) as! TimeCollectionViewCell
            
            let dict = self.arrTime[indexPath.row] as! Dictionary<String,Any>
            let strTime = dict["TimeSlot"] as? String ?? ""
            cell.lblTime.text = strTime
            let fillingstatus = dict["slotststus"] as? String ?? ""
            
            if selectedTimeIndex == indexPath.row
            {
                if fillingstatus=="1"
                {
                    cell.contentView.frame = cell.bounds //This is important line
                    let viewBG = cell.contentView.viewWithTag(10900) as! UIView
                    viewBG.layoutIfNeeded() //This is important line
                    viewBG.layer.cornerRadius = 5
                    viewBG.layer.borderWidth = 1
                    viewBG.layer.borderColor = UIColor.clear.cgColor
                    viewBG.backgroundColor =  UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1)
                    cell.lblTime.textColor = UIColor(red: 42/255, green: 78/255, blue: 42/255, alpha: 1)
                    viewBG.clipsToBounds = true
                }
                else if fillingstatus=="2"
                {
                    cell.contentView.frame = cell.bounds //This is important line
                    let viewBG = cell.contentView.viewWithTag(10900) as! UIView
                    viewBG.layoutIfNeeded() //This is important line
                    viewBG.layer.cornerRadius = 5
                    viewBG.layer.borderWidth = 1
                    viewBG.layer.borderColor = UIColor.clear.cgColor
                    viewBG.backgroundColor =  UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1)
                    cell.lblTime.textColor = UIColor.orange
                    viewBG.clipsToBounds = true
                }
                else if fillingstatus=="3"
                {
                    cell.contentView.frame = cell.bounds //This is important line
                    let viewBG = cell.contentView.viewWithTag(10900) as! UIView
                    viewBG.layoutIfNeeded() //This is important line
                    viewBG.layer.cornerRadius = 5
                    viewBG.layer.borderWidth = 1
                    viewBG.layer.borderColor = UIColor.clear.cgColor
                    viewBG.backgroundColor =  UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1)
                    cell.lblTime.textColor = UIColor.red
                    viewBG.clipsToBounds = true
                    
                }
                
                
            }
            else
            {
                
                if fillingstatus=="1"
                {
                    cell.contentView.frame = cell.bounds //This is important line
                    let viewBG = cell.contentView.viewWithTag(10900) as! UIView
                    viewBG.layoutIfNeeded() //This is important line
                    viewBG.layer.cornerRadius = 5
                    viewBG.layer.borderWidth = 1
                    viewBG.layer.borderColor = UIColor.black.cgColor
                    viewBG.backgroundColor =  UIColor.white
                    cell.lblTime.textColor = UIColor(red: 42/255, green: 78/255, blue: 42/255, alpha: 1)
                }
                else if fillingstatus=="2"
                {
                    cell.contentView.frame = cell.bounds //This is important line
                    let viewBG = cell.contentView.viewWithTag(10900) as! UIView
                    viewBG.layoutIfNeeded() //This is important line
                    viewBG.layer.cornerRadius = 5
                    viewBG.layer.borderWidth = 1
                    viewBG.layer.borderColor = UIColor.black.cgColor
                    viewBG.backgroundColor =  UIColor.white
                    cell.lblTime.textColor = UIColor.orange
                }
                else if fillingstatus=="3"
                {
                    cell.contentView.frame = cell.bounds //This is important line
                    let viewBG = cell.contentView.viewWithTag(10900) as! UIView
                    viewBG.layoutIfNeeded() //This is important line
                    viewBG.layer.cornerRadius = 5
                    viewBG.layer.borderWidth = 1
                    viewBG.layer.borderColor = UIColor.black.cgColor
                    viewBG.backgroundColor =  UIColor.white
                    cell.lblTime.textColor = UIColor.red
                    
                }
                
            }
            
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
                        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView == dateCollectionView
        {
            selectedDateIndex = indexPath.row
            let strDa = self.arrDate[indexPath.row] as? String ?? ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            //   dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            let date = dateFormatter.date(from: strDa)!
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            let strYear = formatter.string(from: date as Date)
            lblYear.text = strYear
            
            formatter.dateFormat = "dd"
            let strDate = formatter.string(from: date as Date)
            
            formatter.dateFormat = "EEE"
            let strDay = formatter.string(from: date as Date)
            lblDateInTime.text = strDay + " " + strDate
            lblDateInDate.text = strDay + " " + strDate
            lblDateInAddress.text = strDay + " " + strDate
            formatter.dateFormat = "dd-MM-yyyy"
            strBookingDate = formatter.string(from: date as Date)
            btnDateNext.isUserInteractionEnabled = true
            btnDateNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), for: .normal)
            
            
            let dtFormatter = DateFormatter()
            dtFormatter.dateFormat = "EEE, dd"
            dSelectedDate = dtFormatter.string(from: date)
            // dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
//            let Currdate = dtFormatter.date(from: CurrentDate)!
            
            dateCollectionView.reloadData()
            
            /*
             // Using granularity of .day
             let order = Calendar.current.compare(Currdate, to: date, toGranularity: .day)
             
             switch order {
             case .orderedAscending:
             //  print("\(date) is after \(Currdate)")
             strSelectedDay = "NotToday"
             case .orderedDescending:
             //   print("\(date) is before \(Currdate)")
             strSelectedDay = "NotToday"
             default:
             //   print("\(date) is the same as \(Currdate)")
             strSelectedDay = "Today"
             }
             */
            
        }
        else
        {
            let dict = self.arrTime[indexPath.row] as! Dictionary<String,Any>
            let fillingstatus = dict["slotststus"] as? String ?? ""
            
            if fillingstatus=="1"
            {
                selectedTimeIndex = indexPath.row
                let dict = self.arrTime[indexPath.row] as! Dictionary<String,Any>
                strTimeSlot = dict["TimeSlot"] as? String ?? ""
                let TimeSlotID = dict["id"]
                strTimeSlotID = String(describing: TimeSlotID!)
                lblTimeInTime.text = strTimeSlot
                lblTimeInDate.text = strTimeSlot
                lblTimeInAddress.text = strTimeSlot
                btnTimeNext.isUserInteractionEnabled = true
                btnTimeNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), for: .normal)
                timeCollectionView.reloadData()
            }
            else if fillingstatus=="2"
            {
                selectedTimeIndex = indexPath.row
                let dict = self.arrTime[indexPath.row] as! Dictionary<String,Any>
                strTimeSlot = dict["TimeSlot"] as? String ?? ""
                let TimeSlotID = dict["id"]
                strTimeSlotID = String(describing: TimeSlotID!)
                lblTimeInTime.text = strTimeSlot
                lblTimeInDate.text = strTimeSlot
                lblTimeInAddress.text = strTimeSlot
                btnTimeNext.isUserInteractionEnabled = true
                btnTimeNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), for: .normal)
                timeCollectionView.reloadData()
            }
            else if fillingstatus=="3"
            {
                selectedTimeIndex = indexPath.row
                let dict = self.arrTime[indexPath.row] as! Dictionary<String,Any>
                strTimeSlot = dict["TimeSlot"] as? String ?? ""
                let TimeSlotID = dict["id"]
                strTimeSlotID = String(describing: TimeSlotID!)
                lblTimeInTime.text = strTimeSlot
                lblTimeInDate.text = strTimeSlot
                lblTimeInAddress.text = strTimeSlot
                btnTimeNext.isUserInteractionEnabled = false
                btnTimeNext.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), for: .normal)
                timeCollectionView.reloadData()
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var cellWidth: CGFloat = 0
        var cellHeight: CGFloat = 0
        
        if collectionView == dateCollectionView
        {
            cellWidth = (collectionView.frame.size.width-15)/4.0
            cellHeight = (collectionView.frame.size.height-15)/4.0
        }
        else
        {
            cellWidth = (collectionView.frame.size.width-12)/3.0
            cellHeight = (collectionView.frame.size.height-12)/3.0
        }
        
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // MARK: - TextField Delegate
    private func addBottomLineToTextField(textField : UITextField, color: String) {
        let border = CALayer()
        let borderWidth = CGFloat(2)
        if color == "green"
        {
            border.borderColor = UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0).cgColor
        }
        else
        {
            border.borderColor = UIColor.lightGray.cgColor
        }
        border.frame = CGRect.init(x: 0, y: textField.frame.size.height - borderWidth, width: textField.frame.size.width, height: textField.frame.size.height)
        border.borderWidth = borderWidth
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
        done.tintColor = UIColor.black
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        txtClothesCount.inputAccessoryView = doneToolbar
        [fieldCount, fieldPromoCode, fieldVoucherCode].forEach { field in
            field.textField.inputAccessoryView = doneToolbar
        }
    }
    
    @objc func doneButtonAction() {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtClothesCount
        {
            
            let  maxLength = 3
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
            
        }
        else if textField == txtPromoCode
        {
            
            let  maxLength = 10
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
            
            if newString.length <= maxLength
            {
                txtPromoCode.text = (textField.text! as NSString).replacingCharacters(in: range, with: string.uppercased())
            }
            return false
        }
        return false
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func showAlert(title:String,message:String)  {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func segmentcontrolchanges(_ sender: UISegmentedControl)
    {
        
        if sender.selectedSegmentIndex == 0
        {
            deliverytype = "0"
            print(deliverytype)
        }
        else
        {
            deliverytype = "1"
            print(deliverytype)
            
        }
    }
    
    func serverTimeReturn(completionHandler:@escaping (_ getResDate: NSDate?) -> Void){
        
        let url = NSURL(string: "https://www.google.com/")
        let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            if let contentType = httpResponse!.allHeaderFields["Date"] as? String {
                
                let dFormatter = DateFormatter()
                dFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
                let serverTime = dFormatter.date(from: contentType)
                completionHandler(serverTime! as NSDate)
            }
        }
        
        task.resume()
    }
    
    // MARK: - Update Paytm Pending Responses
    
    func checkPendingPaytmResponse()
    {
        
        let PaytmRsponsesData = userDefaults.object(forKey: "PaytmRsponse") as? NSData
        if let PaytmRsponsesData = PaytmRsponsesData {
            appDelegate.arrPaytmRsponse = NSKeyedUnarchiver.unarchiveObject(with: PaytmRsponsesData as Data) as! Array<Any>
            
            for i in 0..<appDelegate.arrPaytmRsponse.count
            {
                if i == 0
                {
                    var dict = appDelegate.arrPaytmRsponse[i] as! Dictionary<String, Any>
                    let strpaymentType = dict["paymentType"] as? String ?? ""
                    
                    if strpaymentType == "Wallet"
                    {
                        self.AddMoneyAPICallOnPaymentSuccess(response: dict)
                    }
                    else if strpaymentType == "Package"
                    {
                        self.AddPackageAPICallOnPaymentSuccess(response: dict)
                    }
                    else if strpaymentType == "Service"
                    {
                        self.CardPaymentAPICallOnPaymentSuccess(response: dict)
                    }
                    
                }
                
                
            }
            
        }
    }
    
    func AddMoneyAPICallOnPaymentSuccess(response: Dictionary<String, Any>)
    {
        view.endEditing(true)
        //    self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        let strTransId = response["TXNID"] as? String ?? ""
        let strOrdId = response["ORDERID"] as? String ?? ""
        let strTranStatus = response["STATUS"] as? String ?? ""
        let strTransAmount = response["TXNAMOUNT"] as? String ?? ""
        let strCheckSum = response["CHECKSUMHASH"] as? String ?? ""
        let strPaymentMode = response["PAYMENTMODE"] as? String ?? ""
        let strTransDate = response["TXNDATE"] as? String ?? ""
        let strBankName = response["BANKNAME"] as? String ?? ""
        let strBankTransID = response["BANKTXNID"] as? String ?? ""
        let strStatusCode = response["RESPCODE"] as? String ?? ""
        let strOfferCode = response["offer_code"] as? String ?? ""
        
        let param: [String: Any] = [
            "transactionId":strTransId,
            "orderId":strOrdId,
            "tnx_status":strTranStatus,
            "txn_amount":strTransAmount,
            "check_sum":strCheckSum,
            "payment_mode":strPaymentMode,
            "tnx_date":strTransDate,
            "bank_name":strBankName,
            "bank_tnx_id":strBankTransID,
            "status_code":strStatusCode,
            "offer_code": strOfferCode
        ]
        
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(ADD_AMOUNT_WALLET, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            //  UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                
                let strOrderId = json.value(forKey: "orderId")as? String ?? ""
                
                let PaytmRsponsesData = userDefaults.object(forKey: "PaytmRsponse") as? NSData
                if let PaytmRsponsesData = PaytmRsponsesData {
                    appDelegate.arrPaytmRsponse = NSKeyedUnarchiver.unarchiveObject(with: PaytmRsponsesData as Data) as! Array<Any>
                    
                    for i in 0..<appDelegate.arrPaytmRsponse.count
                    {
                        var dict = appDelegate.arrPaytmRsponse[i] as! Dictionary<String, Any>
                        let strOrdId = dict["ORDERID"] as? String ?? ""
                        if strOrdId == strOrderId
                        {
                            appDelegate.arrPaytmRsponse.remove(at: i)
                            let PaytmRsponsesData = NSKeyedArchiver.archivedData(withRootObject: appDelegate.arrPaytmRsponse)
                            userDefaults.set(PaytmRsponsesData, forKey: "PaytmRsponse")
                        }
                        
                    }
                    
                }
                
                
                //                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                //                self.ShowAlert(msg: errorMessage)
                
            }
            else
            {
                //                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                //                self.ShowAlert(msg: errorMessage)
            }
            
            
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
        })
    }
    
    func CardPaymentAPICallOnPaymentSuccess(response: Dictionary<String, Any>)
    {
        view.endEditing(true)
        //        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        let strTransId = response["TXNID"] as? String ?? ""
        let strOrdId = response["ORDERID"] as? String ?? ""
        let strTranStatus = response["STATUS"] as? String ?? ""
        let strTransAmount = response["TXNAMOUNT"] as? String ?? ""
        let strCheckSum = response["CHECKSUMHASH"] as? String ?? ""
        let strPaymentMode = response["PAYMENTMODE"] as? String ?? ""
        let strTransDate = response["TXNDATE"] as? String ?? ""
        let strBankName = response["BANKNAME"] as? String ?? ""
        let strBankTransID = response["BANKTXNID"] as? String ?? ""
        let strStatusCode = response["RESPCODE"] as? String ?? ""
        let strBookingId = response["bookingId"] as? String ?? ""
        
        
        let param: [String: Any] = [
            "transactionId":strTransId,
            "orderId":strOrdId,
            "tnx_status":strTranStatus,
            "txn_amount":strTransAmount,
            "check_sum":strCheckSum,
            "payment_mode":strPaymentMode,
            "tnx_date":strTransDate,
            "bank_name":strBankName,
            "bank_tnx_id":strBankTransID,
            "status_code":strStatusCode,
            "bookingId":strBookingId
        ]
        
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(CARD_PAYMENT, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            //            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                let strOrderId = json.value(forKey: "orderId")as? String ?? ""
                
                let PaytmRsponsesData = userDefaults.object(forKey: "PaytmRsponse") as? NSData
                if let PaytmRsponsesData = PaytmRsponsesData {
                    appDelegate.arrPaytmRsponse = NSKeyedUnarchiver.unarchiveObject(with: PaytmRsponsesData as Data) as! Array<Any>
                    
                    for i in 0..<appDelegate.arrPaytmRsponse.count
                    {
                        var dict = appDelegate.arrPaytmRsponse[i] as! Dictionary<String, Any>
                        let strOrdId = dict["ORDERID"] as? String ?? ""
                        if strOrdId == strOrderId
                        {
                            appDelegate.arrPaytmRsponse.remove(at: i)
                            let PaytmRsponsesData = NSKeyedArchiver.archivedData(withRootObject: appDelegate.arrPaytmRsponse)
                            userDefaults.set(PaytmRsponsesData, forKey: "PaytmRsponse")
                        }
                        
                    }
                    
                }
                
                //                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                //                self.ShowAlert(msg: errorMessage)
                
            }
            else
            {
                //                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                //                self.ShowAlert(msg: errorMessage)
            }
            
            
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
        })
    }
    
    func AddPackageAPICallOnPaymentSuccess(response: Dictionary<String, Any>)
    {
        view.endEditing(true)
        //        self.navigationController?.view.addSubview(UIView().customActivityIndicator(view: (self.navigationController?.view)!, widthView: nil, message: "Loading"))
        
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        
        let strTransId = response["TXNID"] as? String ?? ""
        let strOrdId = response["ORDERID"] as? String ?? ""
        let strTranStatus = response["STATUS"] as? String ?? ""
        let strTransAmount = response["TXNAMOUNT"] as? String ?? ""
        let strCheckSum = response["CHECKSUMHASH"] as? String ?? ""
        let strPaymentMode = response["PAYMENTMODE"] as? String ?? ""
        let strTransDate = response["TXNDATE"] as? String ?? ""
        let strBankName = response["BANKNAME"] as? String ?? ""
        let strBankTransID = response["BANKTXNID"] as? String ?? ""
        let strStatusCode = response["RESPCODE"] as? String ?? ""
        
        let quantity = response["quantity"] as? String ?? ""
        let strPackageID = response["packageID"] as? String ?? ""
        
        
        let param: [String: Any] = [
            "transactionId":strTransId,
            "orderId":strOrdId,
            "tnx_status":strTranStatus,
            "txn_amount":strTransAmount,
            "check_sum":strCheckSum,
            "payment_mode":strPaymentMode,
            "tnx_date":strTransDate,
            "bank_name":strBankName,
            "bank_tnx_id":strBankTransID,
            "status_code":strStatusCode,
            "quantity":quantity,
            "packageId": strPackageID
        ]
        
        
        self.CheckNetwork()
        
        AlamofireHC.requestPOST(PAYMENT_PACKAGES, params: param as [String : AnyObject], headers: header, success: { (JSON) in
            //            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            let  result = JSON.dictionaryObject
            let json = result! as NSDictionary
            let err = json.value(forKey: "error") as? String ?? ""
            if (err == "false")
            {
                let strOrderId = json.value(forKey: "orderId")as? String ?? ""
                
                let PaytmRsponsesData = userDefaults.object(forKey: "PaytmRsponse") as? NSData
                if let PaytmRsponsesData = PaytmRsponsesData {
                    appDelegate.arrPaytmRsponse = NSKeyedUnarchiver.unarchiveObject(with: PaytmRsponsesData as Data) as! Array<Any>
                    
                    for i in 0..<appDelegate.arrPaytmRsponse.count
                    {
                        var dict = appDelegate.arrPaytmRsponse[i] as! Dictionary<String, Any>
                        let strOrdId = dict["ORDERID"] as? String ?? ""
                        if strOrdId == strOrderId
                        {
                            appDelegate.arrPaytmRsponse.remove(at: i)
                            let PaytmRsponsesData = NSKeyedArchiver.archivedData(withRootObject: appDelegate.arrPaytmRsponse)
                            userDefaults.set(PaytmRsponsesData, forKey: "PaytmRsponse")
                        }
                        
                    }
                    
                }
            }
            else
            {
                //                let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                //                self.ShowAlert(msg: errorMessage)
            }
            
            
        }, failure: { (error) in
            UIView().hideLoader(removeFrom: (self.navigationController?.view)!)
            print(error)
        })
    }
}
@available(iOS 13.0.0, *)

struct LocationConfirmationAlertView: View {
    let onTap: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            VStack {
                Text("Confirmation")
                    .font(.custom(FONT_MEDIUM, size: 25))
                    .foregroundColor(Color(.primaryColor))
                    .padding(.bottom, 15)
                
                Text("We request you to reconfirm your home location for better accuracy")
                    .font(.custom(FONT_REG, size: 18))
                    .foregroundColor(Color(.primaryColor))
                
                Button {
                    onTap()
                } label: {
                    Text("OK")
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(
                            Color(.primaryColor)
                        )
                }
                .padding(.vertical, 15)
            }
            .padding([.horizontal, .top])
            .fixedSize(horizontal: false, vertical: true)
            .background(
                Color.white
            )
        }
        .fixedSize(horizontal: false, vertical: false)
    }
}
@available(iOS 13.0.0, *)

struct Previews: PreviewProvider {
    static var previews: some View {
        LocationConfirmationAlertView(onTap: {})
    }
}


