//
//  SettingsSectionModel.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/11/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import Foundation

class SettingsSectionModel {
    // MARK: - Properties
    var title = ""
    var items = [BaseItemModel]()
    
    // MARK: - Public Methods
    class func section(withTitle title: String, items: [BaseItemModel]) -> SettingsSectionModel {
        let section = SettingsSectionModel()
        section.title = title
        section.items = items
        return section
    }
}
