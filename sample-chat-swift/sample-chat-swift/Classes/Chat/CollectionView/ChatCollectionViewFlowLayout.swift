//
//  ChatCollectionViewFlowLayout.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
/**
 *  The `ChatCollectionViewFlowLayout` is a concrete layout object that inherits
 *  from `UICollectionViewFlowLayout` and organizes message items in a vertical list.
 *  Each `ChatCollectionViewCell` in the layout can display messages of arbitrary sizes and avatar images,
 *  as well as metadata such as a timestamp and sender.
 *  You can easily customize the layout via its properties or its delegate methods
 *  defined in `ChatCollectionViewDelegateFlowLayout`.
 *
 *  @see ChatCollectionViewDelegateFlowLayout.
 *  @see ChatCollectionViewCell.
 */
class ChatCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    /**
     *  The collection view object currently using this layout object.
     */
    lazy private(set) var chatCollectionView: ChatCollectionView = {
        return collectionView as! ChatCollectionView
    }()
    /**
     *  Returns the width of items in the layout.
     */
    
    var itemWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0.0
        }
        return collectionView.frame.width - sectionInset.left - sectionInset.right
    }
    /**
     *  Size for item and index path.
     *
     *  @discussion Returns cached size of item. If size is not in cache, then counts it first.
     *
     *  @return Size of item at index path
     */
    
    func sizeForItem(at indexPath: IndexPath?) -> CGSize {
        
        var height = containerViewSizeForItem(at: indexPath).height
        height.round(.up)
        return CGSize(width: itemWidth, height: height)
    }
    /**
     *  Removing size for itemID from cache.
     *
     *  @discussion Use this method before any of collection view reload methods, that will update missed cached sizes.
     */
    //MARK: - Message cell layout utilities
    func removeSizeFromCache(forItemID itemID: String?) {
        cache.removeValue(forKey: itemID)
    }
    
    
    private var cache: [AnyHashable : Any] = [:]
    
    //MARK: - Initialization
    
    func configureFlowLayout() {
        
        scrollDirection = UICollectionView.ScrollDirection.vertical
        sectionInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
        minimumLineSpacing = 16.0
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveApplicationMemoryWarning(_:)),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
        /**
         *  Init cache
         */
        cache = [AnyHashable : Any]()
    }
    
    override init() {
        super.init()
        
        configureFlowLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        configureFlowLayout()
    }
    
    override class var layoutAttributesClass: AnyClass {
        return ChatCellLayoutAttributes.self
    }
    
    override class var invalidationContextClass: AnyClass {
        return CollectionViewFlowLayoutInvalidationContext.self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Notifications
    @objc func didReceiveApplicationMemoryWarning(_ notification: Notification?) {
        resetLayout()
    }
    
    //MARK: - Collection view flow layout
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        
        let context = CollectionViewFlowLayoutInvalidationContext()
        if let collectionView = collectionView, collectionView.bounds.size.width != newBounds.size.width {
            context.invalidateFlowLayoutMessagesCache = true
        }
        return context
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        guard let invalidationContext = context as? CollectionViewFlowLayoutInvalidationContext else {
            super.invalidateLayout(with: context)
            return
        }
        if invalidationContext.invalidateDataSourceCounts == true {
            invalidationContext.invalidateFlowLayoutAttributes = true
            invalidationContext.invalidateFlowLayoutDelegateMetrics = true
        }
        
        if invalidationContext.invalidateFlowLayoutMessagesCache == false  {
            resetLayout()
        }
        super.invalidateLayout(with: context)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesInRect = super.layoutAttributesForElements(in: rect)
        attributesInRect?.forEach {
            if $0.representedElementCategory == .cell, let item = $0 as? ChatCellLayoutAttributes {
                configureCellLayoutAttributes(item)
            }
        }
        return attributesInRect
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let customAttributes = super.layoutAttributesForItem(at: indexPath) as? ChatCellLayoutAttributes
        
        if customAttributes?.representedElementCategory == .cell {
            configureCellLayoutAttributes(customAttributes)
        }
        
        return customAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView?.bounds ?? .zero
        return oldBounds.size.equalTo(newBounds.size) == false
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        
        guard let collectionView = collectionView  else {
            return
        }
        
        let collectionHeight = collectionView.bounds.height
        
        updateItems.forEach{
            if $0.updateAction == .insert, let index = $0.indexPathAfterUpdate {
                let attributes = ChatCellLayoutAttributes(forCellWith:index)
                if attributes.representedElementCategory == .cell {
                    configureCellLayoutAttributes(attributes)
                }
                attributes.frame = CGRect(x: 0.0,
                                          y: collectionHeight + attributes.frame.height,
                                          width: attributes.frame.width,
                                          height: attributes.frame.height)
            }
        }
    }
    
    //MARK:- Invalidation utilities
    func resetLayout() {
        cache.removeAll()
    }
    
    private func containerViewSizeForItem(at indexPath: IndexPath?) -> CGSize {
        
        guard let indexPath = indexPath else {
            return .zero
        }
        
        guard let chatDataSource = chatCollectionView.chatDataSource else {
            return .zero
        }
        
        let itemID = chatDataSource.collectionView(chatCollectionView, itemIdAt: indexPath)
        
        if let cachedSize = cache[itemID] as? NSValue {
            return cachedSize.cgSizeValue
        }
        
        guard let chatDelegate = chatCollectionView.chatDelegate else {
            return .zero
        }
        
        let layoutModel = chatDelegate.collectionView(chatCollectionView, layoutModelAt: indexPath)
        
        var finalSize = layoutModel.staticContainerSize
        
        if layoutModel.staticContainerSize.equalTo(.zero) {
            
            //  from the cell xibs, there is a 2 point space between avatar and bubble
            let spacingBetweenAvatarAndBubble: CGFloat = 16.0
            let horizontalContainerInsets = layoutModel.containerInsets.left + layoutModel.containerInsets.right
            let horizontalInsetsTotal: CGFloat = horizontalContainerInsets + spacingBetweenAvatarAndBubble
            var maximumWidth: CGFloat = itemWidth - layoutModel.avatarSize.width - layoutModel.maxWidthMarginSpace
            
            if layoutModel.maxWidth > 0.0 {
                maximumWidth = min(maximumWidth, layoutModel.maxWidth - layoutModel.avatarSize.width - layoutModel.maxWidthMarginSpace)
            }
            assert(maximumWidth >= 0.0, "Maximum width cannot be a negative nuber. Please check your maxWidthMarginSpace value.")
            
            let dynamicSize = chatDelegate.collectionView(chatCollectionView, dynamicSizeAt: indexPath, maxWidth: maximumWidth - horizontalInsetsTotal)

            let verticalContainerInsets = layoutModel.containerInsets.top + layoutModel.containerInsets.bottom + layoutModel.timeLabelHeight + 6.0
            
            let additionalSpace = layoutModel.spaceBetweenTopLabelAndTextView
            
            let finalWidth = dynamicSize.width + horizontalContainerInsets
            
            let cellHeight = dynamicSize.height + verticalContainerInsets + additionalSpace
            
            let finalCellHeight = max(cellHeight, layoutModel.avatarSize.height)
            
            var minWidth = chatDelegate.collectionView(chatCollectionView, minWidthAt: indexPath)
            minWidth += horizontalContainerInsets
            
            finalSize = CGSize(width: min(max(finalWidth, minWidth), maximumWidth), height: finalCellHeight)
        }
        
        cache[itemID] = NSValue(cgSize: finalSize)
        
        return finalSize
    }
    
    func configureCellLayoutAttributes(_ layoutAttributes: ChatCellLayoutAttributes?) {
        
        guard let layoutAttributes = layoutAttributes else {
            return
        }
        
        let containerSize = containerViewSizeForItem(at: layoutAttributes.indexPath)
        layoutAttributes.containerSize = containerSize
        
        // fix for content size changes (example: split view display mode change)
        var frame = layoutAttributes.frame
        frame.origin.x = sectionInset.left
        frame.size.width = itemWidth
        layoutAttributes.frame = frame
        
        guard let chatDelegate = chatCollectionView.chatDelegate else {
            return
        }
        
        let layoutModel = chatDelegate.collectionView(chatCollectionView, layoutModelAt: layoutAttributes.indexPath)
        
        layoutAttributes.avatarSize = layoutModel.avatarSize
        layoutAttributes.containerInsets = layoutModel.containerInsets
        layoutAttributes.topLabelHeight = layoutModel.timeLabelHeight
        layoutAttributes.spaceBetweenTopLabelAndTextView = layoutModel.spaceBetweenTopLabelAndTextView
    }
}
