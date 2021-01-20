//
//  ConferenceView.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 01.09.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import Foundation

protocol ConferenceView: BaseView {
    var conferenceSettings: ConferenceSettings { get set }
    var didClosedCallScreen: ((_ isClosedCall: Bool) -> Void)? { get set }
    func leaveFromCallAnimated(_ isAnimated: Bool, completion:(() -> Void)?)
}
