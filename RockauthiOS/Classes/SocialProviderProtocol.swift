//
//  ProviderProtocol.swift
//  Pods
//
//  Created by Brayden Morris on 10/19/15.
//
//

import Foundation

public protocol SocialProvider: LoginProvider {

    static var sharedProvider: SocialProvider? {get set}

    var name: String {get}
    var token: String? {get}
    var secret: String? {get}

    var prettyName: String {get} // Should be capitalized and use any styling specific to the provider, eg. "Google+"
    var icon: UIImage? {get}
    var color: UIColor {get}

    var hash: Dictionary<String, String> {get} // Does not need to be implemented if the default implementation below works.

    var jwtTokenKey: String {get} // Does not need to be implemented if the default implementation below works.
    var jwtToken: String? {get set} // Does not need to be implemented if the default implementation below works.
}

public extension SocialProvider {
    var prettyName: String {
        return name.localizedCapitalizedString
    }

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

    var jwtTokenKey: String {
        return "rockauth_" + name + "_provider_key"
    }

    var jwtToken: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey(jwtTokenKey)
        }
        set(newToken) {
            NSUserDefaults.standardUserDefaults().setObject(newToken, forKey: jwtTokenKey)
        }
    }
}