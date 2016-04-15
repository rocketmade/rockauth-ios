//
//  RockAuthSession.swift
//  RockauthiOS
//
//  Created by Brandon Roth on 12/2/15.
//  Copyright © 2015 Daniel Gubler. All rights reserved.
//

import Foundation

public typealias JWT = String

public class RockAuthSession: NSObject, NSCoding {
    public let authentication: Authentication
    public let authentications: [Authentication]
    public let user: RockauthUser
    public let providerAuthentications: [ProviderAuthentication]
    public let rawJSON: [String: AnyObject]
    
    public init?(json: [String: AnyObject]) {
        
        //Storing the raw data that made up this object so that you have access to addition info which may be passed that doesn't get parsed by this class
        //or it's children
        self.rawJSON = json
        
        //local variables to pull out of the hash.  We use local variables so we can make a master nil check at the end so we can know if we should fail or not.
        //We fail in one place because of a compiler bug where we have to initialize all variables before returning nil.
        var localUser: RockauthUser?
        var localAuthentication: Authentication?
        var localAuthentications: [Authentication]?
        
        //User will either be in a collection or a top level hash.  This is done for consistencey but in practice there will only ever be one user
        if let usersArray = json["users"] as? [[String: AnyObject]], hash = usersArray.first, user = RockauthUser(json: hash) {
            localUser = user
        }
        else if let hash = json["user"] as? [String: AnyObject], user = RockauthUser(json: hash){
            localUser = user
        }
        
        //Same approach with authentication
        if let hash = json["authentication"] as? [String: AnyObject], let auth = Authentication(json: hash) {
            //In this case only 1 auth came down so that is the one we should use and the user object will NOT have a authentication_id key
            localAuthentications = [Authentication]()
            localAuthentications!.append(auth)
            localAuthentication = auth
        }
        else if let array = json["authentications"] as? [[String: AnyObject]] {
            localAuthentications = [Authentication]()
            for hash in array {
                if let auth = Authentication(json: hash) {
                    localAuthentications!.append(auth)
                }
            }
            
            //In this case the meta object should have the primaryResourceId key so we can look through all our auths and find the one we should be using for this session
            if let meta = json["meta"] as? [String: AnyObject], authID = meta["primaryResourceId"] as? Int{
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
            self.authentication = Authentication()
            self.authentications = [Authentication]()
            self.providerAuthentications = [ProviderAuthentication]()
            super.init()
            return nil
        }
        
        //pull the provider authentications out
        if let providerAuths = json["providerAuthentications"] as? [[String: AnyObject]] {
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
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.authentication = aDecoder.decodeObjectForKey("authentication") as! Authentication
        self.authentications = aDecoder.decodeObjectForKey("authentications") as! [Authentication]
        self.user = aDecoder.decodeObjectForKey("user") as! RockauthUser
        self.providerAuthentications = aDecoder.decodeObjectForKey("providerAuthentications") as! [ProviderAuthentication]
        self.rawJSON = aDecoder.decodeObjectForKey("rawJSON") as! [String: AnyObject]
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.authentication, forKey: "authentication")
        aCoder.encodeObject(self.authentications, forKey: "authentications")
        aCoder.encodeObject(self.user, forKey: "user")
        aCoder.encodeObject(self.providerAuthentications, forKey: "providerAuthentications")
        aCoder.encodeObject(self.rawJSON, forKey: "rawJSON")
    }
}