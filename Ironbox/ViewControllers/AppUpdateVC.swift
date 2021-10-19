//
//  AppUpdateVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 25/06/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit

class AppUpdateVC: UIViewController {

    @IBOutlet weak var lblUpdateMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setFontFamilyAndSize()
        self.hideKeyboardWhenTappedAround()
        lblUpdateMessage.text = appDelegate.strUpdateMsg
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onUpdate(_ sender: Any)
    {
        if let url = URL(string: APP_STORE_URL),
            UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
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

}
