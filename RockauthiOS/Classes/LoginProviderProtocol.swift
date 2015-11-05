//
//  LoginProvider.swift
//  Pods
//
//  Created by Brayden Morris on 10/27/15.
//
//

import UIKit

public protocol LoginProvider {

    func login(success success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void)
    func logout()

}
