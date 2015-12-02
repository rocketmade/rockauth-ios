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
    var providers: [SocialProvider?]!
    var connected: loginSuccess!
    var failed: loginFailure!

    init(providers: [SocialProvider?], connected: loginSuccess?, failed: loginFailure?) {
        super.init(nibName: nil, bundle: nil)
        commonInit(providers, connected: connected, failed: failed)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(providers, connected: nil, failed: nil)
    }

    func commonInit(providers: [SocialProvider?], connected: loginSuccess?, failed: loginFailure?) {
        self.providers = providers
        if let connected = connected {
            self.connected = connected
        } else {
            self.connected = {(session: RockAuthSession) -> () in
                print(session)
                if let navigationController = self.navigationController {
                    navigationController.popViewControllerAnimated(true)
                }
            }
        }
        if let failed = failed {
            self.failed = failed
        } else {
            self.failed = {(error: ErrorType) -> () in
                print(error)
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Sign Up"

        self.view.backgroundColor = UIColor.whiteColor()
        addAllSubviews()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addAllSubviews() {
        var views: [String: AnyObject] = [:]

        let bundle = NSBundle(forClass: self.classForCoder)
        self.firstNameField = UITextField(frame: CGRect(x: 10, y: 12.5, width: 150, height: 23))
        self.firstNameField.placeholder = "First Name"
        self.firstNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.firstNameField.leftViewMode = .Always
        self.firstNameField.font = UIFont.systemFontOfSize(17)
        self.firstNameField.autocorrectionType = .No
        views["firstNameField"] = self.firstNameField

        self.lastNameField = UITextField(frame: CGRect(x: 195, y: 12.5, width: 150, height: 23))
        self.lastNameField.placeholder = "Last Name"
        self.lastNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.lastNameField.leftViewMode = .Always
        self.lastNameField.font = UIFont.systemFontOfSize(17)
        self.lastNameField.autocorrectionType = .No
        views["lastNameField"] = self.lastNameField

        self.emailField = UITextField(frame: CGRect(x: 10, y: 49.5, width: self.view.frame.size.width - 40, height: 23))
        self.emailField.placeholder = "Email"
        self.emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.emailField.leftViewMode = .Always
        self.emailField.font = UIFont.systemFontOfSize(17)
        self.emailField.keyboardType = .EmailAddress
        self.emailField.autocorrectionType = .No
        self.emailField.autocapitalizationType = .None
        views["emailField"] = self.emailField

        self.passwordField = UITextField(frame: CGRect(x: 10, y: 86.5, width: self.view.frame.size.width - 40, height: 23))
        self.passwordField.placeholder = "Choose Password"
        self.passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.passwordField.leftViewMode = .Always
        self.passwordField.autocorrectionType = .No
        self.passwordField.font = UIFont.systemFontOfSize(17)
        self.passwordField.autocapitalizationType = .None
        views["passwordField"] = self.passwordField

        var themeColor: UIColor
        if let tc = (self.navigationController as! RockauthNavigationController).themeColor {
            themeColor = tc
        } else {
            themeColor = UIColor.blackColor()
        }
        self.eyeButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 45, y: 85, width: 30, height: 30))
        let image = UIImage(named: "icon-eye-gray", inBundle: bundle, compatibleWithTraitCollection: UITraitCollection())
        let highlightedImage = UIImage(named: "eyeIcon", inBundle: bundle, compatibleWithTraitCollection: UITraitCollection())?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.eyeButton.imageView?.tintColor = themeColor
        self.eyeButton.setImage(image, forState: .Normal)
        self.eyeButton.setImage(highlightedImage, forState: .Selected)
        self.eyeButton.selected = true
        self.eyeButton.addTarget(self, action: Selector("eyeTapped"), forControlEvents: .TouchUpInside)
        views["eyeButton"] = self.eyeButton

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
        self.signUpButton.titleLabel?.font = UIFont.systemFontOfSize(19, weight: UIFontWeightSemibold)
        self.signUpButton.backgroundColor = themeColor
        self.signUpButton.addTarget(self, action: Selector("signUpTapped"), forControlEvents: .TouchUpInside)
        views["signUpButton"] = self.signUpButton

        self.view.addSubview(firstNameField)
        self.view.addSubview(lastNameField)
        self.view.addSubview(emailField)
        self.view.addSubview(passwordField)
        self.view.addSubview(signUpButton)
        self.view.addSubview(eyeButton)

        let socialNetworksView = ConnectWithSocialNetworksView(providers: self.providers, shortFormat: true, orSeparator: true, parentViewController: self, connected: self.connected, failed: self.failed)
        socialNetworksView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(socialNetworksView)
        views["socialNetworksView"] = socialNetworksView
        let socialNetworksViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[socialNetworksView]-10-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        let socialNetworksViewVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[signUpButton]-10-[socialNetworksView]", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        self.view.addConstraints(socialNetworksViewHorizontalConstraints + socialNetworksViewVerticalConstraints)

        let tosButton = UIButton(type: UIButtonType.System)
        tosButton.translatesAutoresizingMaskIntoConstraints = false
        let tosFont = UIFont.systemFontOfSize(12, weight: UIFontWeightRegular)
        let tosAttributes: [String: AnyObject] = [
            NSFontAttributeName: tosFont,
            NSForegroundColorAttributeName: UIColor(white: 161/255.0, alpha: 1)
        ]
        let attributedTitle = NSMutableAttributedString(string: "By continuing you indicate that you have read and agree to the ", attributes: tosAttributes)
        let tosString = NSMutableAttributedString(string: "Terms of Service", attributes: tosAttributes)
        tosString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSRange.init(location: 0, length: tosString.length))
        attributedTitle.appendAttributedString(tosString)
        tosButton.setAttributedTitle(attributedTitle, forState: UIControlState.Normal)
        tosButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        tosButton.titleLabel?.textAlignment = NSTextAlignment.Center
        tosButton.addTarget(self, action: Selector("tosTapped"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(tosButton)
        views["tosButton"] = tosButton
        let tosHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-50-[tosButton]-50-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        let tosVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[socialNetworksView]-10-[tosButton]", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        self.view.addConstraints(tosHorizontalConstraints + tosVerticalConstraints)

    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.signUpButton.layer.cornerRadius = 3
    }

    func eyeTapped() {
        if (self.eyeButton.selected == true) {
            self.eyeButton.selected = false
            self.passwordField.font = UIFont(name: "Avenir-Medium", size: 17)
            self.passwordField.secureTextEntry = true
        } else {
            self.eyeButton.selected = true
            self.passwordField.font = UIFont.systemFontOfSize(17)
            self.passwordField.secureTextEntry = false
        }
    }

    func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }

    func signUpTapped() {
        self.emailField.text = self.emailField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
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
            
            RockauthClient.sharedClient!.registerUser(self.firstNameField.text!, lastName: self.lastNameField.text!, email: self.emailField.text!, password: self.passwordField.text!, success: { (session) -> Void in
                // give the app the user
                self.connected(session: session)
                }) { (error) -> Void in
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.navigationController!.presentViewController((error as! RockauthError).alertController, animated: true, completion: nil)
                    }
            }
        }
    }

    func tosTapped() {
    }

    func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
