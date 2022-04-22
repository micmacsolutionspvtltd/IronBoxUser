//
//  AddAddressVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 28/03/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import  GoogleMaps
import GooglePlaces
import  Toaster
import Alamofire
import NVActivityIndicatorView
import DropDown
import iOSDropDown

protocol DelegateUpdateLocation {
    func didupdateLocation(isUpdated: Bool)
}

class AddAddressVC: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, GMSAutocompleteViewControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var dropDownTextFld: UITextField!
    @IBOutlet weak var viewGoogleMap: GMSMapView!
    @IBOutlet weak var viewAddress: UIView!
    @IBOutlet weak var markerCenter: UIImageView!
    @IBOutlet weak var back: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var imgHomeRadio: UIImageView!
    @IBOutlet weak var imgWorkRadio: UIImageView!
    @IBOutlet weak var imgOtherRadio: UIImageView!
    
    @IBOutlet weak var btnHomeRadio: UIButton!
    @IBOutlet weak var btnWorkRadio: UIButton!
    @IBOutlet weak var btnOtherRadio: UIButton!
    
    @IBOutlet weak var txtFlatNo: UITextField!
   
    @IBOutlet weak var pincodeButton: UIButton!
    @IBOutlet weak var txtLandmark: UITextField!
    @IBOutlet weak var txtApartmentname: UITextField!
    @IBOutlet weak var txtStreetname: UITextField!
    @IBOutlet weak var txtAreacity: UITextField!
    @IBOutlet weak var viewAddressOnMap: UIView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnAddressOnMap: UIButton!
    var delegateDidUpdateLocation: DelegateUpdateLocation?
    
    var ViewTutorial = UIView()
    var ImgTutorial = UIImageView()
    let dropDown = DropDown()
    var selectedPincode = ""
    var strAddressType = ""
    var strPincode = ""
    var strAddrLine = ""
    var strFlatno = ""
    var strLandmark = ""
    var strApartmentname = ""
    var strStreetname = ""
    var strAreacity = ""
    var strArea = ""
    var strCity = ""
    var strLat = ""
    var strLong = ""
    var dictAddress = Dictionary<String,Any>()
    var height = CGFloat()
    var isForSpecialUpdate = false //There is two update address api
    var editAddressID: String!
    var pincodeValues:[String] = []
    var pincodeIds:[Int] = []
