//
//  Constants.swift
//  Spector&Co
//
//  Created by veena on 7/10/17.
//  Copyright © 2017 Pyramidions Solution. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration


// MARK: - Development Url
/*
 var BASEURL = "http://139.59.37.241/Ironman/public/api/apv2/"
var TERMSCONDS_URL = "http://139.59.37.241/Ironman/public/UserTerms"
var PRIVACY_URL = "http://139.59.37.241/Ironman/public/UserPrivacy"
var REFUND_URL = "http://139.59.37.241/Ironman/public/Refunds"
var DISCLAIMER_URL = "http://139.59.37.241/Ironman/public/Disclaimer"
*/


// MARK: - Production Url

var BASEURL = "http://13.126.228.76/Ironbox_new/public/api/"
var TERMSCONDS_URL = "http://13.126.228.76/Ironbox_new/public/UserTerms"
var PRIVACY_URL = "http://13.126.228.76/Ironbox_new/public/UserPrivacy"
var REFUND_URL = "http://13.126.228.76/Ironbox_new/public/Refunds"
var DISCLAIMER_URL = "http://13.126.228.76/Ironbox_new/public/Disclaimer"


// MARK: - AppStore Url
var APP_STORE_URL = "https://itunes.apple.com/in/app/ironbox/id1396394518?ls=1&mt=8&refercode="
var PLAY_STORE_URL = "https://play.google.com/store/apps/details?id=com.zerodegreesouth.Ironbox"

// MARK: - Urls and Keys
var FACEBOOK_URL = "https://www.facebook.com/IronBoxChennai/"
var INSTAGRAM_URL = "https://www.instagram.com/ironbox_chn/"


// MARK: - Amazon
var PROFILE_BUCKET_NAME = "ironboxapp/UserProfileImage"
var AMAZON_S3_IDENTITY_POOL_ID = "ap-south-1:3c6ed2c9-9e7f-4696-8148-9379c047c99e"
var PROFILE_IMG_BASE_URL = "https://s3.ap-south-1.amazonaws.com/ironboxapp/UserProfileImage/"

// MARK: - Google API
let GoogleBaseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
var GOOGLE_MAP_API = "AIzaSyAgMdhqiXHgSsDoPCvq7JLw6QRAG9vw5SI"
var GOOGLE_PALCES_API = "AIzaSyAJYxekPrR1LXlmWiOzrHoshgjrJNbP-54"


// MARK: - Paytm Production
var MERCHANT_ID = "zerode40008007001297"
var WEBSITE = "APPPROD"
var INDUSTRYTYPEID = "Retail109"
var CHANNELID = "WAP"
var CALLBACKURL = "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID="
var GENERATE_CHECKSUM_URL = "GenerateCheckSum"
var VALIDATE_CHECKSUM_URL = "VerifyChecksum"
var SERVER_TYPE = "eServerTypeProduction"

 // MARK: - Paytm STAGING
// var MERCHANT_ID = "zerode85029715802139"
// var WEBSITE = "APPSTAGING" // APP_STAGING
// var INDUSTRYTYPEID = "Retail"
// var CHANNELID = "WAP"
// var CALLBACKURL = "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID="
// var GENERATE_CHECKSUM_URL = "GenerateCheckSum"
// var VALIDATE_CHECKSUM_URL = "VerifyChecksum"
// var SERVER_TYPE = "eServerTypeStaging"


