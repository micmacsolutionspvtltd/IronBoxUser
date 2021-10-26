//
//  SingleTonClass.swift
//  Spector&Co
//
//  Created by Pyramidions Solution on 23/02/17.
//  Copyright © 2017 Pyramidions Solution. All rights reserved.
//

import UIKit
import Reachability
import Toaster
import UserNotifications
import Foundation

var activeField: UITextField?
var  animatedDistance: CGFloat!

// MARK: - Keyboard
let KEYBOARD_ANIMATION_DURATION: CGFloat = 0.3
let MINIMUM_SCROLL_FRACTION: CGFloat = 0.2
let MAXIMUM_SCROLL_FRACTION: CGFloat = 0.8
let PORTRAIT_KEYBOARD_HEIGHT: CGFloat = 216
let LANDSCAPE_KEYBOARD_HEIGHT: CGFloat = 162
let appDelegate = UIApplication.shared.delegate as! AppDelegate
// var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
let userDefaults = UserDefaults.standard

struct ScreenSize {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let frame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)
    static let maxWH = max(ScreenSize.width, ScreenSize.height)
}

struct DeviceType {
    static let iPhone4orLess  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxWH < 568.0
    static let iPhone5orSE    = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxWH == 568.0
    static let iPhone678      = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxWH == 667.0
    static let iPhone678p     = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxWH == 736.0
    static let iPhoneX        = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.maxWH == 812.0
}

class SingleTonClass: NSObject
{
   let firstname : String = "abcd"
}
// MARK: - Extension Font
extension UIFont {
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    var isItalic: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitItalic)
    }
}

// MARK: - Extension NSMutableAttributedString
extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        self.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
    }
    
}

// MARK: - Extension UIImageView
extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }}

// MARK: - Extension UIView
extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    func addDashedLine(strokeColor: UIColor, lineWidth: CGFloat) {
        
        backgroundColor = .clear
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "DashedBottomLine"
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: 0 , y: frame.height)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [14, 4]
        
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: frame.width, y: 0))
        shapeLayer.path = path
        
        layer.addSublayer(shapeLayer)
    }
    
    func customActivityIndicator(view: UIView, widthView: CGFloat?, message: String?) -> UIView{
        
        //Config UIView
        let screenSize: CGRect = UIScreen.main.bounds
        self.frame = CGRect(x: 0, y: 0, width: screenSize.width , height: screenSize.height)
        self.backgroundColor = UIColor(red: 18/255, green: 24/255, blue: 38/255, alpha: 0.852)
        self.tag = 454665
        
        let loopImages = UIImageView()
         loopImages.frame = CGRect(x: (screenSize.width / 2) - 30, y: (screenSize.height / 2) - 50, width: 60 , height: 60)
        self.addSubview(loopImages)
        let loader = UIImage.gif(name: "LoaderNew")
        loopImages.animationImages = loader?.images
        loopImages.startAnimating()
        
      /*  let imageListArray = [UIImage(named: "Address Menu"), UIImage(named: "Aboutus")] // Put your desired array of images in a specific order the way you want to display animation.
        
        loopImages.animationImages = imageListArray as? [UIImage]
        loopImages.animationDuration = TimeInterval(0.8)
        loopImages.startAnimating() */
        
        //ConfigureLabel
        let label = UILabel()
        label.frame = CGRect(x: 10, y: (screenSize.height / 2 + 15), width: screenSize.width - 20, height: 25)
        label.textAlignment = .center
        label.font = UIFont(name: FONT_MEDIUM, size: 15.0)!
        label.numberOfLines = 1
        label.text = message ?? ""
        label.textColor = UIColor.white
       // self.addSubview(label)
       
        return self
        
    }
    
    func hideLoader(removeFrom : UIView)
    {
        if removeFrom.subviews.last?.tag == 454665
        {
           removeFrom.subviews.last?.removeFromSuperview()
        }
        
    }
    
}

// MARK: - Extension Data
extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

// MARK: - Extension String
extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