//    var isSpecialAddressUpdated = false
    var searchText = String() {
        didSet{
            var dataFiltered: [String] = []
                    if searchText == "" {
                dataFiltered = self.pincodeValues
            }else{
                dataFiltered = pincodeValues.filter {
                    return $0.range(of: searchText, options: .caseInsensitive) != nil
                }
            }
            if dataFiltered.count == 0{
                dropDown.dataSource = ["No service available"]
            }else{
            dropDown.dataSource = dataFiltered
            }
            dropDown.show()
        }
    }
    fileprivate var didSelectCompletion: (String, Int ,Int) -> () = {selectedText, index , id  in }
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
     //   dropDownTextFld.isHidden = true
        dropDownTextFld.delegate = self
        dropDownTextFld.addTarget(self, action: #selector(myTargetFunction), for: .touchDown)
      
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.setFontFamilyAndSize()
        self.hideKeyboardWhenTappedAround()
        // viewAddress.backgroundColor = UIColor.white
        //        let camera = GMSCameraPosition.camera(withLatitude: 13.0827, longitude: 80.2707, zoom: 15.5)
        //        self.viewGoogleMap.camera = camera
        //        self.viewGoogleMap.settings.scrollGestures = true
        //        self.viewGoogleMap.settings.compassButton = true
        //        self.viewGoogleMap.isMyLocationEnabled = true
        //        self.viewGoogleMap.settings.myLocationButton = true
        self.viewGoogleMap.delegate = self
        //        do {
        //            // Set the map style by passing the URL of the local file. Make sure style.json is present in your project
        //            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
        //                viewGoogleMap.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
        //            } else {
        //                print("Unable to find style.json")
        //            }
        //        } catch {
        //            print("The style definition could not be loaded: \(error)")
        //        }
        
        //Location Manager code to fetch current location
        locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        markerCenter.layer.zPosition = 1
        back.layer.zPosition = 1
        backButton.layer.zPosition = 1
        viewAddressOnMap.layer.zPosition = 1
        lblAddress.layer.zPosition = 1
        btnAddressOnMap.layer.zPosition = 1
        strAddressType = "Home"
        appDelegate.isNewAddressAdded = false
        
        imgHomeRadio.image = UIImage(named: "RadioOn") // RadioOff
        imgWorkRadio.image = UIImage(named: "RadioOff")
        imgOtherRadio.image = UIImage(named: "RadioOff")
        
        if(dictAddress.count != 0)
        {
            
            strPincode = dictAddress["pincode"] as? String ?? ""
            strAddressType = dictAddress["title"] as? String ?? ""
            txtFlatNo.text = dictAddress["flatNo"] as? String ?? ""
            pincodeButton.setTitle(strPincode, for: .normal)
            txtLandmark.text = dictAddress["landmark"] as? String ?? ""
            strAddrLine = dictAddress["address"] as? String ?? ""
            txtStreetname.text = dictAddress["street"] as? String ?? ""
            txtAreacity.text = dictAddress["city"] as? String ?? ""
            let lat = dictAddress["latitude"]
            let long = dictAddress["longitude"]
            strLat = String(describing: lat!)
            strLong = String(describing: long!)
            let latt = Double(strLat)
            let longg = Double(strLong)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            {
                let camera = GMSCameraPosition.camera(withLatitude: latt!, longitude: longg! , zoom: 15.5)
                self.viewGoogleMap?.animate(to: camera)
                
            }
            
            if strAddressType == "Home"
            {
                self.onHome(self)
            }
            else if strAddressType == "Work"
            {
                self.onWork(self)
            }
            else
            {
                self.onOthers(self)
            }
            
        }
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.viewAddress.addGestureRecognizer(gestureRecognizer)
        markerCenter.layer.zPosition = 1
        pincodeButton.layer.borderColor = UIColor.black.cgColor
        pincodeButton.layer.borderWidth = 1
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if ((userDefaults.value(forKey: IS_ADDADDRESS_TUTORIAL_SHOWN) as? String) == nil)
        {
            self.showTutorialScreen()
        }
        
        if dictAddress.count == 0 {
            let ud = UserDefaults.standard
            var startingX = ud.double(forKey: CUR_LATITUDE)
            var startingY = ud.double(forKey: CUR_LONGITUDE)
            if startingX == 0.0 && startingY == 0.0 {
                startingX = 13.0632
                startingY = 80.2250
            }
            
            let camera = GMSCameraPosition.camera(withLatitude: startingX, longitude: startingY, zoom: 18.0)
            viewGoogleMap.camera = camera
        }
        
        self.viewGoogleMap.mapType = .normal
        
        self.viewGoogleMap.settings.scrollGestures = true
        self.viewGoogleMap.settings.rotateGestures = true
        self.viewGoogleMap.settings.consumesGesturesInView = true
        self.viewGoogleMap.settings.compassButton = true
        
        self.viewGoogleMap.isMyLocationEnabled = true
        self.viewGoogleMap.settings.myLocationButton = true
        //        self.viewGoogleMap.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        height = self.viewGoogleMap.frame.size.height + self.viewAddress.frame.size.height
        setupDropDown()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//            delegateDidUpdateLocation?.didupdateLocation(isUpdated: isSpecialAddressUpdated)
//    }
    
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
        self.view.addSubview(ViewTutorial)
        
        ImgTutorial  = UIImageView(frame:CGRect(x:0, y:0, width:screenSize.width, height:screenSize.height));
        ImgTutorial.image = UIImage(named:"TutoAddAddress1")
        ViewTutorial.addSubview(ImgTutorial)
        
        let btnNxt:UIButton = UIButton(frame:  CGRect(x: screenSize.width - 100, y: screenSize.height - 250, width: 100, height: 50))
        btnNxt.backgroundColor = UIColor.white
        btnNxt.addTarget(self, action: #selector(self.onTutorialNext(_:)), for:.touchUpInside)
        ViewTutorial.addSubview(btnNxt)
        
    }
    
    @IBAction func onTutorialNext(_ sender: Any)
    {
        userDefaults.set("yes", forKey: IS_ADDADDRESS_TUTORIAL_SHOWN)
        ViewTutorial.removeFromSuperview()
    }
    
    // MARK: - PAN GESTURE
    @IBAction func handlePan(_ gestureRecognizer: UIPanGestureRecognizer)
    {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed
        {
            let translation = gestureRecognizer.translation(in: self.view)
            let y = gestureRecognizer.view!.frame.origin.y + translation.y
            let yMax = (height/10) * 7.5
            let yMin = (height/10) * 5
            
            if y >= yMin && y <= yMax
            {
                // note: 'view' is optional and need to be unwrapped
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y + translation.y)
                
                self.viewGoogleMap.frame.size.height = viewGoogleMap.frame.origin.y + viewAddress.frame.origin.y
                self.viewGoogleMap.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.viewGoogleMap.updateFocusIfNeeded()
                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
                
                self.markerCenter.center.y = self.viewGoogleMap.center.y - 15
                self.markerCenter.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.markerCenter.transform = CGAffineTransform.identity
                
            }
            
            
        }
        
        if gestureRecognizer.state == .ended {
            // Do what you want
            let translation = gestureRecognizer.translation(in: self.view)
            let y = gestureRecognizer.view!.frame.origin.y + translation.y
            
            if y >=  (self.height/10) * 6.25
            {
                UIView.animate(withDuration: 0.2, animations: {
                    self.viewGoogleMap.frame.size.height = (self.height/10) * 7.5
                    self.viewAddress.frame.origin.y =  self.viewGoogleMap.frame.origin.y + self.viewGoogleMap.frame.size.height
                    self.viewAddress.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.viewGoogleMap.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.markerCenter.center.y = self.viewGoogleMap.center.y - 15
                    self.markerCenter.transform = CGAffineTransform(scaleX: 1, y: 1)
                }) { (finished) in
                    UIView.animate(withDuration: 0.4, animations: {
                        self.viewGoogleMap.transform = CGAffineTransform.identity
                        self.viewAddress.transform = CGAffineTransform.identity
                        self.markerCenter.transform = CGAffineTransform.identity
                    })
                }
            }
            else
            {
                UIView.animate(withDuration: 0.2, animations: {
                    self.viewGoogleMap.frame.size.height = (self.height/10) * 5
                    self.viewAddress.frame.origin.y =  self.viewGoogleMap.frame.origin.y + self.viewGoogleMap.frame.size.height
                    self.viewAddress.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.viewGoogleMap.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.markerCenter.center.y = self.viewGoogleMap.center.y - 15
                    self.markerCenter.transform = CGAffineTransform(scaleX: 1, y: 1)
                }) { (finished) in
                    UIView.animate(withDuration: 0.4, animations: {
                        self.viewGoogleMap.transform = CGAffineTransform.identity
                        self.viewAddress.transform = CGAffineTransform.identity
                        self.markerCenter.transform = CGAffineTransform.identity
                    })
                }
            }
        }
    }
    
    // MARK: - ACTIONS
    @IBAction func onBack(_ sender: Any)
    {
        appDelegate.IsNewRegistration = false
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onHome(_ sender: Any)
    {
        strAddressType = "Home"
        imgHomeRadio.image = UIImage(named: "RadioOn") // RadioOff
        imgWorkRadio.image = UIImage(named: "RadioOff")
        imgOtherRadio.image = UIImage(named: "RadioOff")
    }
    @IBAction func onWork(_ sender: Any)
    {
        strAddressType = "Work"
        imgHomeRadio.image = UIImage(named: "RadioOff") // RadioOff
        imgWorkRadio.image = UIImage(named: "RadioOn")
        imgOtherRadio.image = UIImage(named: "RadioOff")
    }
    @IBAction func onOthers(_ sender: Any)
    {
        strAddressType = "Other"
        imgHomeRadio.image = UIImage(named: "RadioOff") // RadioOff
        imgWorkRadio.image = UIImage(named: "RadioOff")
        imgOtherRadio.image = UIImage(named: "RadioOn")
    }
    
    @IBAction func onEnterAddress(_ sender: Any)
    {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func onConfirm(_ sender: Any)
    {
        view.endEditing(true)
        
        if txtFlatNo.text! == "" || (txtFlatNo.text?.trimmingCharacters(in: .whitespaces).isEmpty)!
        {
            ShowAlert(msg: "Please enter flat no / block / floor")
        }
        else if selectedPincode == "" || (pincodeButton.titleLabel?.text?.trimmingCharacters(in: .whitespaces).isEmpty)!
        {
            ShowAlert(msg: "Please enter pincode")
        }
        else if selectedPincode.count != 6
        {
            ShowAlert(msg: "Please enter valid pincode")
        }
        else
        {
            self.view.addSubview(UIView().customActivityIndicator(view: (self.view)!, widthView: nil, message: "Loading"))
            
            let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
            let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
            var API_EDIT_ADD = ADD_ADDRESS
            var addressValue = txtFlatNo.text! + ","
            if let street = txtStreetname.text,street.count > 0 {
                addressValue += street + ","
            }
            
            if let apartmentName = txtApartmentname.text,apartmentName.count > 0 {
                addressValue += apartmentName + ","
            }
            
            if let landmark = txtLandmark.text,landmark.count > 0 {
                addressValue += landmark + ","
            }
            
            if let city = txtAreacity.text,city.count > 0 {
                addressValue += city + "- \(selectedPincode)"
            }
            
            
            var param: [String: Any] = [
                "title":strAddressType,
                "flatNo":txtFlatNo.text!,
                "pincode":selectedPincode,
                "landmark":txtLandmark.text!,
                "address":addressValue,
                "latitude":strLat,
                "longitude":strLong,
                "street":strStreetname,
                "area":strArea,
                "city":strCity
            ]
            
            //        http://13.126.228.76/Ironbox_new/public/api/EditAddress_phase3?
            //            AddressId= 2979&
            //            title=Home&
            //            apartment=test apratment&
            
            if(dictAddress.count != 0)
            {
                let addressID: Any
                if isForSpecialUpdate {
                    API_EDIT_ADD = "EditAddress_phase3"
                    addressID = editAddressID
                } else {
                    API_EDIT_ADD = EDIT_ADDRESS
                    addressID = dictAddress["id"] as Any
                }
                param = [
                    "title":strAddressType,
                    "flatNo":txtFlatNo.text!,
                    "landmark":txtLandmark.text!,
                    "pincode":selectedPincode,
                    "address":addressValue,
                    "latitude":strLat,
                    "longitude":strLong,
                    "AddressId":addressID,
                    "street":strStreetname,
                    "area":strArea,
                    "city":strCity
                ]
            }
            
            self.CheckNetwork()
            
            AlamofireHC.requestPOST(API_EDIT_ADD, params: param as [String : AnyObject], headers: header, success: { (JSON) in
                UIView().hideLoader(removeFrom: (self.view)!)
                let  result = JSON.dictionaryObject
                let json = result! as NSDictionary
                let err = json.value(forKey: "error") as? String ?? ""
                if (err == "false")
                {
                    let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                    let alertController = UIAlertController(title: ALERT_TITLE, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                    {
                        (result : UIAlertAction) -> Void in
                        
                        appDelegate.isNewAddressAdded = true
                        self.delegateDidUpdateLocation?.didupdateLocation(isUpdated: true)
                        self.dismiss(animated: true, completion: nil)
                        //self.performSegue(withIdentifier: "Location_EnterLocation", sender: self)
                        
                        
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                else
                {
                    let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                    self.delegateDidUpdateLocation?.didupdateLocation(isUpdated: false)
                    self.ShowAlert(msg: errorMessage)
                }
            }, failure: { (error) in
                UIView().hideLoader(removeFrom: (self.view)!)
                print(error)
            })
            
        }
        
    }
    
    @IBAction func pincodeClicked(_ sender: UIButton) {
        dropDownTextFld.isHidden = false

        var idvalues : [Int] = []
        for i in 0..<pincodeValues.count{
            idvalues.append(i)
        }
//        LoadDropDownValues(dropDown: dropDowns, data: pincodeValues, dataId: idvalues) { (selectedId) in
//
//
//        }
       

//        dropDowns.optionArray = pincodeValues
    //    dropDown.optionIds = pincodeIds
//        dropDowns.didSelect{(selectedText , index ,id) in
//       // self.valueLabel.text = "Selected String: \(selectedText) \n index: \(index)"
//        }
        dropDown.anchorView = txtAreacity //5
     //   dropDown.anchorView = searchBar
            dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)  // UIView or UIBarButtonItem
            DropDown.appearance().backgroundColor = UIColor.white
            dropDown.dataSource = pincodeValues
        dropDown.direction = .top
            dropDown.show()
            dropDown.selectionAction = { [unowned self] (index, item) in
                self.pincodeButton.setTitle(item, for: .normal)
                selectedPincode = "\(pincodeIds[index])"
                dropDownTextFld.isHidden = true

            }
    }
    @objc func myTargetFunction(textField: UITextField) {
        dropDown.anchorView = txtAreacity //5
     //   dropDown.anchorView = searchBar
           // dropDown.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)  // UIView or UIBarButtonItem
            DropDown.appearance().backgroundColor = UIColor.white
            dropDown.dataSource = pincodeValues
        dropDown.direction = .top
            dropDown.show()
            dropDown.selectionAction = { [unowned self] (index, item) in
                self.pincodeButton.setTitle(item, for: .normal)
                dropDownTextFld.text = item
                let selectingText = item

                if searchText == ""{
                    selectedPincode = "\(pincodeIds[index])"
                }else{
                    if let selected = pincodeValues.index(where: {$0 == selectingText}) {
                        let id = pincodeIds[selected]
                            didSelectCompletion(selectingText, selected , id )
                        selectedPincode = String(id)
                    }else{
                        selectedPincode == ""
                    }
                }
                                     dropDownTextFld.resignFirstResponder()

              //  dropDownTextFld.isHidden = true

            }
    }
    func setupDropDown(){
        let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
        let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
        AlamofireHC.requestPOST(GET_PINCODE3, params: nil, headers: header, success: { [unowned self] (JSON) in
        
            let  result = JSON.arrayObject
            let json = result! as NSArray
            for i in 0...json.count - 1 {
                let jsonValue = json[i] as! NSDictionary
                pincodeValues.append(jsonValue["code"] as! String + "-" + "\(jsonValue["area"] as! String)")
                pincodeIds.append(Int(jsonValue["code"] as! String) ?? 0)
            }
            DispatchQueue.main.async {
                self.pincodeButton.setTitle(pincodeValues[0], for: .normal)
                dropDownTextFld.text = pincodeValues[0]
            }
            
        }, failure: { (error) in
            print(error)
        })
    }
    
    //MARK: - Pincode DROPDOWN
    
//    func LoadDropDownValues(dropDown:DropDown,data:[String],dataId:[Int],completion:@escaping (Int) -> ()) {
//
////            dropDown.textColor = UIColor.black
////            dropDown.selectedRowColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1.0)
////            dropDown.optionArray = data
////            dropDown.optionIds = dataId
//////            dropDown.text = data[0]
//////            self.customerTypeId = String(dataId[0])
////            dropDown.didSelect{(selectedText , index ,id) in
////                completion(id)
////                dropDown.text = selectedText
////
////            }
//        }
//
//    }
    
    // MARK: - LAT LONG TO PHYSICAL ADDRESS
    func getAddressFromLatLong(_ locat: CLLocationCoordinate2D)
    {
        let reverseGeoCoder = GMSGeocoder()
        //  let coordinate = manager.location?.coordinate
        reverseGeoCoder.reverseGeocodeCoordinate(locat, completionHandler: {(placeMark, error) -> Void in
            if error == nil {
                if let placeMarkObject = placeMark
                {
                    //  print(placeMarkObject.results()!)
                    let addressCount = placeMarkObject.results()?.count
                    if addressCount != 0
                    {
                      
                        self.lblAddress.text = self.strAddrLine
                        self.strFlatno = placeMarkObject.firstResult()?.thoroughfare ?? ""
                        self.txtFlatNo.text = self.strFlatno
                        //                        self.strLandmark = placeMarkObject.firstResult()?.postalCode ?? ""
                        //                        self.txtLandmark.text = self.strLandmark
                        //                        self.strApartmentname = placeMarkObject.firstResult()?.postalCode ?? ""
                        //                        self.txtApartmentname.text = self.strApartmentname
                        self.strStreetname = placeMarkObject.firstResult()?.thoroughfare ?? ""
                        self.txtStreetname.text = self.strStreetname
                        let strArea = placeMarkObject.firstResult()?.subLocality ?? ""
                        let strCity = placeMarkObject.firstResult()?.locality ?? ""
                        let strState = placeMarkObject.firstResult()?.administrativeArea ?? ""
                        self.strArea = strArea
                        self.strCity = strCity
                        self.txtAreacity.text = strArea + "," + strCity
                        self.strAddrLine = self.strFlatno + strArea + strCity + strState
                    }
                }
                else
                {
                    //Do Nothing
                }
            } else {
                print(error?.localizedDescription)
            }
        })
    }
    
    /*  func mapView(_ mapView: GMSMapView, willMove gesture: Bool)
     {
     print("yes")
     UIView.animate(withDuration: 0.2, animations: {
     self.viewGoogleMap.frame.size.height = (self.height/10) * 7.5
     self.viewAddress.frame.origin.y =  self.viewGoogleMap.frame.origin.y + self.viewGoogleMap.frame.size.height
     self.viewAddress.transform = CGAffineTransform(scaleX: 1, y: 1)
     self.viewGoogleMap.transform = CGAffineTransform(scaleX: 1, y: 1)
     self.markerCenter.center.y = self.viewGoogleMap.center.y - 15
     self.markerCenter.transform = CGAffineTransform(scaleX: 1, y: 1)
     }) { (finished) in
     UIView.animate(withDuration: 0.4, animations: {
     self.viewGoogleMap.transform = CGAffineTransform.identity
     self.viewAddress.transform = CGAffineTransform.identity
     self.markerCenter.transform = CGAffineTransform.identity
     })
     }
     } */
    
    // MARK: - MAP VIEW DELEGATE
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition)
    {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        strLat = String(latitude)
        strLong = String(longitude)
        let centerMapCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.getAddressFromLatLong(centerMapCoordinate)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //        let latitude = mapView.camera.target.latitude
        //        let longitude = mapView.camera.target.longitude
        //        print(latitude)
        //        print(longitude)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Location manager
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 15.5)
        
        viewGoogleMap?.animate(to: camera)
        
        
        let strCurrLat =  (manager.location?.coordinate.latitude)!
        let strCurrLong =  (manager.location?.coordinate.longitude)!
        let defaults = UserDefaults.standard
        defaults.set(strCurrLat, forKey: CUR_LATITUDE)
        defaults.set(strCurrLong, forKey: CUR_LONGITUDE)
        defaults.synchronize()
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
        self.locationManager.delegate = nil
        
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("%@",error);
        let userDefault = UserDefaults.standard
        
        if userDefault.object(forKey: CUR_LATITUDE)  != nil
        {
            let strCurrLat = userDefault.object(forKey: CUR_LATITUDE) as! Double
            let strCurrLong = userDefault.object(forKey: CUR_LONGITUDE) as! Double
            
            let camera = GMSCameraPosition.camera(withLatitude: strCurrLat, longitude: strCurrLong, zoom: 15.5)
            
            viewGoogleMap?.animate(to: camera)
            
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            // If authorized when in use
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            // If always authorized
            manager.startUpdatingLocation()
            break
        case .restricted:
            // If restricted by e.g. parental controls. User can't enable Location Services
            ToastCenter.default.cancelAll()
            Toast(text: "Please enable location service", duration: 2.5).show()
            let appearance = ToastView.appearance()
            appearance.backgroundColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 0.80)
            appearance.textColor = UIColor.white
            appearance.font = UIFont(name: FONT_REG, size: 15)
            appearance.textInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            appearance.bottomOffsetPortrait = 50
            appearance.cornerRadius = 15
            break
        case .denied:
            // If user denied your app access to Location Services, but can grant access from Settings.app
            ToastCenter.default.cancelAll()
            Toast(text: "Please enable location service", duration: 2.5).show()
            let appearance = ToastView.appearance()
            appearance.backgroundColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 0.80)
            appearance.textColor = UIColor.white
            appearance.font = UIFont(name: FONT_REG, size: 15)
            appearance.textInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            appearance.bottomOffsetPortrait = 50
            appearance.cornerRadius = 15
            break
            
        }
    }
    
    // MARK: - TEXT FIELD DELEGATE
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if textField == dropDownTextFld{
            if string != "" {
                self.searchText = textField.text! + string
            }else{
                let subText = textField.text?.dropLast()
                self.searchText = String(subText!)
            }
        }
        return true
    }
  
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
  
    // MARK: - GOOGLE PLACES
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace)
    {
        //        print("Place name: \(place.coordinate)")
        //        print("Place address: \(place.formattedAddress)")
        //        print("Place attributions: \(place.attributions)")
        
        dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        {
            let camera = GMSCameraPosition.camera(withLatitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude), zoom: 15.5)
            self.viewGoogleMap?.animate(to: camera)
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error)
    {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
//   func LoadDropDownValues(dropDown:DropDowns,data:[String],dataId:[Int],completion:@escaping (Int) -> ()) {
//           DispatchQueue.main.async {
//               dropDown.textColor = UIColor.black
//               dropDown.selectedRowColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1.0)
//               dropDown.optionArray = data
//               dropDown.optionIds = dataId
//               dropDown.text = data[0]
//               dropDown.didSelect{(selectedText , index ,id) in
//                   completion(id)
//                   dropDown.text = selectedText
//
//               }
//           }
//   }
    
}



