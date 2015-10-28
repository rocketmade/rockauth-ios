//
//  RockauthError.swift
//  Pods
//
//  Created by Brayden Morris on 10/23/15.
//
//

import UIKit

public class RockauthError: ErrorType {
    var message: String = "Error"
    public init(message: String) {
        self.message = message
    }
}