//
//  SignInViewController.swift
//  Positron
//
//  Created by Sanip Shrestha on 1/23/21.
//  Copyright © 2021 Sanip Shrestha. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var passwordLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func SignInPressed(_ sender: Any) {
        if (validateFields())
        {
            AppDelegate.WebApi.Login(username: usernameLabel.text ?? "", password: passwordLabel.text ?? "") { (success) in
                if (success)
                {
                    AppDelegate.UserID = self.usernameLabel.text ?? ""
                    AppDelegate.Password = self.passwordLabel.text ?? ""
      
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                    
                    let defaults = UserDefaults.standard
                    defaults.set(AppDelegate.UserID, forKey: "username")
                    defaults.set(AppDelegate.Password, forKey: "password")

                    
                    // This is to get the SceneDelegate object from your view controller
                    // then call the change root view controller function to change to main tab bar
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                }
            }
        }
    }
    
    func validateFields() -> Bool
    {
        if ((usernameLabel.text) != nil && passwordLabel.text != nil)
        {
            return true;
        }
        if (usernameLabel.text != nil)
        {
            errorMessageLabel.text = "Please enter a username."
        }
        else if (passwordLabel.text != nil)
        {
            errorMessageLabel.text = "Please enter a password."
        }
        return false;
    }
}
