//
//  RockauthClient.swift
//  Pods
//
//  Created by Brayden Morris on 10/19/15.
//
//

import UIKit

public typealias loginSuccess = (session: RockAuthSession) -> Void
public typealias loginFailure = (error: ErrorType) -> Void

public class RockauthClient {

    public static var sharedClient: RockauthClient?

    public var user: NSDictionary = NSDictionary()
    public var apiURL: NSURL
    public var clientID: String
    public var clientSecret: String
    public var twitterKey: String?
    public var twitterSecret: String?
    
    private let session: NSURLSession

    public init(baseURL: NSURL, clientID: String, clientSecret: String) {
        self.apiURL = baseURL
        self.clientID = clientID
        self.clientSecret = clientSecret
        
        self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    deinit {
        self.session.invalidateAndCancel()
    }

    public func login(provider: SocialProvider, success: loginSuccess, failure: loginFailure) {
        
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
        self.login(params, success: success, failure: failure)
    }

    public func login(provider: EmailProvider, success: loginSuccess, failure: loginFailure) {
        if let email = provider.email, password = provider.password {
            login(email, password: password, success: success, failure: failure)
        } else {
            failure(error: RockauthError(title: "Error Signing In", message: "Email or password not provided"))
        }
    }

    public func login(email: String?, password: String?, success: loginSuccess, failure: loginFailure) {
        var authentication = ["client_id": self.clientID, "client_secret": self.clientSecret, "auth_type": "password"]
        if let email = email, password = password {
            authentication["username"] = email
            authentication["password"] = password
        }
        let params = ["authentication": authentication]
        self.login(params, success: success, failure: failure)
    }
    
    private func login(params: [String: AnyObject], success: (session: RockAuthSession) -> Void, failure: (error: ErrorType) -> Void) {
        let request = self.jsonHTTPRequestWithPath("api/authentications")
        request.HTTPMethod = "POST"
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch {
            failure(error: error)
        }
        
        self.loginOrSignupWithRequest(request, success: success, failure: failure)
    }
    
    private func loginOrSignupWithRequest(request: NSURLRequest, success: (session: RockAuthSession) -> Void, failure: (error: ErrorType) -> Void) {
        self.session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            //exit now if there was an error with the request
            if let error = error {
                failure(error: error)
                return
            }
            // Uncomment below to display the json response
//            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print(dataString)
            guard let responseJSON = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] else {
                failure(error: RockauthError(title: "Bad response", message: "Unexpected response from server, non json repsonse recieved"))
                return
            }
            
            if let responseError = self.errorFromResponse(responseJSON) {
                failure(error: responseError)
                return
            }
            
            guard let session = RockAuthSession(json: responseJSON) else {
                failure(error: RockauthError(title: "Bad response", message: "Unable to match authentications in response"))
                return
            }
            
            success(session: session)
            
            }.resume()
    }
    
    private func errorFromResponse(hash: [String: AnyObject?]) -> ErrorType? {
       
        if let errorObject = hash["error"] as? [String: AnyObject] {
            let title: String = errorObject["message"] as? String ?? "Error Signing In"
            var e: RockauthError = RockauthError(title: title, message: "Could not sign in user")
            if let validationErrors = errorObject["validation_errors"] {
                var message = ""
                for key in (validationErrors as! NSDictionary).allKeys {
                    message += "\(key.capitalizedString) \(validationErrors.valueForKey(key as! String)![0])\n"
                }
                
                e = RockauthError(title: title, message: message)
            }
            
            return e
        }
        return nil
    }
    
    private func jsonHTTPRequestWithPath(path: String) -> NSMutableURLRequest {
        let url = self.apiURL.URLByAppendingPathComponent(path)
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    public func logout(authToken: String) {
        let data = [String:String]()
        let request = self.jsonHTTPRequestWithPath("api/authentications")
        request.addValue("BEARER \(authToken)", forHTTPHeaderField: "AUTHORIZATION")
        request.HTTPMethod = "DELETE"
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted)
        } catch {
            #if DEBUG
                print("Error logging out: \(errorObject)")
            #endif
        }
        self.session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            if let responseDict = json as? NSDictionary {
                if let errorObject = responseDict.objectForKey("error") {
                    #if DEBUG
                        print("Error logging out: \(errorObject)")
                    #endif
                }
            } else {
                #if DEBUG
                    print("Error logging out: \(errorObject)")
                #endif
            }
            }.resume()
    }

    public func registerUser(providers: [SocialProvider], success: loginSuccess, failure: loginFailure) {
        registerUser(nil, lastName: nil, email: nil, password: nil, providers: providers, success: success, failure: failure);
    }

    public func registerUser(firstName: String?, lastName: String?, email: String, password: String, success: loginSuccess, failure: loginFailure) {
        registerUser(firstName, lastName: lastName, email: email, password: password, providers: nil, success: success, failure: failure)
    }
    
    public func registerUser(firstName: String?, lastName: String?, email: String?, password: String?, providers: [SocialProvider]?, success: loginSuccess, failure: loginFailure) {
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
        let request = self.jsonHTTPRequestWithPath("api/me.json")
        request.HTTPMethod = "POST"
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch {
            failure(error: error)
        }
        
        self.loginOrSignupWithRequest(request, success: success, failure: failure)
    }
}









