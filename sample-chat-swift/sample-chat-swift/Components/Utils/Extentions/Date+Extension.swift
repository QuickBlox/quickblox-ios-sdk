//
//  Date+Extension.swift
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
    
    func setupDate() -> String {
        let formatter = DateFormatter()
        var dateString = ""
        if Calendar.current.isDateInToday(self) == true {
            dateString = messageTimeDateFormatter.string(from: self)
        } else if Calendar.current.isDateInYesterday(self) == true {
            dateString = "Yesterday"
        } else if self.hasSame([.year], as: Date()) == true {
            formatter.dateFormat = "d MMM"
            dateString = formatter.string(from: self)
        } else {
            formatter.dateFormat = "d.MM.yy"
            var anotherYearDate = formatter.string(from: self)
            if (anotherYearDate.hasPrefix("0")) {
                anotherYearDate.remove(at: anotherYearDate.startIndex)
            }
            dateString = anotherYearDate
        }
        return dateString
    }
}
