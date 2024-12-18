//
//  UInt+Extension.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 1/9/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

extension UInt {
    func generateColor() -> UIColor {
        let hexString = String(format:"%llX", self)
        var hexInt: UInt64 = 0
        let scanner = Scanner(string: hexString)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt64(&hexInt)

        let redColor = CGFloat((hexInt & 0xff0000) >> 16) / 255.0
        let greenColor = CGFloat((hexInt & 0xff00) >> 8) / 255.0
        let blueColor = CGFloat((hexInt & 0xff) >> 0) / 255.0
        let color = UIColor(red: redColor,
        green: greenColor,
        blue: blueColor,
        alpha: 1.0)

        return color
    }
}
