//
//  GoogleProvider.swift
//  Pods
//
//  Created by Daniel Gubler on 11/3/15.
//
//

import UIKit

public protocol ConnectWithGoogleDelegate {
    func googleButtonClicked()
}

public class GoogleProvider: SocialProvider {
    
    public static var sharedProvider: SocialProvider? = GoogleProvider()
    public var token: String?
    public var name: String = "google_plus"
    public var secret: String? = nil
    public var userName: String? = nil

    public var iconName: String? = "googleicon"
    public var color = UIColor(colorLiteralRed: 220/255.0, green: 78/255.0, blue: 65/255.0, alpha: 1.0)
    public var prettyName: String = "Google"

    public var delegate: ConnectWithGoogleDelegate?
    
    public init() { }

    public func login(fromViewController viewController: UIViewController, success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        if let delegate = self.delegate {
            delegate.googleButtonClicked()
        } else {
            let e = RockauthError(title: "Connect With Google Delegate not found", message: "You must set the ConnectWithGoogleDelegate")
            failure(error: e)
        }
    }
    public func connect(fromViewController viewController: UIViewController, success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        if let sharedClient = RockauthClient.sharedClient {
            sharedClient.login(self,
                success: { (user) -> Void in
                    success(user: user)
                }, failure: { (error) -> Void in
                    failure(error: error)
            })
        }
    }

    public func logout() {
        // This is how to logout. Must be done in app for now, since Google is a static framework
        // GIDSignIn.sharedInstance().signOut()
    }
}