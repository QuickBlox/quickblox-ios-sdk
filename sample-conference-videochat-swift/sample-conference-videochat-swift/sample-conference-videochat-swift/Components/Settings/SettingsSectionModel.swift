//
//  SettingsSectionModel.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 22.10.2018.
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
