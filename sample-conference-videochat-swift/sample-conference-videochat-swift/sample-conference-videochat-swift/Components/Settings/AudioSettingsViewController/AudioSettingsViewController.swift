//
//  AudioSettingsViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
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

    override func viewDidLoad() {
        super.viewDidLoad()
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
        //Constraints
        addSection(with: AudioSettingsSectionType.constraints.rawValue, items: { [weak self] sectionTitle in
            
            //audio level control
            let switchItem = SwitchItemModel()
            switchItem.title = "Audio level control"
            #if targetEnvironment(simulator)
            // Simulator
            switchItem.on = true
            #else
            // Device
            switchItem.on = (self?.settings.mediaConfiguration.isAudioLevelControlEnabled)!
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
            var isEnabled: Bool = false
            
            #if targetEnvironment(simulator)
            // Simulator
            isEnabled = true
            bandwidthSlider.currentValue = 30
            bandwidthSlider.minValue = 6
            bandwidthSlider.maxValue = 510
            #else
            // Device
            isEnabled = (self?.settings.mediaConfiguration.audioBandwidth)! > 0
            self?.updateBandwidthSliderModelRange(bandwidthSlider, using: (self?.settings.mediaConfiguration.audioCodec)!)
            bandwidthSlider.currentValue = (self?.settings.mediaConfiguration.audioBandwidth)! < UInt(bitPattern: (bandwidthSlider.minValue)) ? UInt(bitPattern: (bandwidthSlider.minValue)) : UInt(bitPattern: ((self?.settings.mediaConfiguration.audioBandwidth)!))
            #endif
            switchItem.on = isEnabled
            
            bandwidthSlider.isDisabled = isEnabled
            
            return [switchItem, bandwidthSlider]
        })
    }

    // MARK: - SettingsCellDelegate
    override func cell(_ cell: BaseSettingsCell, didChageModel model: BaseItemModel?) {
        
        var indexPath: IndexPath? = nil
 
            indexPath = tableView.indexPath(for: cell)
 
        if indexPath?.section == AudioSettingsSectionType.bandwidth.rawValue && (model is SwitchItemModel) {
            
            let bandwidth: SettingsSectionModel? = section(with: AudioSettingsSectionType.bandwidth.rawValue)
            let switchItem: SwitchItemModel? = bandwidth?.items[AudioBandwidthSection.enable.rawValue] as? SwitchItemModel
            let isEnabled = switchItem?.on
            let bandwidthSlider: SliderItemModel? = bandwidth?.items[AudioBandwidthSection.bandwidth.rawValue] as? SliderItemModel
            bandwidthSlider?.isDisabled = isEnabled!
            if !isEnabled! {
                bandwidthSlider?.currentValue = UInt(bitPattern: (bandwidthSlider?.minValue)!)
            }
            
            let sectionToReload = NSIndexSet(index: AudioSettingsSectionType.bandwidth.rawValue)
            tableView.reloadSections(sectionToReload as IndexSet, with: .fade)
        }
    }
    
    // MARK: - Helpers
    func updateBandwidthSliderModelRange(_ sliderModel: SliderItemModel?, using codec: QBRTCAudioCodec) {
        
        let range: AudioCodecBandWidthRange = audioCodecRangeForCodec(codec: codec)
        sliderModel?.currentValue = UInt(range.minValue)
        sliderModel?.minValue = range.minValue
        sliderModel?.maxValue = range.maxValue
    }
    
    func updateBandwidthValue(for indexPath: IndexPath?) {
        
        let bandwidth: SettingsSectionModel? = section(with: AudioSettingsSectionType.bandwidth.rawValue)
        let switchItem: SwitchItemModel? = bandwidth?.items[AudioBandwidthSection.enable.rawValue] as? SwitchItemModel
        let bandwidthSlider: SliderItemModel? = bandwidth?.items[AudioBandwidthSection.bandwidth.rawValue] as? SliderItemModel
        let audioCodec: BaseItemModel? = model(with: (indexPath?.row)!, section: (indexPath?.section)!)
        if let aValue = audioCodec?.data as? QBRTCAudioCodec {
            updateBandwidthSliderModelRange(bandwidthSlider, using: aValue)
        }
        
        bandwidthSlider?.isDisabled = true
        switchItem?.on = false
        
        tableView.reloadSections(NSIndexSet(index: AudioSettingsSectionType.bandwidth.rawValue) as IndexSet, with: .fade)
    }
    
    override func applySettings() {
        
        //APPLY SETTINGS
        //constraints
        let constraints: SettingsSectionModel? = section(with: AudioSettingsSectionType.constraints.rawValue)
        let levelControlSwitch: SwitchItemModel? = constraints?.items.first as? SwitchItemModel
        settings.mediaConfiguration.isAudioLevelControlEnabled = (levelControlSwitch?.on)!
        
        //bandwidth
        let bandwidth: SettingsSectionModel? = section(with: AudioSettingsSectionType.bandwidth.rawValue)
        let switchItem: SwitchItemModel? = bandwidth?.items[AudioBandwidthSection.enable.rawValue] as? SwitchItemModel
        let isEnabled = switchItem?.on
        if isEnabled ?? false {
            let bandwidthSlider: SliderItemModel? = bandwidth?.items[AudioBandwidthSection.bandwidth.rawValue] as? SliderItemModel
            settings.mediaConfiguration.audioBandwidth = Int(bitPattern: (bandwidthSlider?.currentValue)!)
        } else {
            settings.mediaConfiguration.audioBandwidth = 0
        }
    }
}
