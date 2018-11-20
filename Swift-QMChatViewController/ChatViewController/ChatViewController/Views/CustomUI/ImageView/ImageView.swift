//
//  QMImageView.swift
//  Swift-QMChatViewController
//
//  Created by Vladimir Nybozhinsky on 11/14/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import SDWebImage

struct ImageViewConstant {
  static let loadNilUrl = "Trying to load a nil url"
  static let imageViewKey = "ImageView"
  static let imageLoadKey = "UIImageViewImageLoad"
}

class TextLayer: CALayer {
  var fillColor: UIColor = .white {
    didSet {
      setNeedsDisplay()
    }
  }
  var string = "" {
    didSet {
      setNeedsDisplay()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init() {
    super.init()
    
    shouldRasterize = true
    rasterizationScale = UIScreen.main.scale
    contentsScale = UIScreen.main.scale
    drawsAsynchronously = true
    
  }
  
  override func draw(in ctx: CGContext) {
    
    var rect: CGRect = bounds
    
    let color = UIColor(white: 1, alpha: 0.8)
    let font = UIFont.systemFont(ofSize: rect.size.height * 0.4)
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    style.lineBreakMode = .byTruncatingTail
    
    let defaultStyle = [NSAttributedString.Key.paragraphStyle: style,
                        NSAttributedString.Key.foregroundColor: color,
                        NSAttributedString.Key.font: font]
    
    UIGraphicsPushContext(ctx)
    
    let size = CGSize(width: bounds.size.width, height: font.lineHeight)
    rect.origin.y = (rect.size.height - size.height) / 2.0
    
    ctx.setFillColor(fillColor.cgColor)
    ctx.fillEllipse(in: bounds)
    
    let firstCharacter = String(string[string.startIndex]).capitalized
    
    firstCharacter.draw(in: rect, withAttributes: defaultStyle)
    
    UIGraphicsPopContext()
  }
}

enum ImageViewType : Int {
  case none
  case circle
  case square
}

protocol ImageViewDelegate: class {
  func imageViewDidTap(_ imageView: ImageView)
}

class ImageView: UIImageView {
  /**
   Default QMUserImageViewType QMUserImageViewTypeNone
   */
  let imageLoader = ImageLoader.sharedManager
  var imageViewType = ImageViewType.none
  weak var delegate: ImageViewDelegate?
  private weak var tapGestureRecognizer: UITapGestureRecognizer?
  lazy private var textLayer: TextLayer = {
    let textLayer = TextLayer()
    textLayer.isHidden = true
    return textLayer
  }()
  
  private var imageUrl: URL?
  
  static var chatColors = [#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.3035047352, green: 0.8693258762, blue: 0.4432001114, alpha: 1), #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), #colorLiteral(red: 0.02297698334, green: 0.6430568099, blue: 0.603818357, alpha: 1), #colorLiteral(red: 0.5244195461, green: 0.3333674073, blue: 0.9113605022, alpha: 1), #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1), #colorLiteral(red: 0.839125216, green: 0.871129334, blue: 0.3547145724, alpha: 1), #colorLiteral(red: 0.09088832885, green: 0.7803853154, blue: 0.8577881455, alpha: 1), #colorLiteral(red: 0.3175504208, green: 0.4197517633, blue: 0.7515394688, alpha: 1)]
  
  //MARK: Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    configure()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    configure()
  }
  
  override init(image: UIImage?) {
    super.init(image: image)
    
    configure()
  }
  
  override init(image: UIImage?, highlightedImage: UIImage?) {
    super.init(image: image, highlightedImage: highlightedImage)
    
    configure()
    
  }
  
  deinit {
    sd_cancelCurrentAnimationImagesLoad()
  }
  
  func configure() {
    
    backgroundColor = UIColor.clear
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    addGestureRecognizer(tap)
    tapGestureRecognizer = tap
    isUserInteractionEnabled = true
    textLayer.frame = bounds
    layer.addSublayer(textLayer)
  }
  
  //MARK: - Helpers
  override func layoutSubviews() {
    super.layoutSubviews()
    
    textLayer.frame = bounds
  }
  
  func color(for string: String) -> UIColor {
    var index = 0
    if string.isEmpty == false {
      index = string.count % 10
    }
    return ImageView.chatColors[index]
  }
  
  //MARK: - Public interface
  func originalImage() -> UIImage? {
    return image
  }
  
  
  //MARK: - UIView
  override var intrinsicContentSize: CGSize {
    if image != nil {
      return super.intrinsicContentSize
    }
    return CGSize.zero
  }
  
  @objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer?) {
    if let _ = delegate?.imageViewDidTap(self) {
      UIView.animate(withDuration: 0.2, animations: {
        self.layer.opacity = 0.6
      }) { finished in
        self.layer.opacity = 1.0
        self.delegate?.imageViewDidTap(self)
      }
    }
  }
  
  func setImageWith(_ url: URL?) {
    let sdOptions = SDWebImageOptions(arrayLiteral: .allowInvalidSSLCertificates, .highPriority, .continueInBackground)
    setImageWith(url, placeholder: nil, options: sdOptions, progress: nil, completedBlock: nil)
  }
  
  func setImageWith(_ url: URL?, placeholder placehoder: UIImage?,
                    options: SDWebImageOptions,
                    progress: SDWebImageDownloaderProgressBlock?,
                    completedBlock: SDExternalCompletionBlock?) {
    
    let urlIsValid: Bool = url != nil && url?.scheme != nil && url?.host != nil
    
    imageUrl = url
    
    sd_cancelCurrentAnimationImagesLoad()
    
    image = placehoder
    
    if urlIsValid {
      
      let operation = imageLoader.downloadImage(with: url,
                                                transform: nil,
                                                options: options,
                                                progress: nil,
                                                completed: { [weak self] image, transfomedImage,
                                                  error, cacheType, finished, imageURL in
                                                  guard let `self` = self else {
                                                    return
                                                  }
                                                  
                                                  if error == nil {
                                                    
                                                    if image != nil {
                                                      self.image = image
                                                      self.setNeedsLayout()
                                                    }
                                                  }
                                                  
                                                  if let completedBlock = completedBlock {
                                                    completedBlock(image, error, cacheType!, imageURL)
                                                  }
      })
      
      sd_setImageLoad(operation, forKey: ImageViewConstant.imageLoadKey)
    } else {
      
      DispatchQueue.main.async {
        
        if completedBlock != nil {
          let error = NSError(domain: SDWebImageErrorDomain, code: -1,
                              userInfo: [NSLocalizedDescriptionKey: ImageViewConstant.loadNilUrl])
          completedBlock!(nil, error, SDImageCacheType.none, url)
        }
      }
    }
  }
  
  func setImageWith(_ url: URL?, title: String = "", completedBlock: @escaping SDExternalCompletionBlock) {
    
    let urlIsValid: Bool = url != nil && url?.scheme != nil && url?.host != nil
    
    let showPlaceholder: () -> () = {
      
      self.textLayer.isHidden = false
      self.textLayer.fillColor = self.color(for: title )
      self.textLayer.string = title
      
      if self.textLayer.frame.equalTo(self.bounds) == false {
        self.textLayer.frame = self.bounds
      }
    }
    
    if imageUrl == url, image == nil {
      showPlaceholder()
      return
    }
    
    imageUrl = url
    
    sd_cancelImageLoadOperation(withKey: ImageViewConstant.imageViewKey)
    
    let targetSize: CGSize = bounds.size
    let type = imageViewType == ImageViewType.circle ? ImageTransformType.circle : ImageTransformType.custom
    var transform = ImageTransform()
    if type == ImageTransformType.circle {
      transform = ImageTransform(type: type, size: targetSize)
    } else if type == ImageTransformType.custom {
      
      transform = ImageTransform(size: targetSize, customTransformBlock: { imageURL, originalImage in
        guard let image = originalImage.withCornerRadius(4.0, targetSize: targetSize) else {
          return UIImage()
        }
        return image
      })
    }
    
    image = nil
    showPlaceholder()
    
    if urlIsValid {
      let sdOptions = SDWebImageOptions(arrayLiteral: .allowInvalidSSLCertificates, .highPriority)
      weak var operation = imageLoader.downloadImage(with: url,
                                                     transform: transform,
                                                     options: sdOptions,
                                                     progress: nil,
                                                     completed: { [weak self] image,
                                                      transfomedImage,
                                                      error, cacheType, finished, imageURL in
                                                      guard let `self` = self else {
                                                        return
                                                      }
                                                      
                                                      
                                                      //        if error == nil {
                                                      
                                                      self.textLayer.isHidden = true
                                                      self.image = transfomedImage
                                                      self.setNeedsLayout()
                                                      //        }
                                                      
                                                      //        if completedBlock != nil {
                                                        completedBlock(image, error, cacheType!, imageURL)
                                                      //        }
                                                      
                              self.sd_removeImageLoadOperation(withKey: ImageViewConstant.imageViewKey)
      })
      
      sd_setImageLoad(operation, forKey: ImageViewConstant.imageViewKey)
      
    } else {
      DispatchQueue.main.async {
        let error = NSError(domain: SDWebImageErrorDomain, code: -1,
                            userInfo: [NSLocalizedDescriptionKey: ImageViewConstant.loadNilUrl])
        completedBlock(nil, error, SDImageCacheType.none, url)
      }
    }
  }
}
