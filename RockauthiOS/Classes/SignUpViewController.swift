//
//  SignUpViewController.swift
//  RockauthiOS
//
//  Created by Cody Mace on 11/2/15.
//  Copyright © 2015 Daniel Gubler. All rights reserved.
//

import UIKit

public class SignUpViewController: UIViewController {

    var firstNameField: UITextField = UITextField()
    var lastNameField: UITextField = UITextField()
    var emailField: UITextField = UITextField()
    var passwordField: UITextField = UITextField()
    var eyeButton: UIButton = UIButton()
    var signUpButton: UIButton = UIButton()
    var nameUnderbar: UIView = UIView()
    var emailUnderbar: UIView = UIView()
    var passwordUnderbar: UIView = UIView()

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.topItem!.title = "Sign Up"
        self.view.backgroundColor = UIColor.whiteColor()
        addTextFields()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addTextFields() {
        let bundle = NSBundle(forClass: self.classForCoder)
        self.firstNameField = UITextField(frame: CGRect(x: 10, y: 12.5, width: 150, height: 23))
        self.firstNameField.placeholder = "First Name"
        self.firstNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.firstNameField.leftViewMode = .Always
        self.firstNameField.font = UIFont.systemFontOfSize(17)
        self.firstNameField.autocorrectionType = .No

        self.lastNameField = UITextField(frame: CGRect(x: 195, y: 12.5, width: 150, height: 23))
        self.lastNameField.placeholder = "Last Name"
        self.lastNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.lastNameField.leftViewMode = .Always
        self.lastNameField.font = UIFont.systemFontOfSize(17)
        self.lastNameField.autocorrectionType = .No

        self.emailField = UITextField(frame: CGRect(x: 10, y: 49.5, width: self.view.frame.size.width - 40, height: 23))
        self.emailField.placeholder = "Email"
        self.emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.emailField.leftViewMode = .Always
        self.emailField.font = UIFont.systemFontOfSize(17)
        self.emailField.keyboardType = .EmailAddress
        self.emailField.autocorrectionType = .No
        self.emailField.autocapitalizationType = .None

        self.passwordField = UITextField(frame: CGRect(x: 10, y: 86.5, width: self.view.frame.size.width - 40, height: 23))
        self.passwordField.placeholder = "Choose Password"
        self.passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.passwordField.leftViewMode = .Always
        self.passwordField.autocorrectionType = .No
        self.passwordField.font = UIFont.systemFontOfSize(17)
        self.passwordField.autocapitalizationType = .None

        self.eyeButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 45, y: 85, width: 30, height: 30))
        let image = UIImage(named: "icon-eye", inBundle: bundle, compatibleWithTraitCollection: UITraitCollection())
        let highlightedImage = UIImage(named: "icon-eye-orange", inBundle: bundle, compatibleWithTraitCollection: UITraitCollection())
        self.eyeButton.setImage(image, forState: .Normal)
        self.eyeButton.setImage(highlightedImage, forState: .Selected)
        self.eyeButton.addTarget(self, action: Selector("eyeTapped"), forControlEvents: .TouchUpInside)

        self.nameUnderbar = UIView(frame: CGRect(x: 10, y: 40, width: self.view.frame.size.width - 20, height: 2))
        self.nameUnderbar.backgroundColor = UIColor(white: 216/255.0, alpha: 1)
        self.view.addSubview(self.nameUnderbar)
        self.emailUnderbar = UIView(frame: CGRect(x: 10, y: 77, width: self.view.frame.size.width - 20, height: 2))
        self.emailUnderbar.backgroundColor = UIColor(white: 216/255.0, alpha: 1)
        self.view.addSubview(self.emailUnderbar)
        self.passwordUnderbar = UIView(frame: CGRect(x: 10, y: 114, width: self.view.frame.size.width - 20, height: 2))
        self.passwordUnderbar.backgroundColor = UIColor(white: 216/255.0, alpha: 1)
        self.view.addSubview(self.passwordUnderbar)

        self.signUpButton = UIButton(type: .System)
        self.signUpButton.frame = CGRect(x: 10, y: 136, width: self.view.frame.size.width - 20, height: 50)
        self.signUpButton.setTitle("Sign Up", forState: .Normal)
        self.signUpButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.signUpButton.titleLabel?.font = UIFont.boldSystemFontOfSize(19)
        self.signUpButton.backgroundColor = UIColor(red: 1, green: 155/255.0, blue: 0, alpha: 1)
        self.signUpButton.addTarget(self, action: Selector("signUpTapped"), forControlEvents: .TouchUpInside)

        self.view.addSubview(firstNameField)
        self.view.addSubview(lastNameField)
        self.view.addSubview(emailField)
        self.view.addSubview(passwordField)
        self.view.addSubview(signUpButton)
        self.view.addSubview(eyeButton)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.signUpButton.layer.cornerRadius = 3
    }

    func eyeTapped() {
        if (self.passwordField.secureTextEntry == true) {
            self.eyeButton.selected = false
            self.passwordField.font = UIFont(name: "Avenir-Medium", size: 17)
            self.passwordField.secureTextEntry = false
        } else {
            self.eyeButton.selected = true
            self.passwordField.font = UIFont.systemFontOfSize(17)
            self.passwordField.secureTextEntry = true
        }
    }

    func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }

    func signUpTapped() {
        resignFirstResponder()
        self.emailUnderbar.backgroundColor = UIColor(white: 216/255.0, alpha: 1)
        self.passwordUnderbar.backgroundColor = UIColor(white: 216/255.0, alpha: 1)
        var validationPassed = true
        if (self.emailField.text == "") {
            self.emailField.attributedPlaceholder = NSAttributedString(string: "Email is required", attributes: [NSForegroundColorAttributeName: UIColor(red: 1, green: 90/255.0, blue: 16/255.0, alpha: 1)])
            self.emailUnderbar.backgroundColor = UIColor(red: 1, green: 90/255.0, blue: 16/255.0, alpha: 0.5)
            validationPassed = false
        } else if (isValidEmail(self.emailField.text!) == false) {
            self.emailField.text = ""
            self.emailField.attributedPlaceholder = NSAttributedString(string: "A valid email is required", attributes: [NSForegroundColorAttributeName: UIColor(red: 1, green: 90/255.0, blue: 16/255.0, alpha: 1)])
            self.emailUnderbar.backgroundColor = UIColor(red: 1, green: 90/255.0, blue: 16/255.0, alpha: 0.5)
            validationPassed = false
        }
        if (self.passwordField.text == "") {
            self.passwordField.attributedPlaceholder = NSAttributedString(string: "Password is required", attributes: [NSForegroundColorAttributeName: UIColor(red: 1, green: 90/255.0, blue: 16/255.0, alpha: 1)])
            self.passwordUnderbar.backgroundColor = UIColor(red: 1, green: 90/255.0, blue: 16/255.0, alpha: 0.5)
            validationPassed = false
        } else if (self.passwordField.text?.characters.count < 8) {
            self.passwordField.text = ""
            self.passwordField.attributedPlaceholder = NSAttributedString(string: "Password must have at least 8 characters", attributes: [NSForegroundColorAttributeName: UIColor(red: 1, green: 90/255.0, blue: 16/255.0, alpha: 1)])
            self.passwordUnderbar.backgroundColor = UIColor(red: 1, green: 90/255.0, blue: 16/255.0, alpha: 0.5)
            validationPassed = false
        }

        if (validationPassed) {
            // check with server
            RockauthClient.sharedClient!.registerUser(self.emailField.text!, password: self.passwordField.text!, success: { (user) -> Void in
                // give the app the user
                print(user)
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                }) { (error) -> Void in
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        let alert = UIAlertController(title: "User could not be created", message: (error as! RockauthError).message, preferredStyle: .Alert)
                        let okButton = UIAlertAction(title: "OK", style: .Default, handler:nil)
                        alert.addAction(okButton)
                        self.navigationController!.presentViewController(alert, animated: true, completion: nil)
                    }
            }
        }
    }
}
