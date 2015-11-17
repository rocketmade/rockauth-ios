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

    var name: String {get} // Identifier used by the rockauth server.
    var token: String? {get}
    var secret: String? {get}

    var prettyName: String {get} // Implement if the name isn't simply converted by the default impmlementation below. Should be capitalized and use any styling specific to the provider, eg. "Google+"
    var iconName: String? {get} // Filename of the icon image.
    var color: UIColor {get} // Background color for the "Connect with ..." button

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