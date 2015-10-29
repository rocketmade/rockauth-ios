//
//  RockauthClient.swift
//  Pods
//
//  Created by Brayden Morris on 10/19/15.
//
//

import UIKit

public class RockauthClient {

    public static var sharedClient: RockauthClient?

    public var user: NSDictionary = NSDictionary()
    public var apiURL: NSURL
    public var clientID: String
    public var clientSecret: String
    public var twitterKey: String?
    public var twitterSecret: String?

    public init(baseURL: NSURL, clientID: String, clientSecret: String) {
        self.apiURL = baseURL
        self.clientID = clientID
        self.clientSecret = clientSecret
    }

    public func login(provider: SocialProvider, success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        let providerAuth = provider.hash
        let params = ["authentication": [
            "auth_type": "assertion",
            "client_id": self.clientID,
            "client_secret": self.clientSecret,
            // these are optional
            //      "device_identifier": "",
            //      "device_description": "",
            //      "device_os": "",
            //      "device_os_version": "",
            "provider_authentication": providerAuth
            ]]

        let request = NSMutableURLRequest(URL: NSURL(string: "\(self.apiURL)authentications.json")!)
        request.HTTPMethod = "POST"
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        } catch {
            print("request failed: \(error)")
        }

        NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(request) { (data, response, error) -> Void in
            let response = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            if let responseDict = response as? NSDictionary {
                print(responseDict)
                success(user: responseDict)
            } else {
                failure(error: error!)
            }
            }.resume()
    }

    public func login(provider: EmailProvider, success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        if let email = provider.email, password = provider.password {
            login(email, password: password, success: success, failure: failure)
        } else {
            failure(error: RockauthError(message: "Email or password not provided"))
        }
    }

    public func login(email: String, password: String, success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        //TODO: Add login with email and password
    }

    public func registerUser(providers: [SocialProvider], success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        registerUser(nil, password: nil, providers: providers, success: success, failure: failure);
    }

    public func registerUser(email: String, password: String, success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        registerUser(email, password: password, providers: nil, success: success, failure: failure)

    }

    public func registerUser(email: String?, password: String?, providers: [SocialProvider]?, success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        // Create user
        let authentication = ["client_id": self.clientID, "client_secret": self.clientSecret]
        var user: Dictionary<String, AnyObject> = ["authentication": authentication]
        var authenticationMethodProvided = false
        if let email = email, password = password {
            user["email"] = email
            user["password"] = password
            authenticationMethodProvided = true
        }
        if let providers = providers {
            var providerAuthentications: Array<Dictionary<String, String>> = []
            for provider in providers {
                providerAuthentications.append(provider.hash)
            }
            user["provider_authentications"] = providerAuthentications
            if providerAuthentications.count > 0 {
                authenticationMethodProvided = true
            }
        }
        if authenticationMethodProvided == false {
            failure(error: RockauthError(message: "No authentication method provided"))
            return
        }

        // Create request
        let params = ["user": user]
        let request = NSMutableURLRequest(URL: NSURL(string: "\(self.apiURL)me.json")!)
        request.HTTPMethod = "POST"
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        } catch {
            failure(error: error)
        }

        NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(request) { (data, response, error) -> Void in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            print(request.description)
            let response = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            if let responseDict = response as? NSDictionary {
                print(responseDict)
                success(user: responseDict)
            }
            print("error: \(error)")
            }.resume()
    }
}