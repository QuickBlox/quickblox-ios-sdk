//
//  LocalVideoView.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import AVKit

protocol LocalVideoViewDelegate: class {
    func localVideoView(_ localVideoView: LocalVideoView?, pressedSwitchButton sender: UIButton?)
}

class LocalVideoView: UIView {
    weak var delegate: LocalVideoViewDelegate?
    private weak var videoLayer: AVCaptureVideoPreviewLayer?
    private var switchCameraBtn: UIButton?
    private var containerView: UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    init(previewlayer layer: AVCaptureVideoPreviewLayer?) {
        
        super.init(frame: CGRect.zero)
        
        videoLayer = layer
        layer?.videoGravity = .resizeAspect
        
        let image = UIImage(named: "switchCamera")
        
        switchCameraBtn = UIButton(type: .custom)
        switchCameraBtn?.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        switchCameraBtn?.setImage(image, for: .normal)
        
        switchCameraBtn?.addTarget(self, action: #selector(didPressSwitchCamera(_:)), for: .touchUpInside)
        
        containerView = UIView(frame: bounds)
        containerView?.backgroundColor = UIColor.clear
        if let aLayer = layer {
            containerView?.layer.insertSublayer(aLayer, at: 0)
        }
        
        if let aView = containerView {
            insertSubview(aView, at: 0)
        }
        if let aBtn = switchCameraBtn {
            addSubview(aBtn)
        }
        ///////////////////////////
        containerView?.frame = bounds
        videoLayer?.frame = bounds
        
        let buttonSize = CGSize(width: 72 / 2.5, height: 54 / 2.5)
        switchCameraBtn?.frame = CGRect(x: bounds.size.width - buttonSize.width - 5, y: bounds.size.height - buttonSize.height - 30, width: buttonSize.width, height: buttonSize.height)
        ///////////////////////////////////
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        updateOrientationIfNeeded()
    }
    
    @objc func didPressSwitchCamera(_ sender: UIButton?) {
        
        delegate?.localVideoView(self, pressedSwitchButton: sender)
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        containerView?.frame = bounds
        videoLayer?.frame = bounds
        
        let buttonSize = CGSize(width: 72 / 2.5, height: 54 / 2.5)
        switchCameraBtn?.frame = CGRect(x: bounds.size.width - buttonSize.width - 5, y: bounds.size.height - buttonSize.height - 30, width: buttonSize.width, height: buttonSize.height)
    }
    
    func updateOrientationIfNeeded() {
        
        let previewLayerConnection: AVCaptureConnection? = videoLayer?.connection
        let interfaceOrientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        let videoOrientation = AVCaptureVideoOrientation(rawValue: interfaceOrientation.rawValue)
        
        let isVideoOrientationSupported = previewLayerConnection?.isVideoOrientationSupported
        if isVideoOrientationSupported ?? false && previewLayerConnection?.videoOrientation != videoOrientation {
            if let anOrientation = videoOrientation {
                previewLayerConnection?.videoOrientation = anOrientation
            }
        }
    }
}
