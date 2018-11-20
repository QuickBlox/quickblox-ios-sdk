//
//  ChatCellLayoutAttributes.swift
//  Swift-QMChatViewController
//
//  Created by Vladimir Nybozhinsky on 11/15/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

struct ChatCellLayoutAttributesConstant {
  static let invalidParameter = "Invalid parameter not satisfying: containerSize.width >= 0.0 && containerSize.height >= 0.0"
}

class ChatCellLayoutAttributes: UICollectionViewLayoutAttributes {

  var containerInsets = UIEdgeInsets.zero
  var containerSize = CGSize.zero
  var avatarSize = CGSize.zero
  var topLabelHeight: CGFloat = 0.0
  var bottomLabelHeight: CGFloat = 0.0
  var spaceBetweenTopLabelAndTextView: CGFloat = 0.0
  var spaceBetweenTextViewAndBottomLabel: CGFloat = 0.0

  //MARK: - Lifecycle
  override init() {
    super.init()
    commonInit()
  }
  
  func commonInit() {
    self.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
  }
  
  deinit {
    debugPrint("deinit ChatCellLayoutAttributes")
  }
  
  //MARK: - Utilities
  private func updateAvatarSize(_ avatarSize: CGSize) {
    self.avatarSize = correctedSizeFromSize(avatarSize)
  }
  
  private func updateContainerSize(_ containerSize: CGSize) {
    assert(containerSize.width >= 0.0 && containerSize.height >= 0.0, ChatCellLayoutAttributesConstant.invalidParameter)
    self.containerSize = correctedSizeFromSize(containerSize)
  }
  
  private func correctedSizeFromSize(_ size: CGSize) -> CGSize {
    return CGSize(width: CGFloat(ceilf(Float(size.width))), height: CGFloat(ceilf(Float(size.height))))
  }
  
  func isEqual(_ object: Any) -> Bool {
    
    if self == object as? ChatCellLayoutAttributes {
      return true
    }
    if object is ChatCellLayoutAttributes == false {
      return false
    }
    if representedElementCategory == .cell {
      
      guard let layoutAttributes = object as? ChatCellLayoutAttributes else {
        return false
      }
      
      if !(layoutAttributes.containerSize.equalTo(containerSize)) ||
        !layoutAttributes.avatarSize.equalTo(avatarSize) ||
        !(layoutAttributes.containerInsets == containerInsets) ||
        Int(layoutAttributes.topLabelHeight) != Int(topLabelHeight) ||
        Int(layoutAttributes.bottomLabelHeight) != Int(bottomLabelHeight) ||
        Int(layoutAttributes.spaceBetweenTopLabelAndTextView) != Int(spaceBetweenTopLabelAndTextView) ||
        Int(layoutAttributes.spaceBetweenTextViewAndBottomLabel) != Int(spaceBetweenTextViewAndBottomLabel) {
        
        return false
      }
    }
    return super.self() == object as? UICollectionViewLayout
  }
  
  func description() -> String {
    var description = super.description
    description += ""
    return description
  }
  
  func hash() -> Int {
    return indexPath.row
  }
}
