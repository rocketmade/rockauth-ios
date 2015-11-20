//
//  RockauthError.swift
//  Pods
//
//  Created by Brayden Morris on 10/23/15.
//
//

import UIKit

public class RockauthError: ErrorType {
    public var title: String = "Error"
    public var message: String = "Error"
    public var alertController: UIAlertController {
        let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: .Alert)
        let okButton = UIAlertAction(title: "OK", style: .Default, handler:nil)
        alert.addAction(okButton)
        return alert
    }

    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}