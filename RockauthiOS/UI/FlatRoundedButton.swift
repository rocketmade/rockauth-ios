//
//  FlatRoundedButton.swift
//  Pods
//
//  Created by Brayden Morris on 11/4/15.
//
//

import UIKit

public class FlatRoundedButton: UIButton {

    init(title: String?, fontSize: CGFloat, color: UIColor?) {
        super.init(frame: CGRectZero)
        if let color = color {
            commonInit(title: title, fontSize: fontSize, color: color)
        }
    }

    init(title: String?, fontSize: CGFloat, color: UIColor?, frame: CGRect) {
        super.init(frame: frame)
        commonInit(title: title, fontSize: fontSize, color: color)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(title: nil, fontSize: nil, color: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(title: nil, fontSize: nil, color: nil)
    }

    func commonInit(title title: String?, fontSize: CGFloat?, color: UIColor?) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(title, forState: UIControlState.Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.clipsToBounds = true
        self.layer.cornerRadius = 3
        if let fontSize = fontSize {
            self.titleLabel?.font = UIFont.systemFontOfSize(fontSize, weight: UIFontWeightSemibold)
        } else {
            self.titleLabel?.font = UIFont.systemFontOfSize(18, weight: UIFontWeightSemibold)
        }
        if let color = color {
            self.setBackgroundImage(color.resizeableImageFromColor(), forState: UIControlState.Normal)
        } else {
            self.setBackgroundImage(UIColor.blackColor().resizeableImageFromColor(), forState: UIControlState.Normal)
        }
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
