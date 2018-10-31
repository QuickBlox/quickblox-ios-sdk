//
//  SettingsSectionModel.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 22.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import Foundation

class SettingsSectionModel {
    var title = ""
    var items = [BaseItemModel]()

    class func section(withTitle title: String?, items: [BaseItemModel]?) -> SettingsSectionModel {
        let section = SettingsSectionModel()
        if let items = items, let title = title {
            section.title = title
            section.items = items
        }
        return section
    }
}
