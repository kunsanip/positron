//
//  SignUpViewController.swift
//  Positron
//
//  Created by Sanip Shrestha on 1/26/21.
//  Copyright © 2021 Sanip Shrestha. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var reenteredPassword: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var ErrorMessage: UITextView!
    @IBOutlet weak var dob: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func signUp(_ sender: Any) {
        
        if (validate())
        {
            print("Successful")
            
            //Create object and send to the server
            let signupDetail = SignupApiModel()
            signupDetail.Firstname = firstName.text
            signupDetail.Lastname = lastName.text
            signupDetail.UserID = emailAddress.text
            signupDetail.Password = password.text
            signupDetail.DOB = dob.text
            signupDetail.Phonenumber = phone.text
            
            AppDelegate.WebApi.SignupUser(apiModel: signupDetail) { (result) in
                print(result)
            }
            
        }
    }
    
    func validate() -> Bool
    {
        var message = ""
        if (emailAddress.text == ""){ message += "Please enter an email address.\n"}
        if (password.text == ""){ message += "Please enter a password.\n"}
        if (reenteredPassword.text == "" && password.text != ""){ message += "Please re-enter a password.\n"}
        if (firstName.text == ""){ message += "Please enter your first name.\n"}
        if (lastName.text == ""){ message += "Please enter your last name.\n"}
        
        //password
        if (password.text != "" && reenteredPassword.text != "" && password.text != reenteredPassword.text)
        {
            message += "Your entered password doesn't match with re-entered password\n"
        }
        if (emailAddress.text != "" && !(isValidEmail(email: emailAddress.text ?? "")))
        {
            message += "The email you've entered is invalid.\n"
        }
        if (phone.text != "" && !(validatePhone(phone.text ?? "")))
        {
            message += "Invalid phone number.\n"
        }
        
        ErrorMessage.text = message
        return message == ""
    }
    
    func isValidEmail(email:String) -> Bool{
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: email)
        return result
    }
    
    func validatePhone(_ phonenumber: String) -> Bool {
        let PHONE_REGEX = "^\\d{3}\\d{3}\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: phonenumber)
        return result
    }
    
    @IBAction func SignInButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)

    }
}
