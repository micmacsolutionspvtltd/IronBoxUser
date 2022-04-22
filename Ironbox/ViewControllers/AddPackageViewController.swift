//
//  AddPackageViewController.swift
//  Ironbox
//
//  Created by MAC on 20/04/22.
//  Copyright © 2022 Gopalsamy A. All rights reserved.
//

import UIKit

class AddPackageViewController: UIViewController {
    @IBOutlet weak var packageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        packageTableView?.register(AddPackageTableViewCell.nib, forCellReuseIdentifier: AddPackageTableViewCell.identifier)
        navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: FONT_BOLD, size: 19)!, NSAttributedStringKey.foregroundColor : UIColor(red: 26/255.0, green: 60/255.0, blue: 92/255.0, alpha: 1.0)]
        
        self.navigationItem.hidesBackButton = true
        let btnBack = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "BackButton"), for: .normal)
        btnBack.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnBack.addTarget(self, action: #selector(self.ClickonBackBtn), for: .touchUpInside)
        let item = UIBarButtonItem(customView: btnBack)
        self.navigationItem.setLeftBarButtonItems([item], animated: true)
    //    navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @objc func ClickonBackBtn()
    {
      //  view.endEditing(true)
     //   navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)

    }


}

extension AddPackageViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddPackageTableViewCell") as? AddPackageTableViewCell
        return cell!
    }
    
    
}
