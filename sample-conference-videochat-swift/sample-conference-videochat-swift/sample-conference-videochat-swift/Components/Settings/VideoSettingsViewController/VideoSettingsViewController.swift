//
//  VideoSettingsViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import AVKit
import QuickbloxWebRTC

enum VideoSettingsSectionType: Int {
    case cameraPostion
    case supportedFormats
    case videoFrameRate
    case bandwidth
}

class VideoSettingsViewController: BaseSettingsViewController {
    //MARK: - Overrides
    override func title(forSection section: Int) -> String {
        switch section {
        case VideoSettingsSectionType.cameraPostion.rawValue:
            return "Switch camera position"
        case VideoSettingsSectionType.supportedFormats.rawValue:
            return "Video formats"
        case VideoSettingsSectionType.videoFrameRate.rawValue:
            return "Frame rate"
        case VideoSettingsSectionType.bandwidth.rawValue:
            return "Bandwidth"
        default:
            return ""
        }
    }
    
    //MARK: - Overrides
    override func configure() {
        //Camera position section
        addSection(with: VideoSettingsSectionType.cameraPostion.rawValue, items: { [weak self] sectionTitle in
            //Camera position section
            let switchItem = SwitchItemModel()
            switchItem.title = "Back Camera"
            switchItem.on = self?.settings.preferredCameraPostion == .back
            return [switchItem]
        })
        //Supported video formats section
        addSection(with: VideoSettingsSectionType.supportedFormats.rawValue, items: { [weak self] sectionTitle in
            var videoFormats = [BaseItemModel]()
            guard let position = self?.settings.preferredCameraPostion, let videoFormatsModels = self?.videoFormatModels(withCameraPositon: position)  else {
                return videoFormats
            }
            videoFormats = videoFormatsModels
            let formats = QBRTCCameraCapture.formats(with: position)
            //Select index path
            let idx: Int = (formats as NSArray).index(of: self?.settings.videoFormat as Any)
            self?.selectSection(VideoSettingsSectionType.supportedFormats.rawValue, index: idx)
            return videoFormats
        })
        //Frame rate
        addSection(with: VideoSettingsSectionType.videoFrameRate.rawValue, items: { [weak self] sectionTitle in
            let frameRateSlider = SliderItemModel()
            frameRateSlider.title = "30"
            frameRateSlider.minValue = 2
            frameRateSlider.maxValue = 30
            if let currentValue = self?.settings.videoFormat.frameRate {
                frameRateSlider.currentValue = currentValue
            } else {
                frameRateSlider.currentValue = 2
            }
            return [frameRateSlider]
        })
        //Video bandwidth
        addSection(with: VideoSettingsSectionType.bandwidth.rawValue, items: { [weak self] sectionTitle in
            var currentValue = 30
            let bandwidthSlider = SliderItemModel()
            bandwidthSlider.title = "30"
            bandwidthSlider.minValue = 0
            if let currValue = self?.settings.mediaConfiguration.videoBandwidth {
                currentValue = currValue
            }
            bandwidthSlider.currentValue = UInt(bitPattern: currentValue)
            bandwidthSlider.maxValue = 2000
            return [bandwidthSlider]
        })
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case Int(VideoSettingsSectionType.supportedFormats.rawValue):
            updateSelection(at: indexPath)
        default:
            break
        }
    }
    
    // MARK: - SettingsCellDelegate
    override func cell(_ cell: BaseSettingsCell?, didChageModel model: BaseItemModel?) {
        guard let model = model as? SwitchItemModel else {
            return }
        reloadVideoFormatSection(for: model.on ? .back : .front)
    }
    
    override func applySettings() {
        //APPLY SETTINGS
        //Preferred camera positon
        guard let cameraPostion = model(with: 0, section: VideoSettingsSectionType.cameraPostion.rawValue) as? SwitchItemModel else {
            return }
        settings.preferredCameraPostion = cameraPostion.on ? .back : .front
        
        //Supported format
        guard let supportedFormatIndexPath = indexPath(atSection: VideoSettingsSectionType.supportedFormats.rawValue),
            let format = model(with: supportedFormatIndexPath.row, section: supportedFormatIndexPath.section),
            let videoFormat = format.data as? QBRTCVideoFormat else {
                return }
        
        //Frame rate
        guard let frameRate = section(with: VideoSettingsSectionType.videoFrameRate.rawValue),
            let frameRateSlider = frameRate.items.first as? SliderItemModel else { return }
        
        //bandwidth
        guard let bandwidth = section(with: VideoSettingsSectionType.bandwidth.rawValue),
            let bandwidthSlider = bandwidth.items.first as? SliderItemModel else {
                return }
        settings.mediaConfiguration.videoBandwidth = Int(bandwidthSlider.currentValue)
        settings.videoFormat = QBRTCVideoFormat.init(width: videoFormat.width,
                                                     height: videoFormat.height,
                                                     frameRate: frameRateSlider.currentValue,
                                                     pixelFormat: QBRTCPixelFormat.format420f)
    }
    
    //MARK: - Internal Methods
    func videoFormatModels(withCameraPositon cameraPosition: AVCaptureDevice.Position) -> [BaseItemModel]? {
        //Grab supported formats
        let formats = QBRTCCameraCapture.formats(with: cameraPosition)
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
