//
//  SignInViewController.swift
//  RockauthiOS
//
//  Created by Cody Mace on 11/2/15.
//  Copyright © 2015 Daniel Gubler. All rights reserved.
//

import UIKit

public class SignInViewController: UIViewController {

    var emailField: UITextField = UITextField()
    var passwordField: UITextField = UITextField()
    var eyeButton: UIButton = UIButton()
    var signInButton: UIButton = UIButton()
    var emailUnderbar: UIView = UIView()
    var passwordUnderbar: UIView = UIView()
    var providers: [SocialProvider?]!
    var connected: ((user: NSDictionary)->())!
    var failed: ((error: ErrorType)->())!

    init(providers: [SocialProvider?], connected: ((user: NSDictionary)->())?, failed: ((error: ErrorType)->())?) {
        super.init(nibName: nil, bundle: nil)
        commonInit(providers, connected: connected, failed: failed)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(providers, connected: nil, failed: nil)
    }

    func commonInit(providers: [SocialProvider?], connected: ((user: NSDictionary)->())?, failed: ((error: ErrorType)->())?) {
        self.providers = providers
        if let connected = connected {
            self.connected = connected
        } else {
            self.connected = {(user: NSDictionary) -> () in
                print(user)
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

        self.title = "Sign In"
        // Do any additional setup after loading the view.

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

        self.emailField = UITextField(frame: CGRect(x: 10, y: 15, width: self.view.frame.size.width - 40, height: 23))
        self.emailField.placeholder = "Email"
        self.emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.emailField.leftViewMode = .Always
        self.emailField.font = UIFont.systemFontOfSize(17)
        self.emailField.keyboardType = .EmailAddress
        self.emailField.autocorrectionType = .No
        self.emailField.autocapitalizationType = .None
        views["emailField"] = self.emailField

        self.passwordField = UITextField(frame: CGRect(x: 10, y: 54, width: self.view.frame.size.width - 40, height: 23))
        self.passwordField.placeholder = "Choose Password"
        self.passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.passwordField.leftViewMode = .Always
        self.passwordField.autocorrectionType = .No
        self.passwordField.font = UIFont.systemFontOfSize(17)
        self.passwordField.autocapitalizationType = .None
        self.passwordField.secureTextEntry = true
        views["passwordField"] = self.passwordField

        self.eyeButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 45, y: 52, width: 30, height: 30))
        let image = UIImage(named: "icon-eye-gray", inBundle: bundle, compatibleWithTraitCollection: UITraitCollection())
        let highlightedImage = UIImage(named: "eyeIcon", inBundle: bundle, compatibleWithTraitCollection: UITraitCollection())?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        if let themeColor = RockauthClient.sharedClient?.themeColor {
            self.eyeButton.imageView?.tintColor = themeColor
        } else {
            self.eyeButton.imageView?.tintColor = UIColor.blackColor()
        }
        self.eyeButton.selected = false
        self.eyeButton.setImage(image, forState: .Normal)
        self.eyeButton.setImage(highlightedImage, forState: .Selected)
        self.eyeButton.addTarget(self, action: Selector("eyeTapped"), forControlEvents: .TouchUpInside)
        views["eyeButton"] = self.eyeButton

        self.emailUnderbar = UIView(frame: CGRect(x: 10, y: 42.5, width: self.view.frame.size.width - 20, height: 2))
        self.emailUnderbar.backgroundColor = UIColor(white: 216/255.0, alpha: 1)
        self.view.addSubview(self.emailUnderbar)
        self.passwordUnderbar = UIView(frame: CGRect(x: 10, y: 81.5, width: self.view.frame.size.width - 20, height: 2))
        self.passwordUnderbar.backgroundColor = UIColor(white: 216/255.0, alpha: 1)
        self.view.addSubview(self.passwordUnderbar)

        self.signInButton = UIButton(type: .System)
        self.signInButton.frame = CGRect(x: 10, y: 105.5, width: self.view.frame.size.width - 20, height: 50)
        self.signInButton.setTitle("Sign In", forState: .Normal)
        self.signInButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.signInButton.titleLabel?.font = UIFont.systemFontOfSize(19, weight: UIFontWeightSemibold)
        self.signInButton.backgroundColor = RockauthClient.sharedClient?.themeColor
        self.signInButton.addTarget(self, action: Selector("signInTapped"), forControlEvents: .TouchUpInside)
        views["signInButton"] = self.signInButton

        self.view.addSubview(emailField)
        self.view.addSubview(passwordField)
        self.view.addSubview(signInButton)
        self.view.addSubview(eyeButton)

        let socialNetworksView = ConnectWithSocialNetworksView(providers: self.providers, shortFormat: true, orSeparator: true, parentViewController: self, connected: self.connected, failed: self.failed)
        socialNetworksView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(socialNetworksView)
        views["socialNetworksView"] = socialNetworksView
        let socialNetworksViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[socialNetworksView]-10-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        let socialNetworksViewVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[signInButton]-10-[socialNetworksView]", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
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
        self.signInButton.layer.cornerRadius = 3
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

    func signInTapped() {
        self.emailField.text = self.emailField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        resignFirstResponder()
        // check with server
        RockauthClient.sharedClient!.login(self.emailField.text, password: self.passwordField.text, success: {
            (user) -> Void in
            // give the app the user
            self.connected(user: user)
            }) { (error) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.navigationController!.presentViewController((error as! RockauthError).alertController, animated: true, completion: nil)
                }
        }
    }
    
    func tosTapped() {
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
