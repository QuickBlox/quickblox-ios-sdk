//
//  ConferenceModuleFactory.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 01.09.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import Foundation

protocol ConferenceModuleFactory {
    func makeConferenceOutput(withSettings settings: ConferenceSettings) -> ConferenceView
    func makeStreamInitiatorOutput(withSettings settings: ConferenceSettings) -> ConferenceView
    func makeStreamParticipantOutput(withSettings settings: ConferenceSettings) -> ConferenceView
}
