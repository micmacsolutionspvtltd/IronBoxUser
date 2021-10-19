//
//  WebViewVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 19/01/19.
//  Copyright © 2019 Gopalsamy A. All rights reserved.
//


import UIKit
import WebKit

class WebViewVC: UIViewController, WKUIDelegate, WKNavigationDelegate  {
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    var strTitle = ""
    var strURL = ""
    var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]
        
        let btnBack = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItems([item], animated: true)
        
        self.title = strTitle
        
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), configuration: WKWebViewConfiguration())
        webView.uiDelegate = self
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        let myURL = URL(string: strURL)
        let myRequest = URLRequest(url: myURL!)
        self.activityIndicator.isHidden = false
        webView.load(myRequest)
        
        self.activityIndicator.color = UIColor.black
        self.webView.addSubview(self.activityIndicator)
        self.activityIndicator.center = self.view.center
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidesWhenStopped = true
        
        
    }
    @objc func ClickonBackBtn()
    {
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    
}
