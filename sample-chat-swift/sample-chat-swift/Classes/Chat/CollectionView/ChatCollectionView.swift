//
//  ChatCollectionView.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

/**
 *  Collection View with chat cells.
 */
class ChatCollectionView: UICollectionView {
    /**
     *  The object that provides the data for the collection view.
     *  The data source must adopt the `ChatCollectionViewDataSource` protocol.
     */
    weak var chatDataSource: ChatCollectionViewDataSource?
    
    override weak var dataSource: UICollectionViewDataSource?  {
        didSet {
            chatDataSource = dataSource as? ChatCollectionViewDataSource
        }
    }
    /**
     *  The object that acts as the delegate of the collection view.
     *  The delegate must adpot the `ChatCollectionViewDelegateFlowLayout` protocol.
     */
    weak var chatDelegate: ChatCollectionViewDelegateFlowLayout?
    override weak var delegate: UICollectionViewDelegate? {
        didSet {
            chatDelegate = dataSource as? ChatCollectionViewDelegateFlowLayout
        }
    }
    /**
     *  The layout used to organize the collection view’s items.
     */
    var chatCollectionViewLayout: ChatCollectionViewFlowLayout?
    
    override var collectionViewLayout: UICollectionViewLayout {
        didSet {
            chatCollectionViewLayout = collectionViewLayout as? ChatCollectionViewFlowLayout
        }
    }
    
    //MARK: - Initialization
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        configureCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        translatesAutoresizingMaskIntoConstraints = false
        keyboardDismissMode = .interactive
        alwaysBounceVertical = true
        bounces = true
    }
}
