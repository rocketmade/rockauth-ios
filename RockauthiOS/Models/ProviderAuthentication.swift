//
//  ProviderAuthentication.swift
//  RockauthiOS
//
//  Created by Brandon Roth on 12/2/15.
//  Copyright © 2015 Daniel Gubler. All rights reserved.
//

import Foundation

public class ProviderAuthentication: NSObject, NSCoding{
    public let name: String
    public let userID: String
    public let id: Int
    
    public override init() {
        self.name = ""
        self.userID = ""
        self.id = 0
    }
    
    public init?(json: [String: AnyObject]) {
        
        guard let name = json["provider"] as? String, let userID = json["providerUserId"] as? String, id = json["id"] as? Int else {
            self.id = 0
            self.userID = ""
            self.name = ""
            super.init()
            return nil
        }
        
        self.id = id
        self.userID = userID
        self.name = name
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.userID = aDecoder.decodeObjectForKey("userID") as! String
        self.id = aDecoder.decodeIntegerForKey("id")
        
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.userID, forKey: "userID")
        aCoder.encodeInteger(self.id, forKey: "id")
    }
}

public func ==(lhs: ProviderAuthentication, rhs: ProviderAuthentication) -> Bool{
    return lhs.id == rhs.id &&
        lhs.userID == rhs.userID &&
        lhs.name == rhs.name
}