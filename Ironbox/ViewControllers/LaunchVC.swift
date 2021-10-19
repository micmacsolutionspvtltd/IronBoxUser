//
//  LaunchVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 24/04/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class LaunchVC: UIViewController {

    @IBOutlet weak var imgLogo: UIImageView!
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage.gif(name: "IronboxLogo")
        imgLogo.animationImages = logo?.images
        imgLogo.animationDuration = 3
        imgLogo.animationRepeatCount = 1
        imgLogo.startAnimating()
        self.moveToNxtVC()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
    self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ACTION
    func moveToNxtVC()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3)
        {
            if ((userDefaults.value(forKey: IS_LOGIN) as? String) == "yes")
            {
                let story = UIStoryboard.init(name: "Main", bundle: nil)
                let HomeVC = story.instantiateViewController(withIdentifier: "HomeVC")as! HomeVC
                self.navigationController?.pushViewController(HomeVC, animated: false)
            }
            else
            {
                let story = UIStoryboard.init(name: "Main", bundle: nil)
                let HomeVC = story.instantiateViewController(withIdentifier: "SignInVC")as! SignInVC
                self.navigationController?.pushViewController(HomeVC, animated: false)
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
