//
//  ConnectWithSocialNetworksView.swift
//  Pods
//
//  Created by Brayden Morris on 11/2/15.
//
//

import UIKit

class ConnectWithSocialNetworksView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    var providers: [SocialProvider]!
    var providersByTitle: [String:SocialProvider] = [:]
    var success: ((user: NSDictionary) -> ())!
    var failure: ((error: ErrorType) -> ())!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit([FacebookProvider()], connected: nil, failed: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit([FacebookProvider()], connected: nil, failed: nil)
    }

    init(providers: [SocialProvider], connected: (user: NSDictionary) -> (), failed: (error: ErrorType) -> ()) {
        super.init(frame: CGRectZero)
        commonInit(providers, connected: connected, failed: failed)
    }

    func commonInit(providers: [SocialProvider], connected: ((user: NSDictionary) -> ())?, failed: ((error: ErrorType) -> ())?) {
        self.providers = providers
        if let connected = connected {
            self.success = connected
        } else {
            self.success = {(user: NSDictionary) -> () in
                print(user)
            }
        }
        if let failed = failed {
            self.failure = failed
        } else {
            self.failure = {(error: ErrorType) -> () in
                print(error)
            }
        }
    }

    override func layoutSubviews() {
        var views: [String : AnyObject] = [:]
        var previousProviderButton: String? = nil
        for provider in providers {
            let providerButton = UIButton(type: UIButtonType.RoundedRect)
            providerButton.translatesAutoresizingMaskIntoConstraints = false
            let title = "Connect with \(provider.prettyName)"
            providerButton.setTitle(title, forState: UIControlState.Normal)
            providersByTitle[title] = provider
            providerButton.setBackgroundImage(provider.color.resizeableImageFromColor(), forState: UIControlState.Normal)
            providerButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            providerButton.addTarget(self, action: "providerButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(providerButton)
            views[provider.name] = providerButton
            let providerButtonHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[\(provider.name)]|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
            let providerButtonVerticalConstraints: [NSLayoutConstraint]
            let height = 50
            if let previousProviderButton = previousProviderButton {
                providerButtonVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[\(previousProviderButton)]-10-[\(provider.name)(\(height))]-(>=10)-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
            } else {
                providerButtonVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[\(provider.name)(\(height))]-(>=10)-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
            }
            self.addConstraints(providerButtonHorizontalConstraints + providerButtonVerticalConstraints)
            previousProviderButton = provider.name
        }
    }

    func providerButtonPressed(sender: UIButton) {
        if let title = sender.currentTitle, provider = providersByTitle[title] {
            provider.login(success: success, failure: failure)
        }
    }
}
