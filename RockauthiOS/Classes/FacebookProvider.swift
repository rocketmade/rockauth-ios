//
//  FacebookProvider.swift
//  Pods
//
//  Created by Daniel Gubler on 10/19/15.
//
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

public class FacebookProvider: SocialProvider {

    public static var sharedProvider: SocialProvider? = FacebookProvider()

    public var name: String = "facebook"
    public var token :String? {
        if FBSDKAccessToken.currentAccessToken() != nil {
            return FBSDKAccessToken.currentAccessToken().tokenString
        }
        return nil
    }
    public var secret: String? = nil

    public var iconName: String? = "icon-facebook"
    public var color: UIColor = UIColor(colorLiteralRed: 0x3b/255.0, green: 0x59/255.0, blue: 0x98/255.0, alpha: 1.0)

    public init() {
        FBSDKApplicationDelegate.sharedInstance().application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: nil)
    }

    public func login(success success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            if let sharedClient = RockauthClient.sharedClient {
                sharedClient.login(self, success: { (user) -> Void in
                    success(user: user)
                    }, failure: { (error) -> Void in
                        failure(error: error)
                })
            } else {
                failure(error: RockauthError(message: "RockauthClient.sharedClient is probably not initialized"))
            }
            return
        }
        let manager = FBSDKLoginManager()
        manager.logInWithReadPermissions(["public_profile"], fromViewController: UIApplication.sharedApplication().keyWindow?.rootViewController) { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if error != nil {
                failure(error: error)
            } else if let result = result {
                if result.isCancelled {
                    failure(error: RockauthError(message: "Facebook login cancelled"))
                } else {
                    if let sharedClient = RockauthClient.sharedClient {
                        sharedClient.login(self, success: { (user) -> Void in
                            success(user: user)
                            }, failure: { (error) -> Void in
                                failure(error: error)
                        })
                    }
                }
            } else {
                // no result AND no error; this shouldn't happen
                failure(error: RockauthError(message: "This shouldn't happen"))
            }
        }
    }

    public func logout() {
        let manager = FBSDKLoginManager()
        manager.logOut()
    }
}
