//
//  AudioSettingsViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

enum AudioSettingsSectionType : Int {
    case constraints
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
    
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        applySettings()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Overrides superClass Methods
    override func title(forSection section: Int) -> String? {
        switch section {
        case AudioSettingsSectionType.constraints.rawValue:
            return "Constraints"
        case AudioSettingsSectionType.bandwidth.rawValue:
            return "Bandwidth"
        default:
            break
        }
        return nil
    }
    
    override func configure() {
        let settings = Settings()
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        
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
            print("audioBandwidth \(audioBandwidth)")
            print("audioBandwidthValue \(audioBandwidthValue)")
            print("sliderMinValue \(sliderMinValue)")
            print("bandwidthSlider.minValue \(bandwidthSlider.minValue)")
            
            
            let audioCodec = settings.mediaConfiguration.audioCodec
            self?.updateBandwidthSliderModelRange(bandwidthSlider, using: audioCodec)
            bandwidthSlider.currentValue = audioBandwidthValue > sliderMinValue ? audioBandwidthValue : sliderMinValue
            
            #endif
            switchItem.on = isEnabled
            bandwidthSlider.isDisabled = !isEnabled
            return [switchItem, bandwidthSlider]
        })
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
                bandwidthSlider.isDisabled = !isEnabled
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
}
