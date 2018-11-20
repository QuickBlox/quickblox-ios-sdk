//
//  ChatResources.swift
//  Swift-QMChatViewController
//
//  Created by Vladimir Nybozhinsky on 11/15/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class ChatResources {
  
  class func resourceBundle() -> Bundle {
    var bundle = Bundle(for: ChatResources.self)
    if let url = bundle.url(forResource: "ChatViewController", withExtension: "bundle") {
     bundle = Bundle(url: url) ?? Bundle.main
    }
    return bundle
  }
  
  class func imageNamed(_ name: String) -> UIImage {
    
    guard let image = UIImage(named: name, in: self.resourceBundle(), compatibleWith: nil) else {
      return UIImage()
    }
    return image
  }
  
  class func nib(withNibName name: String) -> UINib? {
    return UINib(nibName: name , bundle: self.resourceBundle())
  }
}
