//
//  VideoSettingsViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/11/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import AVKit
import QuickbloxWebRTC

enum VideoSettingsSectionType: Int {
    case cameraPostion
    case videoCodec
    case supportedFormats
    case videoFrameRate
    case bandwidth
    case sectionController
}

class VideoSettingsViewController: BaseSettingsViewController {
    
    //MARK: - Overrides
    override func title(forSection section: Int) -> String {
        switch section {
        case VideoSettingsSectionType.cameraPostion.rawValue:
            return "Switch camera position"
        case VideoSettingsSectionType.videoCodec.rawValue:
            return "Video codec"
        case VideoSettingsSectionType.supportedFormats.rawValue:
            return "Video formats"
        case VideoSettingsSectionType.videoFrameRate.rawValue:
            return "Frame rate"
        case VideoSettingsSectionType.bandwidth.rawValue:
            return "Bandwidth"
        case VideoSettingsSectionType.sectionController.rawValue:
            return "Call controller"
        default:
            return ""
        }
    }
    
    //MARK: - Overrides
    override func configure() {
        let settings = Settings()
        //Camera position section
        addSection(with: VideoSettingsSectionType.cameraPostion.rawValue, items: { sectionTitle in
            //Camera position section
            let switchItem = SwitchItemModel()
            switchItem.title = "Back Camera"
            switchItem.on = settings.preferredCameraPostion == .back
            return [switchItem]
        })
        //Video codecs
        addSection(with: VideoSettingsSectionType.videoCodec.rawValue, items: { [weak self] sectionTitle in
            let vp8Model = BaseItemModel()
            vp8Model.title = "VP8"
            vp8Model.data = QBRTCVideoCodec.VP8
            
            let h264BaselineModel = BaseItemModel()
            h264BaselineModel.title = "H264Baseline"
            h264BaselineModel.data = QBRTCVideoCodec.h264Baseline
            
            let h264HighModel = BaseItemModel()
            h264HighModel.title = "H264High"
            h264HighModel.data = QBRTCVideoCodec.h264High
            
            let videoCodec = settings.mediaConfiguration.videoCodec
            self?.selectSection(VideoSettingsSectionType.videoCodec.rawValue, index: Int(videoCodec.rawValue))
            
            
            return [vp8Model, h264BaselineModel, h264HighModel]
        })
        //Supported video formats section
        addSection(with: VideoSettingsSectionType.supportedFormats.rawValue, items: { [weak self] sectionTitle in
            var videoFormats = [BaseItemModel]()
            let position = settings.preferredCameraPostion
            guard let videoFormatsModels = self?.videoFormatModels(withCameraPositon: position)  else {
                return videoFormats
            }
            videoFormats = videoFormatsModels
            var formats = QBRTCCameraCapture.formats(with: position)
            formats = formats.filter({ $0.width <= 1024 })
            //Select index path
            let idx: Int = (formats as NSArray).index(of: settings.videoFormat as Any)
            self?.selectSection(VideoSettingsSectionType.supportedFormats.rawValue, index: idx)
            
            return videoFormats
        })
        //Frame rate
        addSection(with: VideoSettingsSectionType.videoFrameRate.rawValue, items: { sectionTitle in
            let frameRateSlider = SliderItemModel()
            frameRateSlider.title = "30"
            frameRateSlider.minValue = 2
            frameRateSlider.maxValue = 30
            let currentValue = settings.videoFormat.frameRate
            frameRateSlider.currentValue = currentValue
            
            return [frameRateSlider]
        })
        //Video bandwidth
        addSection(with: VideoSettingsSectionType.bandwidth.rawValue, items: { sectionTitle in
            var currentValue = 30
            let bandwidthSlider = SliderItemModel()
            bandwidthSlider.title = "30"
            bandwidthSlider.minValue = 0
            let currValue = settings.mediaConfiguration.videoBandwidth
            currentValue = currValue
            
            bandwidthSlider.currentValue = UInt(bitPattern: currentValue)
            bandwidthSlider.maxValue = 2000
            return [bandwidthSlider]
        })
        addSection(with: VideoSettingsSectionType.sectionController.rawValue, items: { sectionTitle in
            let switchItem = SwitchItemModel()
            switchItem.title = "Prefer Metal for drawing"
            switchItem.on = QBRTCRemoteVideoView.preferMetal
            
            return [switchItem]
        })
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case Int(VideoSettingsSectionType.videoCodec.rawValue):
            updateSelection(at: indexPath)
            // need to request available formats 1 more time for new codec
            // but we need to save it first
            applySettings()
            
        case Int(VideoSettingsSectionType.supportedFormats.rawValue):
            updateSelection(at: indexPath)
        default:
            break
        }
    }
    
    // MARK: - SettingsCellDelegate
    override func cell(_ cell: BaseSettingsCell, didChageModel model: BaseItemModel) {
        guard let model = model as? SwitchItemModel else {
            return }
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        switch indexPath.section {
        case Int(VideoSettingsSectionType.videoCodec.rawValue):
            reloadVideoFormatSection(for: model.on ? .back : .front)
            
        case Int(VideoSettingsSectionType.sectionController.rawValue):
            QBRTCRemoteVideoView.preferMetal = model.on
        default:
            break
        }
    }
    
    override func applySettings() {
        //APPLY SETTINGS
        //Preferred camera positon
        let settings = Settings()
        guard let cameraPostion = model(with: 0, section: VideoSettingsSectionType.cameraPostion.rawValue) as? SwitchItemModel else {
            return }
        settings.preferredCameraPostion = cameraPostion.on ? .back : .front
        
        //Video codec
        guard let videoCodecIndexPath = indexPath(atSection: VideoSettingsSectionType.videoCodec.rawValue),
            let videoCodec = model(with: videoCodecIndexPath.row, section: videoCodecIndexPath.section),
            let videoCodecData = videoCodec.data as? QBRTCVideoCodec  else {
                return
        }
        settings.mediaConfiguration.videoCodec = videoCodecData
        
        //Supported format
        guard let supportedFormatIndexPath = indexPath(atSection: VideoSettingsSectionType.supportedFormats.rawValue),
            let format = model(with: supportedFormatIndexPath.row, section: supportedFormatIndexPath.section),
            let videoFormat = format.data as? QBRTCVideoFormat else {
                return
        }
        
        //Frame rate
        guard let frameRate = section(with: VideoSettingsSectionType.videoFrameRate.rawValue),
            let frameRateSlider = frameRate.items.first as? SliderItemModel else {
                return
        }
        
        //bandwidth
        guard let bandwidth = section(with: VideoSettingsSectionType.bandwidth.rawValue),
            let bandwidthSlider = bandwidth.items.first as? SliderItemModel else {
                return
        }
        settings.mediaConfiguration.videoBandwidth = Int(bandwidthSlider.currentValue)
        settings.videoFormat = QBRTCVideoFormat.init(width: videoFormat.width,
                                                     height: videoFormat.height,
                                                     frameRate: frameRateSlider.currentValue,
                                                     pixelFormat: QBRTCPixelFormat.format420f)
        
        settings.applyConfig()
        settings.saveToDisk()
        reloadVideoFormatSection(for: settings.preferredCameraPostion)
    }
    
    //MARK: - Internal Methods
    func videoFormatModels(withCameraPositon cameraPosition: AVCaptureDevice.Position) -> [BaseItemModel]? {
        //Grab supported formats
        var formats = QBRTCCameraCapture.formats(with: cameraPosition)
        formats = formats.filter({ $0.width <= 1024 })
        var videoFormatModels = [BaseItemModel]()
        for videoFormat in formats {
            let videoFormatModel = BaseItemModel()
            videoFormatModel.title = "\(videoFormat.width)x\(videoFormat.height)"
            videoFormatModel.data = videoFormat
            videoFormatModels.append(videoFormatModel)
        }
        return videoFormatModels
    }
    
    // MARK: - Helpers
    func reloadVideoFormatSection(for position: AVCaptureDevice.Position) {
        guard let videoFormatModels = self.videoFormatModels(withCameraPositon: position),
            let section = self.section(with: VideoSettingsSectionType.supportedFormats.rawValue) else {
                return }
        section.items = videoFormatModels
        let formats = QBRTCCameraCapture.formats(with: position)
        let title = self.title(forSection: VideoSettingsSectionType.supportedFormats.rawValue)
        
        var idx: Int = section.items.count
        if let oldIdnexPath = selectedIndexes[title] {
            //Select index path
            if idx >= oldIdnexPath.row {
                let videoFormatModel = section.items[oldIdnexPath.row]
                let videoFormat = videoFormatModel.data as? QBRTCVideoFormat
                if let videoFormat = videoFormat {
                    idx = (formats as NSArray).index(of: videoFormat)
                }
            }
        }
        selectSection(VideoSettingsSectionType.supportedFormats.rawValue, index: idx)
        let sectionToReload = NSIndexSet(index: Int(VideoSettingsSectionType.supportedFormats.rawValue))
        tableView.reloadSections(sectionToReload as IndexSet, with: .fade)
    }
}
