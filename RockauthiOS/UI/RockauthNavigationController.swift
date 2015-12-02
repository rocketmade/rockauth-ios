//
//  RockauthNavigationController.swift
//  RockauthiOS
//
//  Created by Cody Mace on 11/16/15.
//  Copyright © 2015 Daniel Gubler. All rights reserved.
//

import UIKit

public class RockauthNavigationController: UINavigationController {

    var logo: UIImage?
    var providers: [SocialProvider?]!
    var connected: loginSuccess!
    var failed: loginFailure!
    var useEmailAuthentication: Bool!
    public var themeColor: UIColor?

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(self.providers, connected: nil, failed: nil)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil)
        commonInit([], connected: nil, failed: nil)
    }

    public init(themeColor: UIColor, logo: UIImage?, useEmailAuthentication: Bool, providers: [SocialProvider?]) {
        let splash = UIViewController(nibName: nil, bundle: nil)
        super.init(rootViewController: splash)
        self.navigationBar.backgroundColor = themeColor
        self.navigationBar.barStyle = .Black
        self.navigationBar.barTintColor = themeColor
        self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationBar.translucent = false
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.useEmailAuthentication = useEmailAuthentication
        self.logo = logo
        self.providers = providers
        self.themeColor = themeColor
    }


    func commonInit(providers: [SocialProvider?], connected: loginSuccess?, failed: loginFailure?) {
        self.providers = providers
        if let connected = connected {
            self.connected = connected
        } else {
            self.connected = {(session: RockAuthSession) -> () in
                print(session)
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

    public func showUI(presenter: UIViewController, connected: loginSuccess, failed: loginFailure) {
        self.connected = connected
        self.failed = failed
        let splash = SplashViewController(showCancelButton: true, logo: self.logo, useEmailAuthentication: self.useEmailAuthentication, providers: self.providers, connected: self.connected, failed: self.failed)
        self.viewControllers = [splash]
//        self.modalPresentationStyle = .Custom
        presenter.presentViewController(self, animated: true) { () -> Void in
        }
    }
}

