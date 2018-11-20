//
//  ChatAttachmentCell.swift
//  Swift-ChatViewController
//
//  Created by Vladimir Nybozhinsky on 11/13/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
/**
 *  Protocol which describes required methods and properties for attachment cells.
 */
protocol ChatAttachmentCell: class {
  /**
   *  Unique attachment identifier
   */
  var attachmentID: String { get set }
  
  /**
   *  Sets attachment image to cell
   *
   *  @param attachmentImage UIImage object
   */
  func setAttachmentImage(_ attachmentImage: UIImage)
  
  /**
   *  Updates progress label text
   *
   *  @param progress CGFloat value to set
   */
  func updateLoadingProgress(_ progress: CGFloat)
}
