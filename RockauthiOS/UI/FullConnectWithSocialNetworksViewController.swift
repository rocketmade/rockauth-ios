//
//  FullConnectWithSocialNetworksViewController.swift
//  Pods
//
//  Created by Brayden Morris on 11/10/15.
//
//

import UIKit

class FullConnectWithSocialNetworksViewController: UIViewController {

    var providers: [SocialProvider?]!
    var connected: loginSuccess!
    var failed: loginFailure!

    init(providers: [SocialProvider?], connected: loginSuccess, failed: loginFailure) {
        super.init(nibName: nil, bundle: nil)
        commonInit(providers, connected: connected, failed: failed)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit([FacebookProvider.sharedProvider], connected: nil, failed: nil)
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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Sign In Options"

        self.view.backgroundColor = UIColor.whiteColor()

        var views: [String: AnyObject] = [:]

        let providersView = ConnectWithSocialNetworksView(providers: providers, shortFormat: false, orSeparator: false, parentViewController: self, connected: connected, failed: failed)
        providersView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(providersView)
        views["providersView"] = providersView
        let providersViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[providersView]-10-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        let providersViewVerticalConstrints =  NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[providersView]-(>=10)-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
        self.view.addConstraints(providersViewHorizontalConstraints + providersViewVerticalConstrints)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
