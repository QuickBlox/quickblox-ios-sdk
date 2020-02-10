//
//  KVOView.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class KVOView: UIView {
    //MARK: - Properties
    var hostViewFrameChangeBlock : ((_ view: UIView?, _ animated: Bool) -> Void)?
    
    var frameKeyValueObservingContext = UnsafeMutableRawPointer.allocate(byteCount: 4 * 4, alignment: 1)
    
    weak var collectionView: UICollectionView? {
        didSet {
            collectionView?.panGestureRecognizer.addTarget(self, action: #selector(handle(_:)))
        }
    }
    
    weak var chatInputView: UIView?
    
    private var observerAdded: Bool = false {
        didSet {
            debugPrint("[KVOView] observerAdded \(observerAdded)")
        }
    }
    
    //MARK: - Overrides
    override func willMove(toSuperview newSuperview: UIView?) {
        
        if observerAdded == true {
            
            hostViewFrameChangeBlock?(newSuperview, false)
            
            superview?.removeObserver(self as NSObject, forKeyPath: "center",
                                      context: frameKeyValueObservingContext)
        }
        newSuperview?.addObserver(self as NSObject, forKeyPath: "center", options: .new,
                                  context: frameKeyValueObservingContext)
        observerAdded = true
        super.willMove(toSuperview: newSuperview)
    }
    
    // MARK: - Key-value observing
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if (keyPath == "center") {
            if let hostViewFrameChangeBlock = hostViewFrameChangeBlock,
                let superview = superview {
                hostViewFrameChangeBlock(superview, collectionView?.panGestureRecognizer.state != .changed)
            }
        }
    }
    
    //MARK: - Internal Methods
    @objc private func handle(_ gesture: UIPanGestureRecognizer) {
        
        if superview == nil {
            return
        }
        
        if gesture.state == .changed {
            
            guard let host = superview, let input = chatInputView else { return }
            
            var frame = host.frame
            let panPoint = gesture.location(in: input.window)
            let hostViewRect = input.convert(frame, to: host)
            
            if panPoint.y >= hostViewRect.origin.y {
                frame.origin.y += hostViewRect.origin.y - panPoint.y
                host.frame = frame
            }
        }
    }
}
