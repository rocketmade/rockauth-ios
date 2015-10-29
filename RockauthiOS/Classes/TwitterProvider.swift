//
//  TwitterProvider.swift
//  RockauthiOS
//
//  Created by Cody Mace on 10/27/15.
//  Copyright © 2015 Daniel Gubler. All rights reserved.
//

import UIKit

public class TwitterProvider: SocialProvider {

    public static var sharedProvider: SocialProvider! = TwitterProvider()
    public var token: String?
    public var name: String = "twitter"
    public var secret: String? = nil

    public init() {

    }

    public init(token: String, secret: String) {
        self.token = token
        self.secret = secret
    }

    public func login(success success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
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
