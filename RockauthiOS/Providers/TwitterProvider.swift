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
    public var userName: String?
    public var email: String? = nil
    public var firstName: String? = nil
    public var lastName: String? = nil

    public var iconName: String? = "icon-twitter"
    public var color: UIColor = UIColor(colorLiteralRed: 0x55/255.0, green: 0xac/255.0, blue: 0xee/255.0, alpha: 1.0)
    public var delegate: ConnectWithTwitterDelegate?

    public init(token: String, secret: String) {
        self.token = token
        self.secret = secret
    }

    public func login(fromViewController viewController: UIViewController, success: loginSuccess, failure: loginFailure) {
        if let delegate = self.delegate {
            delegate.twitterButtonClicked()
        } else {
            let e = RockauthError(title: "Connect With Twitter Delegate not found", message: "You must set the ConnectWithTwitterDelegate")
            failure(error: e)
        }
    }

    public func connect(fromViewController viewController: UIViewController, success: loginSuccess, failure: loginFailure) {
        if let sharedClient = RockauthClient.sharedClient {
            sharedClient.login(self, success: success, failure: failure)
        }
    }

    public func logout() {
    }
}
