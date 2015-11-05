//
//  Created by Brandon Roth on 10/7/14.
//

import Foundation
import UIKit

extension UIColor{

    class func RGBColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: 1)
    }

    class func RGBColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: CGFloat(alpha/255.0))
    }

    public class func hexColor(hexValue: Int) -> UIColor {
        let red = (hexValue >> 16) & 0xFF
        let green = (hexValue >> 8) & 0xFF
        let blue = hexValue & 0xFF
        return RGBColor(CGFloat(red), green: CGFloat(green), blue: CGFloat(blue))
    }

    // Alpha [0 1]
    class func hexColor(hexValue: Int, alpha: CGFloat) -> UIColor {
        let red = (hexValue >> 16) & 0xFF
        let green = (hexValue >> 8) & 0xFF
        let blue = hexValue & 0xFF
        return RGBColor(CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: alpha*255)
    }

    class func colorBetweenColor(startColor: UIColor, endColor: UIColor, percent: CGFloat) -> UIColor {
        let startComponents = startColor.components()
        let endComponents = endColor.components()

        let red = startComponents.red + percent * (endComponents.red - startComponents.red)
        let green = startComponents.green + percent * (endComponents.green - startComponents.green)
        let blue = startComponents.blue + percent * (endComponents.blue - startComponents.blue)
        let alpha = startComponents.alpha + percent * (endComponents.alpha - startComponents.alpha)

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    func components() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red,green,blue,alpha)
    }

    func resizeableImageFromColor() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        self.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }

}
