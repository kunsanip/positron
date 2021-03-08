//
//  SignUpViewController.swift
//  Positron
//
//  Created by Sanip Shrestha on 1/26/21.
//  Copyright © 2021 Sanip Shrestha. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var reenteredPassword: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var ErrorMessage: UITextView!
    @IBOutlet weak var dob: UITextField!
    
    @IBOutlet var signupView: UIView!
    var activeTextField = UITextField()
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailAddress.delegate = self
        firstName.delegate = self
        lastName.delegate = self
        password.delegate = self
        reenteredPassword.delegate = self
        phone.delegate = self
        dob.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        initialiseDatePicker()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        
        // 2. add the gesture recognizer to a view
        signupView.addGestureRecognizer(tapGesture)
    }
    
    // 3. this method is called when a tap is recognized
    @objc func handleTap(sender: UITapGestureRecognizer) {
        self.activeTextField.resignFirstResponder()
    }
    func initialiseDatePicker()
    {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //bar button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        
        datePicker.center = dob.center
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        dob.inputAccessoryView = toolbar
        dob.inputView = datePicker
    }
    @objc func donePressed()
    {
        dob.text = UtilDate.getUrlFriendlyDateString(date: datePicker.date)
        self.view.endEditing(true)
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
            signupDetail.CreatedOn = Date().toStringDateTime()
            ProgressUtil.custom(text: "Registering your new account...")
            AppDelegate.WebApi.SignupUser(apiModel: signupDetail) { (result) in
                if (result.Success!)
                {
                    self.dismiss(animated: true, completion: nil)
                }
                else
                {
                    self.ErrorMessage.text = result.Message
                }
                ProgressUtil.dismiss()
            }
        }
        else{
            self.activeTextField.resignFirstResponder()
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.switchBasedNextTextField(textField)
        return true
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.firstName:
            self.lastName.becomeFirstResponder()
        case self.lastName:
            self.dob.becomeFirstResponder()
        case self.dob:
            self.emailAddress.becomeFirstResponder()
        case self.emailAddress:
            self.password.becomeFirstResponder()
        case self.password:
            self.reenteredPassword.becomeFirstResponder()
        case self.reenteredPassword:
            self.phone.becomeFirstResponder()
        default:
            self.phone.resignFirstResponder()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//                self.view.frame.origin.y -= keyboardSize.height
                self.view.layoutIfNeeded()
                
                UIView.animate(withDuration: 0.25, animations: {
                    
                    self.view.layoutIfNeeded()
                    self.view.frame.origin.y = keyboardSize.height - 100 -  self.activeTextField.frame.origin.y
                })
            }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
