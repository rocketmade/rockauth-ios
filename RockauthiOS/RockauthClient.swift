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

        // TODO: fix this so it doesn't call success on 400 errors
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
            failure(error: RockauthError(title: "Error Signing In", message: "Email or password not provided"))
        }
    }

    public func login(email: String?, password: String?, success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        var authentication = ["client_id": self.clientID, "client_secret": self.clientSecret, "auth_type": "password"]
        if let email = email, password = password {
            authentication["username"] = email
            authentication["password"] = password
        }
        let params = ["authentication": authentication]
        // Create request
        let request = NSMutableURLRequest(URL: NSURL(string: "\(self.apiURL)authentications.json")!)
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
                if let errorObject = responseDict.objectForKey("error") {
                    let title: String
                    if let t = errorObject["message"] {
                        title = t as! String
                    } else {
                        title = "Error Signing In"
                    }
                    var e: RockauthError = RockauthError(title: title, message: "Could not sign in user")
                    if let validationErrors = errorObject["validation_errors"] {
                        var message = ""
                        print(validationErrors)
                        for key in (validationErrors as! NSDictionary).allKeys {
                            message += "\(key.capitalizedString) \(validationErrors!.valueForKey(key as! String)![0])\n"
                        }
                        e = RockauthError(title: title, message: message)
                    }
                    failure(error: e)
                } else {
                    success(user: responseDict)
                }
            } else if let error = error {
                failure(error: error)
            }
            }.resume()
    }

    public func logout(success: (response: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        let data = [String:String]()
        let request = NSMutableURLRequest(URL: NSURL(string: "\(self.apiURL)me.json")!)
        request.HTTPMethod = "DELETE"
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        } catch {
            failure(error: error)
        }
        NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(request) { (data, response, error) -> Void in
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            print(request.description)
            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            if let responseDict = json as? NSDictionary {
                if let errorObject = responseDict.objectForKey("error") {
                    let title: String
                    if let t = errorObject["message"] {
                        title = t as! String
                    } else {
                        title = "Error Logging Out"
                    }
                    let e: RockauthError = RockauthError(title: title, message: "Could not log out user")
                    failure(error: e)
                } else {
                    success(response: responseDict)
                }
            } else if let error = error {
                failure(error: error)
            }
            }.resume()
    }

    public func registerUser(providers: [SocialProvider], success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        registerUser(nil, lastName: nil, email: nil, password: nil, providers: providers, success: success, failure: failure);
    }

    public func registerUser(firstName: String?, lastName: String?, email: String, password: String, success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        registerUser(firstName, lastName: lastName, email: email, password: password, providers: nil, success: success, failure: failure)

    }

    public func registerUser(firstName: String?, lastName: String?, email: String?, password: String?, providers: [SocialProvider]?, success: (user: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        // Create user
        let authentication = ["client_id": self.clientID, "client_secret": self.clientSecret]
        var user: Dictionary<String, AnyObject> = ["authentication": authentication]
        var authenticationMethodProvided = false
        if let email = email, password = password {
            user["email"] = email
            user["password"] = password
            authenticationMethodProvided = true
        }
        if let firstName = firstName {
            user["first_name"] = firstName
        }
        if let lastName = lastName {
            user["last_name"] = lastName
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
            failure(error: RockauthError(title: "Error Signing Up", message: "No authentication method provided"))
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
                if let errorObject = responseDict.objectForKey("error") {
                    let title: String
                    if let t = errorObject["message"] {
                        title = t as! String
                    } else {
                        title = "Error Signing Up"
                    }
                    var e: RockauthError = RockauthError(title: title, message: "User could not be created")
                    if let validationErrors = errorObject["validation_errors"] {
                        var message = ""
                        for key in (validationErrors as! NSDictionary).allKeys {
                            message += "\(key.capitalizedString) \(validationErrors!.valueForKey(key as! String)![0])\n"
                        }
                        e = RockauthError(title: title, message: message)
                    }
                    failure(error: e)
                } else {
                    success(user: responseDict)
                }
            } else if let error = error {
                failure(error: error)
            }
            }.resume()
    }
}