//
//  ProfileViewController.swift
//  Positron
//
//  Created by Sanip Shrestha on 1/26/21.
//  Copyright © 2021 Sanip Shrestha. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var Username: UITextView!
    @IBOutlet weak var summaryTableViewCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        Username.text = AppDelegate.UserID
        let image = UIImage(systemName: "chart.bar.xaxis")?
            .withTintColor(UIColor.white , renderingMode: .alwaysOriginal)
        
        summaryTableViewCell.imageView?.image = image
        summaryTableViewCell.textLabel?.text = "View summary"
        summaryTableViewCell.textLabel?.textColor = .white
        summaryTableViewCell.accessoryType = .disclosureIndicator
        summaryTableViewCell.tintColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCell))
        summaryTableViewCell.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapCell()
    {
        self.performSegue(withIdentifier: "summary", sender: self)
   }
    
    @IBAction func LogOutPressed(_ sender: Any) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInViewController = storyboard.instantiateViewController(identifier: "Initial")

        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.synchronize()
        
        // This is to get the SceneDelegate object from your view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(signInViewController)
    }
}
