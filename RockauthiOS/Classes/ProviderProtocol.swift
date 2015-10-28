//
//  ProviderProtocol.swift
//  Pods
//
//  Created by Brayden Morris on 10/19/15.
//
//

import Foundation

public protocol SocialProvider {

    static var sharedProvider: SocialProvider! {get}

    var name: String {get}
    var token: String? {get}
    var secret: String? {get}

    var hash: Dictionary<String, String> {get} // Does not need to be implemented if the default implementation below works.

    var jwtToken: String? {get} // Does not need to be implemented if the default implementation below works.

    func login(success success: () -> Void, failure: (error: ErrorType) -> Void)
}

public extension SocialProvider {
    var hash: Dictionary<String, String> {
        var retVal = [String: String]()
        retVal["provider"] = name
        if let token = token {
            retVal["provider_access_token"] = token
        }
        if let secret = secret {
            retVal["provider_access_token_secret"] = secret
        }
        return retVal
    }

    var jwtToken: String? {
       return ""
    }
}