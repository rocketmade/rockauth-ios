//
//  Authentication.swift
//  RockauthiOS
//
//  Created by Brandon Roth on 12/2/15.
//  Copyright © 2015 Daniel Gubler. All rights reserved.
//

import Foundation

public class Authentication: NSObject, NSCoding {
    public let id: Int
    public let token: JWT
    public let tokenID: String
    public let expiration: NSDate
    public let providerAuthID: Int?
    
    override init() {
        self.id = 0
        self.token = ""
        self.tokenID = ""
        self.expiration = NSDate()
        self.providerAuthID = nil
        super.init()
    }
    
    init?(json: [String: AnyObject]) {
        
        guard let id = json["id"] as? Int, jwt = json["token"] as? String, tokenID = json["tokenId"] as? String, expiration = json["expiration"] as? Int else {
            self.id = 0
            self.token = ""
            self.tokenID = ""
            self.expiration = NSDate()
            self.providerAuthID = nil
            super.init()
            return nil
        }
        
        self.id = id
        self.token = jwt
        self.tokenID = tokenID
        self.expiration = NSDate(timeIntervalSince1970: NSTimeInterval(expiration))
        self.providerAuthID = json["providerAuthenticationId"] as? Int
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeIntegerForKey("id")
        self.token = aDecoder.decodeObjectForKey("token") as! JWT
        self.tokenID = aDecoder.decodeObjectForKey("tokenID") as! String
        self.expiration = aDecoder.decodeObjectForKey("expiration") as! NSDate
        self.providerAuthID = (aDecoder.decodeObjectForKey("providerAuthID") as? NSNumber)?.integerValue
        
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.id, forKey: "id")
        aCoder.encodeObject(self.token, forKey: "token")
        aCoder.encodeObject(self.tokenID, forKey: "tokenID")
        aCoder.encodeObject(self.expiration, forKey: "expiration")
        
        if let value = self.providerAuthID {
            aCoder.encodeObject(NSNumber(integer: value), forKey: "providerAuthID")
        }
    }
}

public func ==(lhs: Authentication, rhs: Authentication) -> Bool{
    return lhs.id == rhs.id &&
        lhs.token == rhs.token &&
        lhs.tokenID == rhs.tokenID &&
        lhs.expiration == rhs.expiration &&
        lhs.providerAuthID == rhs.providerAuthID
}