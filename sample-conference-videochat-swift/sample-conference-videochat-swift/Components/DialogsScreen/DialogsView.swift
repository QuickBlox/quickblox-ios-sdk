//
//  DialogsView.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 01.09.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import Foundation

protocol DialogsView: BaseView {
    var onOpenChatScreenWithDialogID: ((_ dialogID: String, _ isNewCreated: Bool) -> Void)? { get set }
    var onSignIn: (() -> Void)? { get set }
}
