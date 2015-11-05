//
//  RockauthSplashViewController.swift
//  Pods
//
//  Created by Brayden Morris on 10/29/15.
//
//

import UIKit

@IBDesignable
class RockauthSplashViewController: UIViewController {

    @IBInspectable var useEmailAuthentication: Bool!
    @IBInspectable var showOtherOptions: Bool!
    var providers: [SocialProvider?]!
    var connected: ((user: NSDictionary)->())!
    var failed: ((error: ErrorType)->())!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(emailAuthentication: true, providers: [FacebookProvider()], otherOptions: true, connected: nil, failed: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit(emailAuthentication: true, providers: [FacebookProvider()], otherOptions: true, connected: nil, failed: nil)
    }

    init(useEmailAuthentication email: Bool, providers: [SocialProvider?], showOtherOptions: Bool, connected: (user: NSDictionary)->(), failed: (error: ErrorType)->()) {
        super.init(nibName: nil, bundle: nil)
        commonInit(emailAuthentication: email, providers: providers, otherOptions: showOtherOptions, connected: connected, failed: failed)
    }

    func commonInit(emailAuthentication email: Bool, providers: [SocialProvider?], otherOptions: Bool, connected: ((user: NSDictionary)->())?, failed: ((error: ErrorType)->())?) {
        useEmailAuthentication = email
        showOtherOptions = otherOptions
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let buttonBack: UIButton = UIButton(type: UIButtonType.Custom) as UIButton
        buttonBack.frame = CGRectMake(0, 0, 40, 40)
        buttonBack.setTitle("Back", forState: .Normal)
        buttonBack.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.setLeftBarButtonItem(UIBarButtonItem(customView: buttonBack), animated: false)

        var views: [String : AnyObject] = [:]

        self.view.backgroundColor = UIColor.whiteColor()

        let buttonsContainer = UIView()
        buttonsContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(buttonsContainer)
        views["buttonsContainer"] = buttonsContainer
        let buttonsContainerHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[buttonsContainer]-10-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        let buttonsContainerVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[buttonsContainer]-10-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        self.view.addConstraints(buttonsContainerHorizontalConstraints + buttonsContainerVerticalConstraints)

        let otherOptionsButton = UIButton(type: UIButtonType.System)
        otherOptionsButton.translatesAutoresizingMaskIntoConstraints = false
        otherOptionsButton.setTitle("Other sign up options", forState: UIControlState.Normal)
        buttonsContainer.addSubview(otherOptionsButton)
        views["otherOptionsButton"] = otherOptionsButton
        let otherOptionsButtonHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[otherOptionsButton]|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        let otherOptionsButtonVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=0)-[otherOptionsButton]-2-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        buttonsContainer.addConstraints(otherOptionsButtonHorizontalConstraints + otherOptionsButtonVerticalConstraints)

        let socialButtonsContainer = ConnectWithSocialNetworksView(providers: providers, connected: connected, failed: failed)
        socialButtonsContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.addSubview(socialButtonsContainer)
        views["socialButtonsContainer"] = socialButtonsContainer
        var socialButtonsContainerVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=0)-[socialButtonsContainer]-10-[otherOptionsButton]", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        socialButtonsContainerVerticalConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[socialButtonsContainer]-(>=10)-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        let socialButtonsContainerHorizontalContstriants = NSLayoutConstraint.constraintsWithVisualFormat("H:|[socialButtonsContainer]|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        buttonsContainer.addConstraints(socialButtonsContainerHorizontalContstriants + socialButtonsContainerVerticalConstraints)

        let signInButton = FlatRoundedButton(title: "Sign In", fontSize: 19, color: RockauthClient.sharedClient?.themeColor)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainer.addSubview(signInButton)
        views["signInButton"] = signInButton
        let height = 50
        let signInButtonVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[signInButton(\(height))]-(10)-[socialButtonsContainer]", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        buttonsContainer.addConstraints(signInButtonVerticalConstraints)
        let signUpButton = FlatRoundedButton(title: "Sign Up", fontSize: 19, color: RockauthClient.sharedClient?.themeColor)
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.addTarget(self, action: "signUpButtonPressed:", forControlEvents: .TouchUpInside)
        buttonsContainer.addSubview(signUpButton)
        views["signUpButton"] = signUpButton
        let signUpButtonVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[signUpButton(\(height))]-(10)-[socialButtonsContainer]", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        buttonsContainer.addConstraints(signUpButtonVerticalConstraints)
        let emailHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[signInButton]-10-[signUpButton(signInButton)]|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        buttonsContainer.addConstraints(emailHorizontalConstraints)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func signUpButtonPressed(sender: UIButton) {
        let sUVC = SignUpViewController()
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
