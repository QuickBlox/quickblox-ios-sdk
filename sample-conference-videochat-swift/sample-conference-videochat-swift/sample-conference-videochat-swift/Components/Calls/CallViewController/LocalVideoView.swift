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
    let image = UIImage(named: "switchCamera")
    var videoLayer: AVCaptureVideoPreviewLayer?
    lazy private var switchCameraBtn: UIButton = {
        let switchCameraBtn = UIButton(type: .custom)
        switchCameraBtn.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        switchCameraBtn.setImage(image, for: .normal)
        switchCameraBtn.addTarget(self, action: #selector(didPressSwitchCamera(_:)),
                                  for: .touchUpInside)
        return switchCameraBtn
    }()
    lazy private var containerView: UIView = {
        let containerView = UIView(frame: bounds)
        containerView.backgroundColor = UIColor.clear
        return containerView
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public init(previewlayer layer: AVCaptureVideoPreviewLayer) {
        super.init(frame: CGRect.zero)
        self.videoLayer = layer
        self.videoLayer?.videoGravity = .resizeAspectFill
        self.layer.insertSublayer(layer, at:0)
        insertSubview(containerView, at: 0)
        addSubview(switchCameraBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.videoLayer?.frame = self.bounds
        let buttonSize = CGSize(width: 72 / 2.5, height: 54 / 2.5)
        switchCameraBtn.frame = CGRect(x: bounds.size.width - buttonSize.width - 5,
                                       y: bounds.size.height - buttonSize.height - 30,
                                       width: buttonSize.width, height: buttonSize.height)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        updateOrientationIfNeeded()
    }
    
    @objc func didPressSwitchCamera(_ sender: UIButton?) {
        delegate?.localVideoView(self, pressedSwitchButton: sender)
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
