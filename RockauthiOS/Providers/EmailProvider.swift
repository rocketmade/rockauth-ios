//
//  EmailProvider.swift
//  Pods
//
//  Created by Brayden Morris on 10/27/15.
//
//

import UIKit

public class EmailProvider: LoginProvider {
    var email: String?
    var password: String?

    public init() {}

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }

    public func login(fromViewController viewController: UIViewController, success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        if let client = RockauthClient.sharedClient {
            client.login(self, success: success, failure: failure)
        } else {
            failure(error: RockauthError(title: "Error Signing In", message: "RockauthClient.sharedClient is probably not initialized"))
        }
    }

    public func logout() {
    }
}
