//
//  ChatResources.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatResources {
  
  class func resourceBundle() -> Bundle {
    return Bundle.main
  }
  
  class func imageNamed(_ name: String) -> UIImage? {
    
    guard let image = UIImage(named: name, in: self.resourceBundle(), compatibleWith: nil) else {
      return UIImage()
    }
    return image
  }
  
  class func nib(withNibName name: String) -> UINib? {
    return UINib(nibName: name , bundle: Bundle.main)
  }
}
