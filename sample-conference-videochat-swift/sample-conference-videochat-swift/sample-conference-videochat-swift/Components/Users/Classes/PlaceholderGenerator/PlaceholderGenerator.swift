//
//  PlaceholderGenerator.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 17.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

class PlaceholderGenerator {
    
    private var cache: NSCache<AnyObject, AnyObject>?
    private let colors: [UIColor] = [#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.3035047352, green: 0.8693258762, blue: 0.4432001114, alpha: 1), #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), #colorLiteral(red: 0.02297698334, green: 0.6430568099, blue: 0.603818357, alpha: 1), #colorLiteral(red: 0.5244195461, green: 0.3333674073, blue: 0.9113605022, alpha: 1), #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1), #colorLiteral(red: 0.839125216, green: 0.871129334, blue: 0.3547145724, alpha: 1), #colorLiteral(red: 0.09088832885, green: 0.7803853154, blue: 0.8577881455, alpha: 1), #colorLiteral(red: 0.3175504208, green: 0.4197517633, blue: 0.7515394688, alpha: 1)]
    
    static let instance = PlaceholderGenerator()
    
    class func color(for index: Int?) -> UIColor {
        return PlaceholderGenerator.instance.color(for: index)
    }
    
    init() {
        cache = NSCache<AnyObject, AnyObject>()
        cache?.name = "QMUserPlaceholer.cache"
        cache?.countLimit = 200
    }
    
    func color(for index: Int?) -> UIColor {
        let color = colors[index ?? 0]
        return color
    }
    
    class func placeholder(size: CGSize, title: String?) -> UIImage? {
        let key = title ?? ""
        if let image = PlaceholderGenerator.instance.cache?.object(forKey: key as AnyObject) as? UIImage {
            return image
        } else {
            var image: UIImage?
            let index = key.count % 10
            if let img: UIImage = self.placeholder(size: size, color: PlaceholderGenerator.instance.color(for: index), title: title, isOval: true)
            {
                PlaceholderGenerator.instance.cache?.setObject(img, forKey: key as AnyObject)
                image = img
            }
            return image
        }
    }
    
    class func placeholder(size: CGSize, color: UIColor?, title: String?, isOval: Bool) -> UIImage? {
        
        let minSize = min(size.width, size.height)
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        var path: UIBezierPath? = nil
        if isOval {
            path = UIBezierPath(ovalIn: frame)
        } else {
            
            path = UIBezierPath(rect: frame)
        }
        
        color?.setFill()
        path?.fill()
        
        let paragraphStyle = NSMutableParagraphStyle.default as? NSMutableParagraphStyle
        paragraphStyle?.alignment = .center
        
        let font = UIFont.systemFont(ofSize: CGFloat(Double(minSize) / 2.0))
        let textColor = UIColor.white
        
        let titleString: NSString = title as NSString? ?? "Q"
        
        let textContent = titleString.substring(to: 1).uppercased()
        
        var ovalFontAttributes: [NSAttributedString.Key : UIFont]? = nil
        if let aStyle = paragraphStyle {
            ovalFontAttributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.paragraphStyle: aStyle] as? [NSAttributedString.Key : UIFont]
        }
        
        let rect: CGRect = textContent.boundingRect(with: frame.size, options: .usesLineFragmentOrigin, attributes: ovalFontAttributes, context: nil)
        
        let textRect: CGRect = frame.offsetBy(dx: (size.width - (rect.size.width)) / 2, dy: (size.height - (rect.size.height)) / 2)
        
        textContent.draw(in: textRect, withAttributes: ovalFontAttributes)
        //Get image
        let img: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    class func groupPlaceholder(withUsers users: [QBUUser]?, size: Int) -> UIImage? {
        
        let tSize: CGSize? = CGSize(width: size, height: size)
        
        UIGraphicsBeginImageContextWithOptions(tSize ?? CGSize.zero, _: false, _: 0.0)
        
        let count = min((users?.count)!, 4)
        
        for i in 0..<count {
            
            let user = users?[i]
            let r: CGRect = self.rect(withIndex: i, size: size, count: count)
            let indexUser = user?.id ?? 0
            let index: Int = Int(indexUser % 10)
            
            let img: UIImage? = self.placeholder(size: r.size, color: PlaceholderGenerator.instance.colors[index], title: user?.fullName, isOval: true)
            img?.draw(in: r)
        }
        
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContextWithOptions(tSize ?? CGSize.zero, _: false, _: 0.0)
        
        UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3).setFill()
        UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: CGFloat(size), height: CGFloat(size))).fill()
        
        let interiorBox = CGRect(x: 0, y: 0, width: CGFloat(size), height: CGFloat(size)).insetBy(dx: 2, dy: 2)
        let interior = UIBezierPath(ovalIn: interiorBox)
        
        interior.addClip()
        image?.draw(in: CGRect(x: 0, y: 0, width: CGFloat(size), height: CGFloat(size)))
        
        let finalImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
    class func rect(withIndex idx: Int, size: Int, count: Int) -> CGRect {
        
        let h: Int = count > 2 ? size / 2 : size
        let s: Int = size / 2
        
        switch idx {
        case 0:
            return CGRect(x: 0, y: 0, width: s, height: count < 4 ? size : size / 2)
        case 1:
            return CGRect(x: s, y: 0, width: s, height: h)
        case 2:
            return CGRect(x: count < 4 ? s : 0, y: s, width: s, height: h)
        case 3:
            return CGRect(x: s, y: s, width: s, height: h)
        default:
            return CGRect.zero
        }
    }
}
