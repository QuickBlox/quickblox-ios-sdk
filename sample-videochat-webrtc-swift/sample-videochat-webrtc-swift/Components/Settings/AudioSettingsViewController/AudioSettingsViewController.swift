//
//  AudioSettingsViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/11/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

enum AudioSettingsSectionType : Int {
    case constraints
    case audioCodec
    case bandwidth
}

enum AudioBandwidthSection : Int {
    case enable
    case bandwidth
}

struct AudioCodecBandWidthRange {
    var minValue: Int = 0
    var maxValue: Int = 0
}

@inline(__always) private func audioCodecRangeForCodec(codec: QBRTCAudioCodec) -> AudioCodecBandWidthRange {
    var range: AudioCodecBandWidthRange = AudioCodecBandWidthRange()
    switch codec {
    case QBRTCAudioCodec.codecOpus:
        range.minValue = 6
        range.maxValue = 510
    case QBRTCAudioCodec.codecISAC:
        range.minValue = 10
        range.maxValue = 32
    case QBRTCAudioCodec.codeciLBC:
        range.minValue = 15
        range.maxValue = 32
    default:
        break
    }
    return range
}

class AudioSettingsViewController: BaseSettingsViewController {
    
    // MARK: - Overrides superClass Methods
    override func title(forSection section: Int) -> String? {
        switch section {
        case AudioSettingsSectionType.constraints.rawValue:
            return "Constraints"
        case AudioSettingsSectionType.audioCodec.rawValue:
            return "Codecs"
        case AudioSettingsSectionType.bandwidth.rawValue:
            return "Bandwidth"
        default:
            break
        }
        return nil
    }
    
    override func configure() {
        let settings = Settings()
        //Constraints
        addSection(with: AudioSettingsSectionType.constraints.rawValue, items: { sectionTitle in
            //audio level control
            let switchItem = SwitchItemModel()
            switchItem.title = "Audio level control"
            #if targetEnvironment(simulator)
            // Simulator
            switchItem.on = true
            #else
            // Device
            switchItem.on = settings.mediaConfiguration.isAudioLevelControlEnabled
            
            #endif
            return [switchItem]
        })
        //Audio codecs
        addSection(with: AudioSettingsSectionType.audioCodec.rawValue, items: { [weak self] sectionTitle in
            
            let opusModel = BaseItemModel()
            opusModel.title = "Opus"
            opusModel.data = QBRTCAudioCodec.codecOpus
            
            let isacModel = BaseItemModel()
            isacModel.title = "ISAC"
            isacModel.data = QBRTCAudioCodec.codecISAC
            
            let iLBCModel = BaseItemModel()
            iLBCModel.title = "iLBC"
            iLBCModel.data = QBRTCAudioCodec.codeciLBC
            
            let audioCodec = settings.mediaConfiguration.audioCodec
            self?.selectSection(AudioSettingsSectionType.audioCodec.rawValue, index: Int(audioCodec.rawValue))
            
            return [opusModel, isacModel, iLBCModel]
        })
        //Bandwidth
        addSection(with: AudioSettingsSectionType.bandwidth.rawValue, items: { [weak self] sectionTitle in
            
            //Camera position section
            let switchItem = SwitchItemModel()
            switchItem.title = "Enable"
            let bandwidthSlider = SliderItemModel()
            bandwidthSlider.title = "30"
            var isEnabled = false
            
            #if targetEnvironment(simulator)
            // Simulator
            isEnabled = true
            bandwidthSlider.currentValue = 30
            bandwidthSlider.minValue = 6
            bandwidthSlider.maxValue = 510
            #else
            // Device
            
            let audioBandwidth = settings.mediaConfiguration.audioBandwidth
            isEnabled = audioBandwidth > 0
            let sliderMinValue = UInt(bitPattern: (bandwidthSlider.minValue))
            let audioBandwidthValue = UInt(bitPattern: audioBandwidth)
            bandwidthSlider.currentValue = audioBandwidth < sliderMinValue ? sliderMinValue : audioBandwidthValue
            
            let audioCodec = settings.mediaConfiguration.audioCodec
            self?.updateBandwidthSliderModelRange(bandwidthSlider, using: audioCodec)
            
            #endif
            switchItem.on = isEnabled
            bandwidthSlider.isDisabled = isEnabled
            return [switchItem, bandwidthSlider]
        })
    }
    
