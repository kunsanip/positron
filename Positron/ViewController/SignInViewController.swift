//
//  SignInViewController.swift
//  Positron
//
//  Created by Sanip Shrestha on 1/23/21.
//  Copyright © 2021 Sanip Shrestha. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var usernameLabel: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var passwordLabel: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameLabel.delegate = self
        passwordLabel.delegate = self
        
        errorMessageLabel.font = UIFont.systemFont(ofSize: 10)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        
        // 2. add the gesture recognizer to a view
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // 3. this method is called when a tap is recognized
    @objc func handleTap(sender: UITapGestureRecognizer) {
        self.usernameLabel.resignFirstResponder()
        self.passwordLabel.resignFirstResponder()
    }
    
    @IBAction func SignInPressed(_ sender: Any) {
       signIn()
    }
    func signIn()
    {
        if (validateFields())
        {
            ProgressUtil.logIn()
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

                    ProgressUtil.dismiss()
                    
                    // This is to get the SceneDelegate object from your view controller
                    // then call the change root view controller function to change to main tab bar
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                }
                else
                {
                    ProgressUtil.custom(text: "Login failed..")
                    ProgressUtil.dismiss()
                    
                    self.errorMessageLabel.text = "Login failed. Invalid username/password."
                }
            }
        }
    }
    
    @IBAction func exploreBtnPressed(_ sender: Any) {
        //sign up
        AppDelegate.WebApi.GetUsernameForExplorer { (id) in
            let signupDetail = SignupApiModel()
            signupDetail.Firstname = "Explore-\(id)"
            signupDetail.Lastname = "Explore-\(id)"
            signupDetail.UserID = "Explore-\(id)"
            signupDetail.Password = "Explore-Pass-\(id)"
            signupDetail.DOB = "1/1/2000"
            signupDetail.Phonenumber = ""
            signupDetail.CreatedOn = Date().toStringDateTime()
            ProgressUtil.custom(text: "Loading....")
            AppDelegate.WebApi.SignupUser(apiModel: signupDetail) { (result) in
                if (result.Success!)
                {
                    ProgressUtil.logIn()
                    AppDelegate.WebApi.Login(username: "Explore-\(id)", password: "Explore-Pass-\(id)") { (success) in
                        if (success)
                        {
                            AppDelegate.UserID = "Explore-\(id)"
                            AppDelegate.Password = "Explore-Pass-\(id)"
              
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                            
                            let defaults = UserDefaults.standard
                            defaults.set(AppDelegate.UserID, forKey: "username")
                            defaults.set(AppDelegate.Password, forKey: "password")

                            ProgressUtil.dismiss()
                            
                            // This is to get the SceneDelegate object from your view controller
                            // then call the change root view controller function to change to main tab bar
                            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                        }
                        else
                        {
                            ProgressUtil.custom(text: "Login failed..")
                            ProgressUtil.dismiss()
                            
                            self.errorMessageLabel.text = "Login failed. Invalid username/password."
                        }
                    }
                }
                else
                {
                    print("Failed..")
                }
                ProgressUtil.dismiss()
            }
            //save on device
            
            //login
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.switchBasedNextTextField(textField)
        return true
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.usernameLabel:
            self.passwordLabel.becomeFirstResponder()
        case self.passwordLabel:
            signIn()
        default:
            self.passwordLabel.resignFirstResponder()
        }
    }
}
