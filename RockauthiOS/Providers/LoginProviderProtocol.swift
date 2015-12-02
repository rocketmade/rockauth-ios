//
//  LoginProvider.swift
//  Pods
//
//  Created by Brayden Morris on 10/27/15.
//
//

import UIKit

public protocol LoginProvider {

    func login(fromViewController viewController: UIViewController, success: loginSuccess, failure: loginFailure)
    func logout()

}
