//
//  RockAuthSession.swift
//  RockauthiOS
//
//  Created by Brandon Roth on 12/2/15.
//  Copyright © 2015 Daniel Gubler. All rights reserved.
//

import Foundation

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
            self.authentication = Authetication()
            self.authentications = [Authetication]()
            self.providerAuthentications = [ProviderAuthentication]()
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
    }
}