//
//  StatsView.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/18/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

struct StatsViewConstants {
    static let statsReportPlaceholderText = "Loading stats report..."
}


class StatsView: UIView {
    //MARK: - IBOutlets
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var participantButton: UIButton!

    //MARK: - Properties
    var callInfo: CallInfo! {
        didSet {
            selectedParticipant = callInfo.interlocutors.first
            
            callInfo.onChangedBitrate = { [weak self] (participant) in
                if self?.selectedParticipant?.userID != participant.iD { return }
                self?.updateStats(participant.statsString)
            }
        }
    }

    private var selectedParticipant: CallParticipant? {
         didSet {
             participantButton.setTitle("\(selectedParticipant?.fullName ?? "User") ⌵", for: .normal)
         }
     }

    //MARK: - Actions
    @IBAction func didTapBack(_ sender: UIButton) {
        removeFromSuperview()
    }

    @IBAction func didTapRarticipant(_ sender: UIButton) {
        let actionsMenuView = ActionsMenuView.loadNib()
        for participant in callInfo.interlocutors {
            participant.isSelected = participant.userID == self.selectedParticipant?.userID
            let selectParticipantAction = ActionMenu(title: participant.fullName,
                                                     isSelected: participant.isSelected,
                                                     action: .selectParticipant) { [weak self] action in
                if self?.selectedParticipant?.userID == participant.userID {
                    return
                }
                self?.selectedParticipant = participant
                self?.updateStats(StatsViewConstants.statsReportPlaceholderText)
            }
            actionsMenuView.addAction(selectParticipantAction)
        }
        addSubview(actionsMenuView)
        actionsMenuView.translatesAutoresizingMaskIntoConstraints = false
        actionsMenuView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0).isActive = true
        actionsMenuView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0).isActive = true
        actionsMenuView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0.0).isActive = true
        actionsMenuView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0).isActive = true
    }
    
    //MARK: - Private Methods
    private func updateStats(_ stats: String?) {
        statsLabel.text = stats ?? StatsViewConstants.statsReportPlaceholderText
    }
}