// MARK: - Extension UILabel
extension UILabel {
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }
    
    public var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        if let insets = padding {
            self.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        } else {
            self.drawText(in: rect)
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        guard let text = self.text else { return super.intrinsicContentSize }
        
        var contentSize = super.intrinsicContentSize
        var textWidth: CGFloat = frame.size.width
        var insetsHeight: CGFloat = 0.0
        
        if let insets = padding {
            textWidth -= insets.left + insets.right
            insetsHeight += insets.top + insets.bottom
        }
        
        let newSize = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                        attributes: [NSAttributedStringKey.font: self.font], context: nil)
        
        contentSize.height = ceil(newSize.size.height) + insetsHeight
        
        return contentSize
    }
}

// MARK: - Extension UITextField
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

// MARK: - Extension UIButton
extension UIButton {
    
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
    func flash() {
        
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 1
        
        layer.add(flash, forKey: nil)
    }
    
    
    func shake() {
        
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: "position")
    }
}

// MARK: - Extension UIColor
extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
    @objc class var AppThemeColor: UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "AppThemeColor")!
        } else {
            return UIColor(hexString: "#1A3C5C")
        }
    }
    
}

// MARK: - Extension UIDevice
extension UIDevice {
        var modelName: String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator"
            default:                                        return identifier
            }
        }
        
    
}

// MARK: - Extension UIViewController
extension UIViewController {
   
    // MARK: - Alert / Toast
    func ShowAlert(msg:String)
    {
        ToastCenter.default.cancelAll()
        Toast(text: msg, duration: 2.5).show()
        let appearance = ToastView.appearance()
        appearance.backgroundColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 0.80)
        appearance.textColor = UIColor.white
        appearance.font = UIFont(name: FONT_REG, size: 15)
        appearance.textInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        appearance.bottomOffsetPortrait = 50
        appearance.cornerRadius = 15
        