    // MARK: - Overrides
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case Int(AudioSettingsSectionType.audioCodec.rawValue):
            updateSelection(at: indexPath)
            updateBandwidthValue(for: indexPath)
            applySettings()
            
        default:
            break
        }
    }
    
    // MARK: - Overrides SettingsCellDelegate
    override func cell(_ cell: BaseSettingsCell, didChageModel model: BaseItemModel) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        if indexPath.section == AudioSettingsSectionType.bandwidth.rawValue, model is SwitchItemModel {
            guard let bandwidth = section(with: AudioSettingsSectionType.bandwidth.rawValue) else {
                return
            }
            let switchItem = bandwidth.items[AudioBandwidthSection.enable.rawValue] as? SwitchItemModel
            
            let bandwidthSlider = bandwidth.items[AudioBandwidthSection.bandwidth.rawValue] as? SliderItemModel
            
            if let isEnabled = switchItem?.on, let bandwidthSlider = bandwidthSlider {
                
                bandwidthSlider.isDisabled = isEnabled
                
                if isEnabled == false {
                    bandwidthSlider.currentValue = UInt(bitPattern: bandwidthSlider.minValue)
                }
            }
            let sectionToReload = NSIndexSet(index: AudioSettingsSectionType.bandwidth.rawValue)
            tableView.reloadSections(sectionToReload as IndexSet, with: .fade)
        }
    }
    
    override func applySettings() {
        //APPLY SETTINGS
        //constraints
        let settings = Settings()
        let constraints = section(with: AudioSettingsSectionType.constraints.rawValue)
        if let levelControlSwitch = constraints?.items.first as? SwitchItemModel {
            settings.mediaConfiguration.isAudioLevelControlEnabled = levelControlSwitch.on
        } else {
            settings.mediaConfiguration.isAudioLevelControlEnabled = false
        }
        
        //Video codec
        guard let audioCodecIndexPath = indexPath(atSection: AudioSettingsSectionType.audioCodec.rawValue),
            let audioCodec = model(with: audioCodecIndexPath.row, section: audioCodecIndexPath.section),
            let audioCodecData = audioCodec.data as? QBRTCAudioCodec else {
                return
        }
        settings.mediaConfiguration.audioCodec = audioCodecData
        
        //bandwidth
        let bandwidth = section(with: AudioSettingsSectionType.bandwidth.rawValue)
        let switchItem = bandwidth?.items[AudioBandwidthSection.enable.rawValue] as? SwitchItemModel
        if let isEnabled = switchItem?.on, isEnabled == true,
            let bandwidthSlider = bandwidth?.items[AudioBandwidthSection.bandwidth.rawValue] as? SliderItemModel {
            settings.mediaConfiguration.audioBandwidth = Int(bitPattern: bandwidthSlider.currentValue)
        } else {
            settings.mediaConfiguration.audioBandwidth = 0
        }
        settings.applyConfig()
        settings.saveToDisk()
    }
    
    // MARK: - Helpers
    func updateBandwidthSliderModelRange(_ sliderModel: SliderItemModel?, using codec: QBRTCAudioCodec) {
        let range: AudioCodecBandWidthRange = audioCodecRangeForCodec(codec: codec)
        sliderModel?.currentValue = UInt(range.minValue)
        sliderModel?.minValue = range.minValue
        sliderModel?.maxValue = range.maxValue
    }
    
    func updateBandwidthValue(for indexPath: IndexPath) {
        let bandwidth = section(with: AudioSettingsSectionType.bandwidth.rawValue)
        let switchItem = bandwidth?.items[AudioBandwidthSection.enable.rawValue] as? SwitchItemModel
        let bandwidthSlider = bandwidth?.items[AudioBandwidthSection.bandwidth.rawValue] as? SliderItemModel
        let audioCodec = model(with: indexPath.row, section: indexPath.section)
        if let audioCodecData = audioCodec?.data as? QBRTCAudioCodec {
            updateBandwidthSliderModelRange(bandwidthSlider, using: audioCodecData)
        }
        bandwidthSlider?.isDisabled = true
        switchItem?.on = false
        tableView.reloadSections(NSIndexSet(index: AudioSettingsSectionType.bandwidth.rawValue) as IndexSet,
                                 with: .fade)
    }
}
