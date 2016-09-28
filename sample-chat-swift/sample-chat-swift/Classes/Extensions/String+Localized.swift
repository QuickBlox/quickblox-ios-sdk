//
//  String+Localized.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/24/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