// MARK: - API Methods
var LOGIN = "UserLogin"
var RESEND_OTP = "ResentOtp"
var LOGOUT = "logout"
var CHECK_OTP = "UserCheckOpt"
var EDIT_USER_PROFILE = "EditUserProfile"
var GET_ADDRESS = "GetAddress"
var GET_TIMESLOTS = "GetTimeSlots"
var ADD_ADDRESS = "AddAddresses"
var USER_BOOKING = "UserBooking"
var USER_CURRENT_ORDER_LIST = "UserOrderList"
var BOOKING_HISTORY = "BookingHistory"
var DELETE_ADDRESS = "DeleteAddress"
var EDIT_ADDRESS = "EditAddress"
var GET_RATECARD = "RateCard"
var GET_USERDETAILS = "UserDetails"
var SEND_FEEDBACK = "CustomerSupport"
var ABOUT_US = "ContentPages"
var CENCEL_REASON = "CancelReason"
var CANCEL_ORDER = "OrderCancel"
//var VIEW_BILLING_DETAILS = "ViewItems"
var VIEW_BILLING_DETAILS = "ViewItems_phase3"
var HOME_API = "Home"
var RATING = "Rating"
var GET_PINCODE = "Pincode"
var CHECK_PINCODE = "CheckPincode"
var ADD_AMOUNT_WALLET = "AddWalletRazorPay"         // "AddWallet"
var GET_AMOUNT_WALLET = "WalletAmount"
var GET_TRANSACTIONS_WALLET = "WalletTransaction"
var CANCELLED_TRANSACTION = "CancelledTrasaction"
var GET_ORDERID = "GetOrderId"
var GET_OFFERS = "UserPromocode"
var CARD_PAYMENT = "CardPayment"
var WALLET_PAYMENT = "WalletPayment"
var VALIDATE_OFFERS = "ValidPromocode"
var GET_PACKAGES = "Packages"
var PAYMENT_PACKAGES = "packagesPayment"
var GET_MY_PACKAGES = "MyPackages"
var MY_PACKAGE_TRANSACTIONS = "MyPackageTransactions"
var ON_CLICK_BOOKING = "OneClickBooking"
//var MY_PACKAGE_TRANSACTIONS = "MyPackageTransactions"


// MARK: - KeyWords
let ALERT_TITLE = "Ironbox"
let IS_LOGIN = "IsLogin"
let USER_MOBILE = "USER_MOBILE"
let USER_ALTERNATE_MOBILE = "USER_ALTERNATE_MOBILE"
let USER_ID = "USER_ID"
let USER_NAME = "USER_NAME"
let USER_EMAIL = "USER_EMAIL"
let USER_GENDER = "USER_GENDER"
let USER_DOB = "USER_DOB"
let USER_REFERAL_CODE = "USER_REFERAL_CODE"
let USER_PROFILE_IMAGE = "USER_PROFILE_IMAGE"
let CUR_LATITUDE = "CURRENT LATITUDE"
let CUR_LONGITUDE = "CURRENT LONGITUDE"
let IS_HOME_TUTORIAL_SHOWN = "IS_HOME_TUTORIAL_SHOWN"
let IS_ONGOING_TUTORIAL_SHOWN = "IS_ONGOING_TUTORIAL_SHOWN"
let IS_HISTORY_TUTORIAL_SHOWN = "IS_HISTORY_TUTORIAL_SHOWN"
let IS_ADDADDRESS_TUTORIAL_SHOWN = "IS_ADDADDRESS_TUTORIAL_SHOWN"
let IS_RATINGS_TUTORIAL_SHOWN = "IS_RATINGS_TUTORIAL_SHOWN"
let ACCESS_TOKEN = "ACCESS_TOKEN"
let REFERRAL_AMOUNT = "REFERRAL_AMOUNT"
let USER = "USER"
let AMOUNT = "AMOUNT"

// MARK: - Font
var FONT_BOLD = "Quicksand-Bold"
var FONT_MEDIUM = "Quicksand-Medium"
var FONT_REG = "Quicksand-Regular"
var FONT_LIGHT = "Quicksand-Light"

//var FONT_EXTRALIGHT = "Quicksand-Extralight"

// MARK: - Basic Functions
func UserDefaults_Obj() -> UserDefaults
{
    
    let userDefaults = UserDefaults.standard
    return userDefaults
}
func Appdelegate_Obj() -> AppDelegate
{
    let delegate = UIApplication.shared.delegate as! AppDelegate
    return delegate
}

struct UI<V: UIView>: UIViewRepresentable { //hu
    let content: () -> V
    let update: ((V) -> ())?
    
    init(content: @escaping () -> V, update: ((V) -> Void)? = nil) {
        self.content = content
        self.update = update
    }
    
    func makeUIView(context: Context) -> V {
        content()
    }
    
    func updateUIView(_ uiView: V, context: Context) {
        update?(uiView)
    }
}

func uiView() -> UIView {
    let controller = UIHostingController(rootView: self)
    controller.view.translatesAutoresizingMaskIntoConstraints = false
    controller.view.backgroundColor = .clear
    controller.view.insetsLayoutMarginsFromSafeArea = false
    return controller.view
}