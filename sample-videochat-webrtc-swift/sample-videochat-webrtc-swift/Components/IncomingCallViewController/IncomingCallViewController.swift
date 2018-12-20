//
//  IncomingCallViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Vladimir Nybozhinsky on 12/18/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC
import Quickblox

protocol IncomingCallViewControllerDelegate: NSObjectProtocol {
  func incomingCallViewController(_ vc: IncomingCallViewController, didAccept session: QBRTCSession)
  func incomingCallViewController(_ vc: IncomingCallViewController, didReject session: QBRTCSession)
}

class IncomingCallViewController: UIViewController, QBRTCClientDelegate {
  
  @IBOutlet private weak var callStatusLabel: UILabel!
  @IBOutlet private weak var callInfoTextView: UITextView!
  @IBOutlet private weak var toolbar: ToolBar!
  @IBOutlet private weak var colorMarker: CornerView!
  private var users: [QBUUser] = []
  private var dialignTimer: Timer?
  
  weak var delegate: IncomingCallViewControllerDelegate?
  var session: QBRTCSession?
  var usersDatasource: UsersDataSource?
  
  deinit {
    debugPrint("deinit \(self)")
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    QBRTCClient.instance().add(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    SoundManager.playRingtoneSound()
    var users: [QBUUser] = []
    if let session = session,
      let usersDatasource = usersDatasource {
      for uID in session.opponentsIDs {
        if let user = usersDatasource.user(withID: uID.uintValue) {
          users.append(user)
        } else {
          let user = QBUUser()
          user.id = uID.uintValue
          users.append(user)
        }
      }
    }
    self.users = users
    confiugreGUI()
    dialignTimer = Timer.scheduledTimer(timeInterval: QBRTCConfig.dialingTimeInterval(),
                                        target: self,
                                        selector: #selector(dialing(_:)),
                                        userInfo: nil,
                                        repeats: true)
  }
  
  @objc func dialing(_ timer: Timer?) {
    SoundManager.playRingtoneSound()
  }
  
  // MARK: - Update GUI
  func confiugreGUI() {
    defaultToolbarConfiguration()
    updateOfferInfo()
    updateCallInfo()
    if let currentUser = QBChat.instance.currentUser {
      title = "Logged in as \(String(describing: currentUser.fullName))"
    }
  }
  
  func defaultToolbarConfiguration() {
    toolbar.backgroundColor = UIColor.clear
    toolbar.add(ButtonsFactory.circleDecline(), action: { [weak self] sender in
      guard let `self` = self else {
        return
      }
      self.cleanUp()
      if let session = self.session {
        self.delegate?.incomingCallViewController(self, didReject: session)
      }
    })
    
    toolbar.add(ButtonsFactory.answer(), action: { [weak self] sender in
      guard let `self` = self else {
        return
      }
      self.cleanUp()
      if let session = self.session {
        self.delegate?.incomingCallViewController(self, didAccept: session)
      }
    })
    toolbar.updateItems()
  }
  
  // MARK: - Actions
  func cleanUp() {
    dialignTimer?.invalidate()
    dialignTimer = nil
    QBRTCClient.instance().remove(self)
    SoundManager.instance.stopAllSounds()
  }
  
  func updateOfferInfo() {
    
    if let usersDatasource = usersDatasource,
      let session = session,
      let caller = usersDatasource.user(withID: session.initiatorID.uintValue) {
      colorMarker.bgColor = UIColor.gray
      colorMarker.title = caller.fullName ?? ""
      colorMarker.fontSize = 30.0
    }
  }
  
  func updateCallInfo() {
    
    var info: [String] = []
    for user in users {
      info.append("\(String(describing: user.fullName))(ID \(user.id))")
    }
    callInfoTextView.text = info.joined(separator: ", ")
    callInfoTextView.font = UIFont(name: "HelveticaNeue-Thin", size: 19)
    callInfoTextView.textAlignment = .center
    let text = session?.conferenceType == QBRTCConferenceType.video ? "Incoming video call" : "Incoming audio call"
    callStatusLabel.text = NSLocalizedString(text, comment: "")
  }
  
  func sessionDidClose(_ session: QBRTCSession) {
    if self.session == session {
      cleanUp()
    }
  }
}
