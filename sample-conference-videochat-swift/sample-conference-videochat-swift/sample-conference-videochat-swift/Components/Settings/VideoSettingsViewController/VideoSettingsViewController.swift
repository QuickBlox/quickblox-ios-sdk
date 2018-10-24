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

enum VideoSettingsSectionType : Int {
    case cameraPostion
    case supportedFormats
    case videoFrameRate
    case bandwidth
}

class VideoSettingsViewController: BaseSettingsViewController {
    
    override func title(forSection section: Int) -> String? {
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
            break
        }
        return nil
    }
    
    func videoFormatModels(withCameraPositon cameraPosition: AVCaptureDevice.Position) -> [BaseItemModel]? {
        //Grab supported formats
        let formats = QBRTCCameraCapture.formats(with: cameraPosition)
        var videoFormatModels = [BaseItemModel]()
        for videoFormat in formats {
            
            let videoFormatModel = BaseItemModel()
            videoFormatModel.title = String(format: "%tux%tu", videoFormat.width, videoFormat.height)
            videoFormatModel.data = videoFormat
            videoFormatModels.append(videoFormatModel)
        }
        
        return videoFormatModels
    }
    
    override func configure() {
        //Camera position section
        addSection(with: VideoSettingsSectionType.cameraPostion.rawValue, items: { [weak self] sectionTitle in
            //Camera position section
            let switchItem = SwitchItemModel()
            switchItem.title = "Back Camera"
            switchItem.on = self?.settings?.preferredCameraPostion == .back
            return [switchItem]
        })
        //Supported video formats section
        addSection(with: VideoSettingsSectionType.supportedFormats.rawValue, items: { [weak self] sectionTitle in
            
//            let position: AVCaptureDevice.Position = (weakSelf?.settings?.preferredCameraPostion)!
            #if targetEnvironment(simulator)
            // Simulator
            let position: AVCaptureDevice.Position = .front
            #else
            // Device
            let position: AVCaptureDevice.Position = (weakSelf?.settings?.preferredCameraPostion)!
            #endif
            let videoFormats = self?.videoFormatModels(withCameraPositon: position)
            debugPrint("videoFormats \(String(describing: videoFormats))")
            let formats = QBRTCCameraCapture.formats(with: position)
            
            debugPrint("formats \(formats)")
            //Select index path
            let idx: Int = (formats as NSArray).index(of: self?.settings?.videoFormat! as Any)
            self?.selectSection(VideoSettingsSectionType.supportedFormats.rawValue, index: idx)
            
            return videoFormats!
        })
        //Frame rate
        addSection(with: VideoSettingsSectionType.videoFrameRate.rawValue, items: { [weak self] sectionTitle in
            
            let frameRateSlider = SliderItemModel()
            frameRateSlider.title = "30"
            frameRateSlider.minValue = 2
            
            frameRateSlider.maxValue = 30
            #if targetEnvironment(simulator)
            // Simulator
            frameRateSlider.currentValue = 30
            #else
            // Device
            frameRateSlider.currentValue = (self?.settings?.videoFormat?.frameRate)!
            #endif
            
            return [frameRateSlider]
        })
        //Video bandwidth
        addSection(with: VideoSettingsSectionType.bandwidth.rawValue, items: { [weak self] sectionTitle in
            
            let bandwidthSlider = SliderItemModel()
            bandwidthSlider.title = "30"
            bandwidthSlider.minValue = 0
            #if targetEnvironment(simulator)
            // Simulator
            let currValue = 30
            #else
            // Device
            let currValue = self?.settings?.mediaConfiguration?.videoBandwidth
            #endif
            bandwidthSlider.currentValue = UInt(bitPattern: currValue)
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

        guard let model = model as? SwitchItemModel else { return }
        debugPrint("model.on \(String(describing: model.on))")
        reloadVideoFormatSection(for: model.on ? .back : .front)
    }
    
    // MARK: - Helpers
    func reloadVideoFormatSection(for position: AVCaptureDevice.Position) {
        
        let videoFormatModels = self.videoFormatModels(withCameraPositon: position)
        
        let section: SettingsSectionModel? = self.section(with: VideoSettingsSectionType.supportedFormats.rawValue)
        section?.items = videoFormatModels!
        let formats = QBRTCCameraCapture.formats(with: position)
        
        let title = self.title(forSection: VideoSettingsSectionType.supportedFormats.rawValue)
        let oldIdnexPath = selectedIndexes[title!]
        //Select index path
        
        var idx: Int = section?.items.count ?? 0 - 1
        if idx >= (oldIdnexPath?.row ?? 0) {
            
            let videoFormatModel: BaseItemModel? = section?.items[oldIdnexPath?.row ?? 0]
            let videoFormat: QBRTCVideoFormat? = videoFormatModel?.data as? QBRTCVideoFormat
            
            if let aFormat = videoFormat {
                idx = (formats as NSArray).index(of: aFormat)
            }
        }
        
        selectSection(VideoSettingsSectionType.supportedFormats.rawValue, index: idx)
        
        let sectionToReload = NSIndexSet(index: Int(VideoSettingsSectionType.supportedFormats.rawValue))
        tableView.reloadSections(sectionToReload as IndexSet, with: .fade)
    }
    
    override func applySettings() {
        
        //APPLY SETTINGS
        
        //Preferred camera positon
        let cameraPostion = model(with: 0, section: VideoSettingsSectionType.cameraPostion.rawValue) as? SwitchItemModel
        settings?.preferredCameraPostion = (cameraPostion?.on)! ? .back : .front
        
        //Supported format
        let supportedFormatIndexPath: IndexPath? = indexPath(atSection: VideoSettingsSectionType.supportedFormats.rawValue)
        let format: BaseItemModel? = model(with: (supportedFormatIndexPath?.row)!, section: (supportedFormatIndexPath?.section)!)
        let videoFormat: QBRTCVideoFormat? = format?.data as? QBRTCVideoFormat
        
        //Frame rate
        let frameRate: SettingsSectionModel? = section(with: VideoSettingsSectionType.videoFrameRate.rawValue)
        let frameRateSlider: SliderItemModel? = frameRate?.items.first as? SliderItemModel
        
        //bandwidth
        let bandwidth: SettingsSectionModel? = section(with: VideoSettingsSectionType.bandwidth.rawValue)
        let bandwidthSlider: SliderItemModel? = bandwidth?.items.first as? SliderItemModel
        settings?.mediaConfiguration?.videoBandwidth = Int((bandwidthSlider?.currentValue)!)
        
        settings?.videoFormat = QBRTCVideoFormat.init(width: (videoFormat?.width)!, height: (videoFormat?.height)!, frameRate: (frameRateSlider?.currentValue)!, pixelFormat: QBRTCPixelFormat.format420f)
    }
}
