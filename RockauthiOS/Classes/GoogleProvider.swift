//
//  GoogleProvider.swift
//  Pods
//
//  Created by Daniel Gubler on 11/3/15.
//
//

import UIKit

public class GoogleProvider: SocialProvider {
    
    public static var sharedProvider: SocialProvider? = GoogleProvider()
    public var token: String?
    public var name: String = "google_plus"
    public var secret: String? = nil

    public var iconName: String? = nil
    public var color = UIColor(colorLiteralRed: 0x42/255.0, green: 0x85/255.0, blue: 0xf4/255.0, alpha: 1.0)
    public var prettyName: String = "Google"
    
    public init() { }
    
    public func login(success success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
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