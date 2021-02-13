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
    override func viewDidLoad() {
        super.viewDidLoad()
        Username.text = AppDelegate.UserID
    }
    
    @IBAction func LogOutPressed(_ sender: Any) {
        AppDelegate.UserID = ""
        AppDelegate.Password = ""

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInViewController = storyboard.instantiateViewController(identifier: "Initial")
        
        let defaults = UserDefaults.standard
        defaults.set("", forKey: "username")
        defaults.set("", forKey: "password")
        
        // This is to get the SceneDelegate object from your view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(signInViewController)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
