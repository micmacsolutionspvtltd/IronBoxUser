//
//  RatingsVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 17/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Cosmos
import Alamofire
import NVActivityIndicatorView

class RatingsVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var txtVwFeedback: UITextView!
    @IBOutlet weak var pickupRating: CosmosView!
    @IBOutlet weak var serviceRating: CosmosView!
    @IBOutlet weak var deliveryRating: CosmosView!
    
    var ViewTutorial = UIView()
    var ImgTutorial = UIImageView()
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setFontFamilyAndSize()
        self.hideKeyboardWhenTappedAround()
        txtVwFeedback.delegate = self
        pickupRating.rating = 0
        serviceRating.rating = 0
        deliveryRating.rating = 0
        
        txtVwFeedback.text = "Type your comments(optional)"
        txtVwFeedback.textColor = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0)
        self.txtVwFeedback.layer.borderWidth = 1
        self.txtVwFeedback.layer.borderColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:0.43).cgColor
        self.txtVwFeedback.layer.masksToBounds = true
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        if ((userDefaults.value(forKey: IS_RATINGS_TUTORIAL_SHOWN) as? String) == nil)
        {
            self.showTutorialScreen()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews()
    {
        
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
        ImgTutorial.image = UIImage(named:"TutoRatings1")
        ViewTutorial.addSubview(ImgTutorial)
        
        let btnNxt:UIButton = UIButton(frame:  CGRect(x: screenSize.width - 100, y: screenSize.height - 50, width: 100, height: 50))
        btnNxt.backgroundColor = UIColor.clear
        btnNxt.addTarget(self, action: #selector(self.onTutorialNext(_:)), for:.touchUpInside)
        ViewTutorial.addSubview(btnNxt)
    }
    @IBAction func onTutorialNext(_ sender: Any)
    {
        userDefaults.set("yes", forKey: IS_RATINGS_TUTORIAL_SHOWN)
        ViewTutorial.removeFromSuperview()
    }
    
    // MARK: - ACTIONS
    @IBAction func ClickonCloseBtn(_ sender: Any)
    {
       self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onRate(_ sender: Any)
    {
        if pickupRating.rating == 0
        {
            ShowAlert(msg: "Please provide ratings for pickup")
        }
        else  if serviceRating.rating == 0
        {
            ShowAlert(msg: "Please provide ratings for service")
        }
        else  if deliveryRating.rating == 0
        {
            ShowAlert(msg: "Please provide ratings for delivery")
        }
        else
        {
            view.endEditing(true)
            self.view.addSubview(UIView().customActivityIndicator(view: (self.view)!, widthView: nil, message: "Loading"))
            
            let accessToken = userDefaults.object(forKey: ACCESS_TOKEN)
            let header:HTTPHeaders = ["Accept":"application/json", "Authorization":accessToken as! String]
            
            var strComments = ""
            if txtVwFeedback.text == "Type your comments(optional)" || (txtVwFeedback.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!
            {
                strComments = ""
            }
            else
            {
                strComments = txtVwFeedback.text!
            }
            
            
            
            let ID = appDelegate.dictServiceSuccess["userBookId"]
            let strBookingID = String(describing: ID!)
            
            let strPickupRating = String(describing: pickupRating.rating)
            let strServiceRating = String(describing: serviceRating.rating)
            let strDeliveryRating = String(describing: deliveryRating.rating)
            
            let param: [String: Any] = [
                "PickupRate":strPickupRating,
                "ServiceRate":strServiceRating,
                "DeliveryRate":strDeliveryRating,
                "bookingId":strBookingID,
                "Comments": strComments
                
            ]
            self.CheckNetwork()
            
            AlamofireHC.requestPOST(RATING, params: param as [String : AnyObject], headers: header, success: { (JSON) in
                UIView().hideLoader(removeFrom: (self.view)!)
                let  result = JSON.dictionaryObject
                let json = result! as NSDictionary
                
                let err = json.value(forKey: "error") as? String ?? ""
                if (err == "false")
                {
                    appDelegate.IsfromRatingsVC = true
                    self.dismiss(animated: true, completion: nil)
                }
                else
                {
                    let errorMessage = json.value(forKey: "error_message")as? String ?? ""
                    self.ShowAlert(msg: errorMessage)
                }
                
                
            }, failure: { (error) in
                UIView().hideLoader(removeFrom: (self.view)!)
                print(error)
            })
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
    
    // MARK: - TextView Delegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return numberOfChars < 500;
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0) {
            textView.text = nil
            textView.textColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha:1)
        }
        
        //move textfields up
        let myScreenRect: CGRect = UIScreen.main.bounds
        let keyboardHeight : CGFloat = 230
        
        UIView.beginAnimations( "animateView", context: nil)
        var movementDuration:TimeInterval = 0.35
        var needToMove: CGFloat = 0
        
        var frame : CGRect = self.view.frame
        if (textView.frame.origin.y + textView.frame.size.height + UIApplication.shared.statusBarFrame.size.height > (myScreenRect.size.height - keyboardHeight - 30)) {
            needToMove = (textView.frame.origin.y + textView.frame.size.height + UIApplication.shared.statusBarFrame.size.height) - (myScreenRect.size.height - keyboardHeight - 30);
        }
        
        frame.origin.y = -needToMove
        self.view.frame = frame
        UIView.commitAnimations()
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || (textView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!
        {
            txtVwFeedback.text = "Type your comments(optional)"
            textView.textColor = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0)
        }
        //move textfields back down
        UIView.beginAnimations( "animateView", context: nil)
        var movementDuration:TimeInterval = 0.35
        var frame : CGRect = self.view.frame
        frame.origin.y = 0
        self.view.frame = frame
        UIView.commitAnimations()
    }

}