       /* let alert = UIAlertController(title: ALERT_TITLE, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (result : UIAlertAction) -> Void in
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil) */
        
    }
    
    // MARK: - Email Validation
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }

    
    // MARK: - NetWork Finder
    @discardableResult
    func CheckNetwork() -> Bool
    {
        let reachability = try! Reachability()
        
        if reachability.connection != .unavailable
        {
            return true
           print("Network reachable")
        }
        else
        {
            ToastCenter.default.cancelAll()
            Toast(text: "Please check your internet connection", duration: 2.5).show()
            let appearance = ToastView.appearance()
            appearance.backgroundColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 0.80)
            appearance.textColor = UIColor.white
            appearance.font = UIFont(name: FONT_REG, size: 15)
            appearance.textInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            appearance.bottomOffsetPortrait = 50
            appearance.cornerRadius = 15
            print("Network not reachable")
            return false
        }
        
    }
   
    // MARK: - Hide KeyBoard
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
   
    
    
    // MARK: - Clear UserDefaults
    func ClearData()
    {
//        let defaults = UserDefaults.standard
//        defaults.set("", forKey: ACESS_TOKEN)
//        defaults.synchronize()
    }
    
    // MARK: - Change Font For Whole App
    func setFontFamilyAndSize()
    {

    /*   // UILabels Navigation Controller
        let Navlabels = getLabelsInView(view: (self.navigationController?.view)!)
        print(UIDevice.current.modelName)
         for Navlabel in Navlabels
         {
            switch (UIDevice.current.modelName) {
            case "iPhone 4",
                 "iPhone 4s",
                 "iPhone 5",
                 "iPhone 5c",
                 "iPhone 5s",
                 "iPhone SE" :
                Navlabel.font = Navlabel.font.withSize(Navlabel.font.pointSize - 2)
                break
            case "iPhone 6",
                 "iPhone 8",
                 "iPhone 7",
                  "iPhone 6s" :
                Navlabel.font = Navlabel.font.withSize(Navlabel.font.pointSize)
                break
            case
                 "iPhone 6 Plus",
                 "iPhone 6s Plus",
                 "iPhone 7 Plus",
                 "iPhone 8 Plus",
                 "iPhone X" :
                Navlabel.font = Navlabel.font.withSize(Navlabel.font.pointSize + 2)
                break
            case
            "Simulator" :
                Navlabel.font = Navlabel.font.withSize(Navlabel.font.pointSize)
                break
            default:
                Navlabel.font = Navlabel.font.withSize(Navlabel.font.pointSize + 3)
            }

         }

*/
    // UILabels
    let labels = getLabelsInView(view: self.view)
    for label in labels
    {
        switch (UIDevice.current.modelName) {
        case "iPhone 4",
             "iPhone 4s",
             "iPhone 5",
             "iPhone 5c",
             "iPhone 5s",
             "iPhone SE" :
            label.font = label.font.withSize(label.font.pointSize - 2)
            break
        case "iPhone 6",
             "iPhone 8",
             "iPhone 7",
             "iPhone 6s" :
            label.font = label.font.withSize(label.font.pointSize)
            break
        case
        "iPhone 6 Plus",
        "iPhone 6s Plus",
        "iPhone 7 Plus",
        "iPhone 8 Plus",
        "iPhone X" :
            label.font = label.font.withSize(label.font.pointSize + 2)
            break
        case
        "Simulator" :
            label.font = label.font.withSize(label.font.pointSize)
            break
        default:
            label.font = label.font.withSize(label.font.pointSize + 3)
        }
    }


    // UIButton
    let buttons = getButtonsInView(view: self.view)
    for button in buttons
    {

        switch (UIDevice.current.modelName) {
        case "iPhone 4",
             "iPhone 4s",
             "iPhone 5",
             "iPhone 5c",
             "iPhone 5s",
             "iPhone SE" :
            button.titleLabel!.font = button.titleLabel!.font.withSize(button.titleLabel!.font.pointSize - 2)
            break
        case "iPhone 6",
             "iPhone 8",
             "iPhone 7",
             "iPhone 6s" :
            button.titleLabel!.font = button.titleLabel!.font.withSize(button.titleLabel!.font.pointSize)
            break
        case
        "iPhone 6 Plus",
        "iPhone 6s Plus",
        "iPhone 7 Plus",
        "iPhone 8 Plus",
        "iPhone X" :
            button.titleLabel!.font = button.titleLabel!.font.withSize(button.titleLabel!.font.pointSize + 2)
            break
        case
        "Simulator" :
            button.titleLabel!.font = button.titleLabel!.font.withSize(button.titleLabel!.font.pointSize)
            break
        default:
            button.titleLabel!.font = button.titleLabel!.font.withSize(button.titleLabel!.font.pointSize + 3)
        }
    }


    // UITextFields
    let textFields = getTextFieldsInView(view: self.view)
    for textField in textFields
    {
        switch (UIDevice.current.modelName) {
        case "iPhone 4",
             "iPhone 4s",
             "iPhone 5",
             "iPhone 5c",
             "iPhone 5s",
             "iPhone SE" :
            textField.font = textField.font?.withSize((textField.font?.pointSize)! - 2)
            break
        case "iPhone 6",
             "iPhone 8",
             "iPhone 7",
             "iPhone 6s" :
            textField.font = textField.font?.withSize((textField.font?.pointSize)!)
            break
        case
        "iPhone 6 Plus",
        "iPhone 6s Plus",
        "iPhone 7 Plus",
        "iPhone 8 Plus",
        "iPhone X" :
            textField.font = textField.font?.withSize((textField.font?.pointSize)! + 2)
            break
        case
        "Simulator" :
            textField.font = textField.font?.withSize((textField.font?.pointSize)!)
            break
        default:
            textField.font = textField.font?.withSize((textField.font?.pointSize)! + 3)
        }

    }


    // UITextView
    let textViews = getTextViewsInView(view: self.view)
    for textView in textViews
    {
        switch (UIDevice.current.modelName) {
        case "iPhone 4",
             "iPhone 4s",
             "iPhone 5",
             "iPhone 5c",
             "iPhone 5s",
             "iPhone SE" :
            textView.font = textView.font?.withSize((textView.font?.pointSize)! - 2)
            break
        case "iPhone 6",
             "iPhone 8",
             "iPhone 7",
             "iPhone 6s" :
            textView.font = textView.font?.withSize((textView.font?.pointSize)!)
            break
        case
        "iPhone 6 Plus",
        "iPhone 6s Plus",
        "iPhone 7 Plus",
        "iPhone 8 Plus",
        "iPhone X" :
            textView.font = textView.font?.withSize((textView.font?.pointSize)! + 2)
            break
        case
        "Simulator" :
            textView.font = textView.font?.withSize((textView.font?.pointSize)!)
            break
        default:
            textView.font = textView.font?.withSize((textView.font?.pointSize)! + 3)
        }
    }
    
}
    
    // MARK: - Date to milliseconds
    func currentTimeInMiliseconds(date: Date) -> CLongLong  {
        // let currentDate = Date()
        let since1970 = date.timeIntervalSince1970
        return CLongLong(Int(since1970 * 1000))
    }
    
   // MARK: - Milliseconds to date
    func dateFromMilliseconds(milliSeconds: CLongLong) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(milliSeconds)/1000)
    }
    
    
    // MARK: - TextField Delegate
   @objc func textFieldDidBeginEditing(_ textField: UITextField)
    {
        let textFieldRect = self.view.window!.convert(textField.bounds, from: textField)
        let viewRect = self.view.window!.convert(self.view.bounds, from: self.view)
        let midline: CGFloat = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
        let numerator: CGFloat = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height
        let denominator: CGFloat = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height
        var heightFraction: CGFloat = numerator / denominator
        if heightFraction < 0.0 {
            heightFraction = 0.0
        }
        else if heightFraction > 1.0 {
            heightFraction = 1.0
        }
        
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == .portrait || orientation == .portraitUpsideDown {
            animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction)
        }
        else {
            animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction)
        }
        var viewFrame = self.view.frame
        viewFrame.origin.y -= animatedDistance
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(KEYBOARD_ANIMATION_DURATION))
        self.view.frame = viewFrame
        UIView.commitAnimations()
        
        let OtpBiginEditing = Notification.Name("OTPVerificationBeginEditing")
        NotificationCenter.default.post(name: OtpBiginEditing, object: textField)
        
    }
    @objc func textFieldDidEndEditing(_ textfield: UITextField) {
        var viewFrame = self.view.frame
        viewFrame.origin.y += animatedDistance
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(KEYBOARD_ANIMATION_DURATION))
        self.view.frame = viewFrame
        UIView.commitAnimations()
        
        let OtpEndEditing = Notification.Name("OTPVerificationEndEditing")
        NotificationCenter.default.post(name: OtpEndEditing, object: nil)
    }
 
    // MARK: - Font Change
    func getLabelsInView(view: UIView) -> [UILabel] {
        var results = [UILabel]()
        for subview in view.subviews as [UIView] {
            if let labelView = subview as? UILabel {
                results += [labelView]
            } else {
                results += getLabelsInView(view: subview)
            }
        }
        return results
    }
    
    func getButtonsInView(view: UIView) -> [UIButton] {
        var results = [UIButton]()
        for subview in view.subviews as [UIView] {
            if let buttonView = subview as? UIButton {
                results += [buttonView]
            } else {
                results += getButtonsInView(view: subview)
            }
        }
        return results
    }
    
    func getTextFieldsInView(view: UIView) -> [UITextField] {
        var results = [UITextField]()
        for subview in view.subviews as [UIView] {
            if let txtField = subview as? UITextField {
                results += [txtField]
            } else {
                results += getTextFieldsInView(view: subview)
            }
        }
        return results
    }

    func getTextViewsInView(view: UIView) -> [UITextView] {
        var results = [UITextView]()
        for subview in view.subviews as [UIView] {
            if let txtView = subview as? UITextView {
                results += [txtView]
            } else {
                results += getTextViewsInView(view: subview)
            }
        }
        return results
    }

}




/*   let fontFamilyNames = UIFont.familyNames
 for familyName in fontFamilyNames {
 print("------------------------------")
 print("Font Family Name = [\(familyName)]")
 let names = UIFont.fontNames(forFamilyName: familyName)
 print("Font Names = [\(names)]")
 } */


