//
//  TwitterProvider.swift
//  RockauthiOS
//
//  Created by Cody Mace on 10/27/15.
//  Copyright © 2015 Daniel Gubler. All rights reserved.
//

import UIKit

public protocol ConnectWithTwitterDelegate {
    func twitterButtonClicked()
}

public class TwitterProvider: SocialProvider {

    public static var sharedProvider: SocialProvider?

    public var token: String?
    public var name: String = "twitter"
    public var secret: String?

    public var iconName: String? = "icon-twitter"
    public var color: UIColor = UIColor(colorLiteralRed: 0x55/255.0, green: 0xac/255.0, blue: 0xee/255.0, alpha: 1.0)
    public var delegate: ConnectWithTwitterDelegate?

    public init(token: String, secret: String) {
        self.token = token
        self.secret = secret
    }

    public func login(fromViewController viewController: UIViewController, success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        if let delegate = self.delegate {
            delegate.twitterButtonClicked()
        } else {
            let e = RockauthError(title: "Connect With Twitter Delegate not found", message: "You must set the ConnectWithTwitterDelegate")
            failure(error: e)
        }
    }

    public func connect(fromViewController viewController: UIViewController, success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        if let sharedClient = RockauthClient.sharedClient {
            sharedClient.login(self, success: { (user) -> Void in
                success(user: user)
                }, failure: { (error) -> Void in
                    failure(error: error)
            })
        }
    }

    public func logout() {
    }
}
