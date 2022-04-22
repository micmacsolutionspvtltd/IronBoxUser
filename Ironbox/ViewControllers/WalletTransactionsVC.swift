//
//  WalletTransactionsVC.swift
//  Ironbox
//
//  Created by Gopalsamy A on 30/05/18.
//  Copyright © 2018 Gopalsamy A. All rights reserved.
//

import UIKit
import Spring
import Parchment

class WalletTransactionsVC: UIViewController {

    fileprivate let menu = [
        "ALL",
        "CREDIT",
        "SPENT",
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setFontFamilyAndSize()
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]
        
        let btnBack = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItems([item], animated: true)
        
        let pagingViewController = PagingViewController()
        pagingViewController.dataSource = self
        pagingViewController.delegate = self
        pagingViewController.indicatorColor = UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1)
        pagingViewController.selectedTextColor =  UIColor(red: 139/255, green: 214/255, blue: 239/255, alpha: 1)
        pagingViewController.textColor = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha: 1.0)
        pagingViewController.backgroundColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1)
        pagingViewController.selectedBackgroundColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1)
        pagingViewController.font = UIFont(name: FONT_BOLD, size: 18)!
        pagingViewController.selectedFont = UIFont(name: FONT_BOLD, size: 18)!
        pagingViewController.borderColor = UIColor.clear
        pagingViewController.menuBackgroundColor = UIColor(red: 26/255, green: 60/255, blue: 92/255, alpha: 1)
        
        // Add the paging view controller as a child view controller and
        // contrain it to all edges.
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ACTIONS
    @objc func ClickonBackBtn()
    {
        _ = navigationController?.popViewController(animated: true)
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

extension WalletTransactionsVC: PagingViewControllerDataSource {
    func pagingViewController(_: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return WalletTransactionTableViewVC(title: menu[index])
    }
    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return PagingIndexItem(index: index, title: menu[index])
    }
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return menu.count
    }
}

extension WalletTransactionsVC: PagingViewControllerDelegate {
    
    // We want the size of our paging items to equal the width of the
    // city title. Parchment does not support self-sizing cells at
    // the moment, so we have to handle the calculation ourself. We
    // can access the title string by casting the paging item to a
    // PagingTitleItem, which is the PagingItem type used by
    // FixedPagingViewController.
    func pagingViewController(_ pagingViewController: PagingViewController, widthForPagingItem pagingItem: PagingItem, isSelected: Bool) -> CGFloat {

        guard let item = pagingItem as? PagingIndexItem else { return 0 }
        
        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: pagingViewController.menuItemSize.height)
        let attributes = [NSAttributedStringKey.font: pagingViewController.font]
        
        let rect = item.title.boundingRect(with: size,
                                           options: .usesLineFragmentOrigin,
                                           attributes: attributes,
                                           context: nil)
        
        let width = ceil(rect.width) + insets.left + insets.right
        let screenSize: CGRect = UIScreen.main.bounds
        if isSelected {
            return screenSize.width / 3
        } else {
            return screenSize.width / 3
        }
    }
    
}

