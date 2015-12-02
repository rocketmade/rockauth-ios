//
//  Authentication.swift
//  RockauthiOS
//
//  Created by Brandon Roth on 12/2/15.
//  Copyright © 2015 Daniel Gubler. All rights reserved.
//

import Foundation

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

public func ==(lhs: Authetication, rhs: Authetication) -> Bool{
    return lhs.id == rhs.id &&
        lhs.token == rhs.token &&
        lhs.tokenID == rhs.tokenID &&
        lhs.expiration == rhs.expiration &&
        lhs.providerAuthID == rhs.providerAuthID
}