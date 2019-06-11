//
//  String+Trimming.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation

extension String {
  func stringByTrimingWhitespace() -> String {
    let squashed = replacingOccurrences(of: "[ ]+",
                                        with: " ",
                                        options: .regularExpression)
    return squashed.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
