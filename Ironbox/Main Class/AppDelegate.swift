//
//  AppDelegate.swift
//  Ironbox
//
//  Created by Gopalsamy A on 22/03/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
//import CoreData
import GoogleMaps
import GooglePlaces
import Firebase
import UserNotifications
import AWSCore
import AWSCognito
import AWSS3
import FBSDKCoreKit
import SwiftUI





@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var isNewAddressAdded:Bool = false
    var isEditingAddress:Bool = false
    var dictServiceSuccess = Dictionary<String,Any>()
    var dictPaymentSuccess = Dictionary<String,Any>()
    var IsfromRatingsVC:Bool = false
    var IsNewRegistration:Bool = false
    var IsfromLogout:Bool = false
    var IsfromPackageConfirmation:Bool = false
    var strOfferCode = ""
    var strOfferType = ""
    var arrPaytmRsponse = Array<Any>()
    var strUpdateMsg = ""
   // var userInfo = NSDictionary()
    
    
    // MARK: - App
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        window?.rootViewController = UIHostingController(rootView: BookingConfirmationAlertView(onOkay: {}, onCancel: {}))
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(GOOGLE_MAP_API)
        GMSPlacesClient.provideAPIKey(GOOGLE_PALCES_API)
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()

        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        AppEvents.shared.activateApp()
        Settings.shared.isAutoLogAppEventsEnabled = true
        UserDefaults.standard.set("true", forKey: "enterFirstTime")
//
        guard let gai = GAI.sharedInstance() else {
            assert(false, "Google Analytics not configured correctly")
            return true//Base on your function return type, it may be returning something else
        }
        gai.tracker(withTrackingId: "UA-124352220-1")
        // Optional: automatically report uncaught exceptions.
        gai.trackUncaughtExceptions = true
        
        // Optional: set Logger to VERBOSE for debug information.
        // Remove before app release.
        gai.logger.logLevel = .verbose;
        
        UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 2

        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.APSouth1,
                                                                identityPoolId:AMAZON_S3_IDENTITY_POOL_ID)
        let configuration = AWSServiceConfiguration(region:.APSouth1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        if ((userDefaults.value(forKey: IS_LOGIN) as? String) == "yes")
        {
//            self.window = UIWindow(frame: UIScreen.main.bounds)
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let initialViewController = storyboard.instantiateViewController(withIdentifier: "HomeVC")
//            let navigationController = UINavigationController(rootViewController: initialViewController)
//            self.window?.rootViewController = navigationController
//            self.window?.makeKeyAndVisible()
            
        }
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
        UIApplication.shared.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self as? MessagingDelegate
        
         UINavigationBar.appearance().isTranslucent = false
        return true
    }

    // MARK: - Register for notifications
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        
        Messaging.messaging().apnsToken = deviceToken
//        InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.sandbox)
//        InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.prod)
        let tok = Messaging.messaging().fcmToken
        print("FCM token: \(tok ?? "")")
        
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(token)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("Failed to register:", error)
    }
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = ApplicationDelegate.shared.application(app, open: url, options: options)
        
        // Add any custom logic here.
        
        return handled
    }
   
    // MARK: - Notification Handling
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        print("Handle push from foreground")
        // custom code to handle push while app is in the foreground
        print("\(notification.request.content.userInfo)")
        completionHandler(.alert)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle push from background or closed")
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
//        userInfo = (response.notification.request.content.userInfo) as NSDictionary
//        print(userInfo)
        
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        
        print("Recived: \(userInfo)")
        
        if ((userDefaults.value(forKey: IS_LOGIN) as? String) == "yes")
        {
            //            let userInfo = (notification.request.content.userInfo as? NSDictionary)!
            print(userInfo)
            let isDeliverNotification = userInfo["DeliveryStatus"] as? String ?? ""
            if isDeliverNotification == "Yes"
            {
                let Delivery = Notification.Name("DeliverySuccess")
                NotificationCenter.default.post(name: Delivery, object: nil)
            }
        }
        
        completionHandler(.newData)
        
    }
    

     // MARK: - App States
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
       self.window?.endEditing(true)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
     //   self.saveContext()
    }

    // MARK: - Core Data stack

//    lazy var persistentContainer: NSPersistentContainer = {
//        /*
//         The persistent container for the application. This implementation
//         creates and returns a container, having loaded the store for the
//         application to it. This property is optional since there are legitimate
//         error conditions that could cause the creation of the store to fail.
//        */
//        let container = NSPersistentContainer(name: "Ironbox")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//
//                /*
//                 Typical reasons for an error here include:
//                 * The parent directory does not exist, cannot be created, or disallows writing.
//                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                 * The device is out of space.
//                 * The store could not be migrated to the current model version.
//                 Check the error message to determine what the actual problem was.
//                 */
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()

    // MARK: - Core Data Saving support

//    func saveContext () {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }

}

