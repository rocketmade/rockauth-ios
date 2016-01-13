//
//  RockAuthUser.swift
//  RockauthiOS
//
//  Created by Brandon Roth on 12/2/15.
//  Copyright © 2015 Daniel Gubler. All rights reserved.
//

import Foundation

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
        self.firstName = json["firstName"] as? String
        self.lastName = json["lastName"] as? String
    }
}