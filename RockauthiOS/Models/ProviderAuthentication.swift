//
//  ProviderAuthentication.swift
//  RockauthiOS
//
//  Created by Brandon Roth on 12/2/15.
//  Copyright © 2015 Daniel Gubler. All rights reserved.
//

import Foundation

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

public func ==(lhs: ProviderAuthentication, rhs: ProviderAuthentication) -> Bool{
    return lhs.id == rhs.id &&
        lhs.userID == rhs.userID &&
        lhs.name == rhs.name
}