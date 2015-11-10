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

    var providers: [SocialProvider?]!
    var providersByTitle: [String:SocialProvider] = [:]
    var success: ((user: NSDictionary) -> ())!
    var failure: ((error: ErrorType) -> ())!
    var shortFormat: Bool = true
    var parentViewController: UIViewController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit([FacebookProvider()], shortFormat: true, parentViewController: nil, connected: nil, failed: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit([FacebookProvider()], shortFormat: true, parentViewController: nil, connected: nil, failed: nil)
    }

    init(providers: [SocialProvider?], shortFormat: Bool, parentViewController: UIViewController?, connected: (user: NSDictionary) -> (), failed: (error: ErrorType) -> ()) {
        super.init(frame: CGRectZero)
        commonInit(providers, shortFormat: shortFormat, parentViewController: parentViewController, connected: connected, failed: failed)
    }

    func commonInit(providers: [SocialProvider?], shortFormat: Bool, parentViewController: UIViewController?, connected: ((user: NSDictionary) -> ())?, failed: ((error: ErrorType) -> ())?) {
        self.parentViewController = parentViewController
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
        self.shortFormat = shortFormat
    }

    override func layoutSubviews() {
        var views: [String : AnyObject] = [:]
        var previousProviderButton: String? = nil
        var displayedProviders: [SocialProvider?]
        var truncatedProvidersList: Bool
        if shortFormat && (providers.count > 3) {
            displayedProviders = [providers[0], providers[1]]
            truncatedProvidersList = true
        } else {
            displayedProviders = providers
            truncatedProvidersList = false
        }
        for provider in displayedProviders {
            if let provider = provider {
                let title = "Connect with \(provider.prettyName)"
                let providerButton = FlatRoundedButton(title: title, fontSize: 17, color: provider.color)
                providerButton.translatesAutoresizingMaskIntoConstraints = false
                providersByTitle[title] = provider
                providerButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                providerButton.addTarget(self, action: "providerButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
                self.addSubview(providerButton)
                views[provider.name] = providerButton
                let providerButtonHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[\(provider.name)]|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
                let providerButtonVerticalConstraints: [NSLayoutConstraint]
                let height = 50
                if let previousProviderButton = previousProviderButton {
                    providerButtonVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[\(previousProviderButton)]-10-[\(provider.name)(\(height))]-(>=0)-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
                } else {
                    providerButtonVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[\(provider.name)(\(height))]-(>=0)-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
                }
                self.addConstraints(providerButtonHorizontalConstraints + providerButtonVerticalConstraints)
                if let iconName = provider.iconName {
                    if let icon = UIImage(named: iconName, inBundle: NSBundle(forClass: self.classForCoder), compatibleWithTraitCollection: UITraitCollection()) {
                        let iconView = UIImageView(image: icon)
                        iconView.translatesAutoresizingMaskIntoConstraints = false
                        let iconName = provider.name + "_icon"
                        providerButton.addSubview(iconView)
                        views[iconName] = iconView
                        let iconVerticalConstraints = [NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: providerButton, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)]
                        providerButton.layoutIfNeeded()
                        let iconHorizontalConstraints = [NSLayoutConstraint(item: iconView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: providerButton, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: providerButton.frame.height/2),]
                        providerButton.addConstraints(iconHorizontalConstraints + iconVerticalConstraints)
                    }

                }
                previousProviderButton = provider.name
            }
        }
        if truncatedProvidersList {
            if let previousProviderButton = previousProviderButton {
                let otherOptionsButton = UIButton(type: UIButtonType.System)
                otherOptionsButton.translatesAutoresizingMaskIntoConstraints = false
                let otherOptionsFont = UIFont.systemFontOfSize(14, weight: UIFontWeightRegular)
                let otherOptionsAttributes: [String: AnyObject] = [
                    NSFontAttributeName: otherOptionsFont,
                    NSForegroundColorAttributeName: UIColor(white: 161/255.0, alpha: 1)
                ]
                let attributedTitle = NSMutableAttributedString(string: "Other sign in ", attributes: otherOptionsAttributes)
                let otherOptionsString = NSMutableAttributedString(string: "options", attributes: otherOptionsAttributes)
                otherOptionsString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSRange.init(location: 0, length: otherOptionsString.length))
                attributedTitle.appendAttributedString(otherOptionsString)
                otherOptionsButton.setAttributedTitle(attributedTitle, forState: UIControlState.Normal)
                otherOptionsButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
                otherOptionsButton.titleLabel?.textAlignment = NSTextAlignment.Center
                otherOptionsButton.addTarget(self, action: Selector("otherOptionsTapped"), forControlEvents: UIControlEvents.TouchUpInside)
                self.addSubview(otherOptionsButton)
                views["otherOptionsButton"] = otherOptionsButton
                let otherOptionsHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-50-[otherOptionsButton]-50-|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
                let otherOptionsVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[\(previousProviderButton)]-10-[otherOptionsButton]|", options: NSLayoutFormatOptions.DirectionLeftToRight, metrics: nil, views: views)
                self.addConstraints(otherOptionsHorizontalConstraints + otherOptionsVerticalConstraints)
            }
        }
    }

    func otherOptionsTapped() {
        let fullVC = FullConnectWithSocialNetworksViewController(providers: providers, connected: success, failed: failure)
        parentViewController?.navigationController?.pushViewController(fullVC, animated: true)

    }

    func providerButtonPressed(sender: UIButton) {
        if let title = sender.currentTitle, provider = providersByTitle[title] {
            provider.login(success: success, failure: failure)
        }
    }
}
