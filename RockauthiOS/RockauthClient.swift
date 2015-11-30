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
        
        var authentication: [String: AnyObject] = [
            "auth_type": "assertion",
            "client_id": self.clientID,
            "client_secret": self.clientSecret,
            "provider_authentication": provider.hash,
            "device_description": UIDevice.currentDevice().name,
            "device_os_version": UIDevice.currentDevice().systemVersion,
            "device_os": UIDevice.currentDevice().systemName
        ]
        
        //the identifier for vendor is optional so we should only include the key in the hash if it exists.
        if let identifier = UIDevice.currentDevice().identifierForVendor?.UUIDString {
           authentication["device_identifier"] = identifier
        }

        if let userName = provider.userName {
            authentication["username"] = userName
        }
        if let firstName = provider.firstName {
            authentication["first_name"] = firstName
        }
        if let lastName = provider.lastName {
            authentication["last_name"] = lastName
        }
        if let email = provider.email {
            authentication["email"] = email
        }

        let params = ["authentication": authentication]
        
        let request = self.jsonHTTPRequestWithPath("authentications.json")
        request.HTTPMethod = "POST"
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
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
        let request = self.jsonHTTPRequestWithPath("authentications.json")
        request.HTTPMethod = "POST"
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
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
    
    private func jsonHTTPRequestWithPath(path: String) -> NSMutableURLRequest {
        let url = self.apiURL.URLByAppendingPathComponent(path)
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    public func logout(success: (response: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        let data = [String:String]()
        let request = self.jsonHTTPRequestWithPath("me.json")
        request.HTTPMethod = "DELETE"
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted)
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

typealias JWT = String

class Session {
    var authentication: Authetication
    var user: RockauthUser
    let providerAuthentications: [ProviderAuthentication]
    
    init?(json: [String: AnyObject?]) {
        
        guard let authenticationHash = json["authentication"] as? [String: AnyObject?], auth = Authetication(json: authenticationHash),
            let usersArray = json["users"] as? [[String: AnyObject?]], userHash = usersArray.first, user = RockauthUser(json: userHash) else {
                self.authentication = Authetication()
                self.user = RockauthUser()
                self.providerAuthentications = [ProviderAuthentication]()
                return nil
        }
        
        self.authentication = auth
        self.user = user
        
        //pull the provider authentications out
        if let providerAuths = json["provider_authentications"] as? [[String: AnyObject?]] {
            var collector = [ProviderAuthentication]()
            for hash in providerAuths {
                if let auth = ProviderAuthentication(json: hash) {
                    collector.append(auth)
                }
            }
            self.providerAuthentications = collector
        }
        else{
            self.providerAuthentications = [ProviderAuthentication]()
        }
    }
}

class RockauthUser {
    let id: Int
    let email: String?
    let firstName: String?
    let lastName: String?
    
    init() {
        self.id = 0
        self.email = ""
        self.firstName = ""
        self.lastName = ""
    }
    
    init?(json: [String: AnyObject?]) {
        
        guard let id = json["id"] as? Int else {
            self.id = 0
            self.email = ""
            self.firstName = ""
            self.lastName = ""
            return nil
        }
        
        self.id = id
        self.email = json["email"] as? String
        self.firstName = json["first_name"] as? String
        self.lastName = json["last_name"] as? String
    }
}

class Authetication {
    let id: Int
    let jwt: JWT
    let tokenID: String
    let expiration: NSDate
    let providerAuthID: Int?
    
    init() {
        self.id = 0
        self.jwt = ""
        self.tokenID = ""
        self.expiration = NSDate()
        self.providerAuthID = nil
    }
    
    init?(json: [String: AnyObject?]) {
        
        guard let id = json["id"] as? Int, jwt = json["token"] as? String, tokenID = json["token_id"] as? String, expiration = json["expiration"] as? Int else {
            self.id = 0
            self.jwt = ""
            self.tokenID = ""
            self.expiration = NSDate()
            self.providerAuthID = nil
            return nil
        }
        
        self.id = id
        self.jwt = jwt
        self.tokenID = tokenID
        self.expiration = NSDate(timeIntervalSince1970: NSTimeInterval(expiration))
        self.providerAuthID = json["provider_authentication_id"] as? Int
    }
}

class ProviderAuthentication {
    let name: String
    let userID: String
    let id: Int
    
    init?(json: [String: AnyObject?]) {
       
        guard let name = json["provider"] as? String, let userID = json["provider_user_id"] as? String, id = json["id"] as? Int else {
            self.id = 0
            self.userID = ""
            self.name = ""
            return nil
        }
        
        self.id = id
        self.userID = userID
        self.name = name
    }
}