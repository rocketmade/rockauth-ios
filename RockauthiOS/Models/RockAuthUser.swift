//
//  RockAuthUser.swift
//  RockauthiOS
//
//  Created by Brandon Roth on 12/2/15.
//  Copyright © 2015 Daniel Gubler. All rights reserved.
//

import Foundation

public class RockauthUser: NSObject, NSCoding {
    public let id: Int
    public let email: String?
    public let firstName: String?
    public let lastName: String?
    
    override init() {
        self.id = 0
        self.email = ""
        self.firstName = ""
        self.lastName = ""
        
        super.init()
    }
    
    init?(json: [String: AnyObject]) {
        
        guard let id = json["id"] as? Int else {
            self.id = 0
            self.email = ""
            self.firstName = ""
            self.lastName = ""
            super.init()
            return nil
        }
        
        self.id = id
        self.email = json["email"] as? String
        self.firstName = json["firstName"] as? String
        self.lastName = json["lastName"] as? String
        
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeIntegerForKey("id")
        self.email = aDecoder.decodeObjectForKey("email") as! String
        self.firstName = aDecoder.decodeObjectForKey("firstName") as! String
        self.lastName = aDecoder.decodeObjectForKey("lastName") as! String
        
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.id, forKey: "id")
        aCoder.encodeObject(self.email, forKey: "email")
        aCoder.encodeObject(self.firstName, forKey: "firstName")
        aCoder.encodeObject(self.lastName, forKey: "lastName")
    }
}