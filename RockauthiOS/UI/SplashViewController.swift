//
//  RockauthSplashViewController.swift
//  Pods
//
//  Created by Brayden Morris on 10/29/15.
//
//

import UIKit

@IBDesignable
class SplashViewController: UIViewController {

    @IBInspectable var useEmailAuthentication: Bool!
    @IBInspectable var cancelButton: Bool!
    var logo: UIImage?
    var providers: [SocialProvider?]!
    var connected: ((user: NSDictionary)->())!
    var failed: ((error: ErrorType)->())!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(emailAuthentication: true, cancelButton: false, providers: [FacebookProvider()], logo: nil, connected: nil, failed: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit(emailAuthentication: true, cancelButton: false, providers: [FacebookProvider()], logo: nil, connected: nil, failed: nil)
    }

    init(showCancelButton: Bool, logo: UIImage?, useEmailAuthentication email: Bool, providers: [SocialProvider?], connected: (user: NSDictionary)->(), failed: (error: ErrorType)->()) {
        super.init(nibName: nil, bundle: nil)
        commonInit(emailAuthentication: email, cancelButton: showCancelButton, providers: providers, logo: logo, connected: connected, failed: failed)
    }

    func commonInit(emailAuthentication email: Bool, cancelButton: Bool, providers: [SocialProvider?], logo: UIImage?, connected: ((user: NSDictionary)->())?, failed: ((error: ErrorType)->())?) {
        useEmailAuthentication = email
        self.cancelButton = cancelButton
        self.providers = providers
        if let logo = logo {
            self.logo = logo
        } else {
            let bundle = NSBundle(forClass: self.classForCoder)
            self.logo = UIImage(named: "logo", inBundle: bundle, compatibleWithTraitCollection: UITraitCollection())
        }
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.title = ""

        if cancelButton! {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "back")
        }

        var views: [String : AnyObject] = [:]

        self.view.backgroundColor = UIColor.whiteColor()

        let buttonsContainer = UIView()
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(buttonsContainer)
        views["buttonsContainer"] = buttonsContainer
        let buttonsContainerHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[buttonsContainer]-10-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        let buttonsContainerVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=10)-[buttonsContainer]-10-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        self.view.addConstraints(buttonsContainerHorizontalConstraints + buttonsContainerVerticalConstraints)

        let socialButtonsContainer = ConnectWithSocialNetworksView(providers: providers, shortFormat: true, orSeparator: false, parentViewController: self, connected: connected, failed: failed)
        socialButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.addSubview(socialButtonsContainer)
        views["socialButtonsContainer"] = socialButtonsContainer
        let socialButtonsContainerVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=0)-[socialButtonsContainer]|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        let socialButtonsContainerHorizontalContstriants = NSLayoutConstraint.constraintsWithVisualFormat("H:|[socialButtonsContainer]|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        buttonsContainer.addConstraints(socialButtonsContainerHorizontalContstriants + socialButtonsContainerVerticalConstraints)

        if useEmailAuthentication! {
            let themeColor = (self.navigationController as! RockauthNavigationController).themeColor
            let signInButton = FlatRoundedButton(title: "Sign In", fontSize: 19, color: themeColor)
            signInButton.translatesAutoresizingMaskIntoConstraints = false
            signInButton.addTarget(self, action: "signInButtonPressed:", forControlEvents: .TouchUpInside)
            buttonsContainer.addSubview(signInButton)
            views["signInButton"] = signInButton
            let height = 50
            let signInButtonVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[signInButton(\(height))]-(10)-[socialButtonsContainer]", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
            buttonsContainer.addConstraints(signInButtonVerticalConstraints)
            let signUpButton = FlatRoundedButton(title: "Sign Up", fontSize: 19, color: themeColor)
            signUpButton.translatesAutoresizingMaskIntoConstraints = false
            signUpButton.addTarget(self, action: "signUpButtonPressed:", forControlEvents: .TouchUpInside)
            buttonsContainer.addSubview(signUpButton)
            views["signUpButton"] = signUpButton
            let signUpButtonVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[signUpButton(\(height))]-(10)-[socialButtonsContainer]", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
            buttonsContainer.addConstraints(signUpButtonVerticalConstraints)
            let emailHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[signInButton]-10-[signUpButton(signInButton)]|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
            buttonsContainer.addConstraints(emailHorizontalConstraints)
        }

        let logoContainer = UIView()
        logoContainer.translatesAutoresizingMaskIntoConstraints = false
        views["logoContainer"] = logoContainer
        self.view.addSubview(logoContainer)
        let logoContainerHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[logoContainer]|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        let logoContainerVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[logoContainer]-[buttonsContainer]", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        self.view.addConstraints(logoContainerHorizontalConstraints + logoContainerVerticalConstraints)

        let logoView = UIImageView(image: logo)
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoContainer.addSubview(logoView)
        views["logoView"] = logoView
        let logoConstraints = [
            NSLayoutConstraint(item: logoView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: logoContainer, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: logoView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: logoContainer, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        ]
        logoContainer.addConstraints(logoConstraints)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func signInButtonPressed(sender: UIButton) {
        let sIVC = SignInViewController(providers: providers, connected: connected, failed: failed)
        self.navigationController?.pushViewController(sIVC, animated: true)
    }

    func signUpButtonPressed(sender: UIButton) {
        let sUVC = SignUpViewController(providers: providers, connected: connected, failed: failed)
        self.navigationController?.pushViewController(sUVC, animated: true)
    }

    func back() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */

}
