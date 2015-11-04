//
//  ConnectWithTwitterButton.swift
//  RockauthiOS
//
//  Created by Cody Mace on 10/30/15.
//  Copyright © 2015 Rocketmade. All rights reserved.
//

import UIKit

public class TwitterButton: UIButton {

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 85/255.0, green: 172/255.0, blue: 238/255.0, alpha: 1)
        self.setTitle("Connect with Twitter", forState: .Normal)
        self.titleLabel?.font = UIFont.boldSystemFontOfSize(18)
        self.clipsToBounds = true
        self.layer.cornerRadius = 3

        let bundle = NSBundle(forClass: self.classForCoder)
        let logo = UIImage(named: "icon-twitter", inBundle: bundle, compatibleWithTraitCollection: UITraitCollection())
        self.setImage(logo, forState: .Normal)
        self.setImage(logo, forState: .Highlighted)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView!.frame.origin.x = 14
        self.titleLabel!.frame.origin.x = self.frame.width/2 - self.titleLabel!.frame.size.width/2
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var highlighted: Bool {
        get {
            return super.highlighted
        }
        set {
            if newValue {
                self.backgroundColor = UIColor(red: 62/255.0, green: 149/255.0, blue: 215/255.0, alpha: 1)
                self.titleLabel?.alpha = 0.6
                self.imageView?.alpha = 0.6

            } else {
                self.backgroundColor = UIColor(red: 85/255.0, green: 172/255.0, blue: 238/255.0, alpha: 1)
                self.titleLabel?.alpha = 1.0
                self.imageView?.alpha = 1.0
            }
        }
    }
}
