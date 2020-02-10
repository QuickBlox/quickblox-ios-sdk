//
//  Date+Extention.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import Foundation

extension Date {
    func hasSame(_ components: Set<Calendar.Component>, as date: Date, using calendar: Calendar = .autoupdatingCurrent) -> Bool {
             return components.filter { calendar.component($0, from: date) != calendar.component($0, from: self) }.isEmpty
    }
}
