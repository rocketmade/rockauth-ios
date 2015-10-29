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

    init() {}

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }

    public func login(success success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
    }

    public func logout() {
    }
}
