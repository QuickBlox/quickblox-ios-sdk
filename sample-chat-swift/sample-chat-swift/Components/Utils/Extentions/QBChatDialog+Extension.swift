//
//  QBChatDialog+Extension.swift
//  sample-chat-swift
//
//  Created by Injoit on 28.03.2022.
//  Copyright © 2022 quickBlox. All rights reserved.
//

import Foundation
import Quickblox

extension QBChatDialog {
    func joinWithCompletion(_ completion:@escaping QBChatCompletionBlock) {
        if type != .private, isJoined() {
            completion(nil)
            return
        }
        join { error in
            if let error = error {
                debugPrint("error._code = \(error._code)")
                if error._code == -1006 {
                    completion(nil)
                    return
                }
                completion(error)
                return
            }
            completion(nil)
        }
    }
}
