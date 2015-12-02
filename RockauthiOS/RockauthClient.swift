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
        let request = self.jsonHTTPRequestWithPath("authentications.json")
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
            
            guard let responseJSON = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] else {
                failure(error: RockauthError(title: "Bad response", message: "Unexpected response from server, non json repsonse recieved"))
                return
            }
            
            if let responseError = self.errorFromResponse(responseJSON) {
                failure(error: responseError)
                return
            }
            
            guard let session = RockAuthSession(json: responseJSON) else {
                failure(error: RockauthError(title: "Bad response", message: "Missing authentication in response"))
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

    public func logout(success: (response: NSDictionary) -> Void, failure: (error: ErrorType) -> Void) {
        let data = [String:String]()
        let request = self.jsonHTTPRequestWithPath("me.json")
        request.HTTPMethod = "DELETE"
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted)
        } catch {
            failure(error: error)
        }
        self.session.dataTaskWithRequest(request) { (data, response, error) -> Void in
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
        let request = self.jsonHTTPRequestWithPath("me.json")
        request.HTTPMethod = "POST"
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch {
            failure(error: error)
        }
        
        self.loginOrSignupWithRequest(request, success: success, failure: failure)
    }
}

public typealias JWT = String

public class RockAuthSession {
    let authentication: Authetication
    let authentications: [Authetication]
    let user: RockauthUser
    let providerAuthentications: [ProviderAuthentication]
    
    init?(json: [String: AnyObject?]) {
        
        //local variables to pull out of the hash.  We use local variables so we can make a master nil check at the end so we can know if we should fail or not.
        //We fail in one place because of a compiler bug where we have to initialize all variables before returning nil.
        var localUser: RockauthUser?
        var localAuthentication: Authetication?
        var localAuthentications: [Authetication]?
        
        //User will either be in a collection or a top level hash.  This is done for consistencey but in practice there will only ever be one user
        if let usersArray = json["users"] as? [[String: AnyObject]], hash = usersArray.first, user = RockauthUser(json: hash) {
            localUser = user
        }
        else if let hash = json["user"] as? [String: AnyObject], user = RockauthUser(json: hash){
            localUser = user
        }
        
        //Same approach with authentication
        if let hash = json["authentication"] as? [String: AnyObject], let auth = Authetication(json: hash) {
            //In this case only 1 auth came down so that is the one we should use and the user object will NOT have a authentication_id key
            localAuthentications = [Authetication]()
            localAuthentications!.append(auth)
            localAuthentication = auth
        }
        else if let array = json["authentications"] as? [[String: AnyObject]] {
            localAuthentications = [Authetication]()
            for hash in array {
                if let auth = Authetication(json: hash) {
                localAuthentications!.append(auth)
                }
            }
            
            //In this case the user object should have the authentication_id key so we can look through all our auths and find the one we should be using for this session
            if let userHash = json["user"] as? [String: AnyObject], authID = userHash["authentication_id"] as? Int{
                localAuthentication = localAuthentications!.filter{ $0.id == authID}.first
            }
        }
        
        //At this point we have collected all our values in the localy named ones so we can unwrap and assign them.  If they are non nil at this point we can fail
        if let u = localUser, let auth = localAuthentication, let auths = localAuthentications {
            self.user = u
            self.authentication = auth
            self.authentications = auths
        }
        else {
            self.user = RockauthUser()
            self.authentication = Authetication()
            self.authentications = [Authetication]()
            self.providerAuthentications = [ProviderAuthentication]()
            return nil
        }
        
        //pull the provider authentications out
        if let providerAuths = json["provider_authentications"] as? [[String: AnyObject]] {
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

public class RockauthUser {
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
    
    init?(json: [String: AnyObject]) {
        
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

public class Authetication: Equatable{
    let id: Int
    let token: JWT
    let tokenID: String
    let expiration: NSDate
    let providerAuthID: Int?
    
    init() {
        self.id = 0
        self.token = ""
        self.tokenID = ""
        self.expiration = NSDate()
        self.providerAuthID = nil
    }
    
    init?(json: [String: AnyObject]) {
        
        guard let id = json["id"] as? Int, jwt = json["token"] as? String, tokenID = json["token_id"] as? String, expiration = json["expiration"] as? Int else {
            self.id = 0
            self.token = ""
            self.tokenID = ""
            self.expiration = NSDate()
            self.providerAuthID = nil
            return nil
        }
        
        self.id = id
        self.token = jwt
        self.tokenID = tokenID
        self.expiration = NSDate(timeIntervalSince1970: NSTimeInterval(expiration))
        self.providerAuthID = json["provider_authentication_id"] as? Int
    }
}

public class ProviderAuthentication: Equatable{
    let name: String
    let userID: String
    let id: Int
    
    init?(json: [String: AnyObject]) {
       
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

public func ==(lhs: Authetication, rhs: Authetication) -> Bool{
    return lhs.id == rhs.id &&
    lhs.token == rhs.token &&
    lhs.tokenID == rhs.tokenID &&
    lhs.expiration == rhs.expiration &&
    lhs.providerAuthID == rhs.providerAuthID
}

public func ==(lhs: ProviderAuthentication, rhs: ProviderAuthentication) -> Bool{
    return lhs.id == rhs.id &&
    lhs.userID == rhs.userID &&
    lhs.name == rhs.name
}

