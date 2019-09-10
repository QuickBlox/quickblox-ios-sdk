//
//  SessionSettingsViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/10/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

protocol SettingsViewControllerDelegate: class {
    func settingsViewController(_ vc: SessionSettingsViewController, didPressLogout sender: Any)
}

enum SessionConfigureItem : Int {
    case video
    case auido
}

struct SessionSettingsConstant {
    static let LogoutCellIdentifier = "LogoutCell"
    static let logoutMessage = NSLocalizedString("Logout ?", comment: "")
    static let yesMessage = NSLocalizedString("Yes", comment: "")
    static let noMessage = NSLocalizedString("NO", comment: "")
}

class SessionSettingsViewController: UITableViewController {
    //MARK: - IBOutlets
    @IBOutlet private weak var versionLabel: UILabel!
    
    //MARK: - Properties
    weak var delegate: SettingsViewControllerDelegate?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let version = """
        Sample version \(appVersion ?? "") build \(appBuild ?? "").\n\
        QuickBlox WebRTC SDK: \(QuickbloxWebRTCFrameworkVersion) Revision \(QuickbloxWebRTCRevision)
        """
        versionLabel.text = version
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func pressDoneBtn(_ sender: Any) {
        doneAction()
    }
    
    private func doneAction() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Overrides
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.detailTextLabel?.text = detailTextForRow(atIndexPaht: indexPath)
        #if targetEnvironment(simulator)
        // Simulator
        if indexPath.row == SessionConfigureItem.video.rawValue, indexPath.section == 0 {
            cell.isUserInteractionEnabled = false
        }
        #endif
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath)
        if (cell?.reuseIdentifier == SessionSettingsConstant.LogoutCellIdentifier) {
            let alertController = UIAlertController(title: nil,
                                                    message: SessionSettingsConstant.logoutMessage,
                                                    preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: SessionSettingsConstant.yesMessage,
                                                    style: .default,
                                                    handler: { [weak self] action in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        self.delegate?.settingsViewController(self,
                                                                                              didPressLogout: cell as Any)
            }))
            alertController.addAction(UIAlertAction(title: SessionSettingsConstant.noMessage,
                                                    style: .default,
                                                    handler: nil))
            present(alertController, animated: true)
        }
    }
    
    //MARK: - Internal Methods
    func detailTextForRow(atIndexPaht indexPath: IndexPath) -> String {
        let settings = Settings()
        if indexPath.row == SessionConfigureItem.video.rawValue {
            #if targetEnvironment(simulator)
            // Simulator
            return "unavailable"
            #else
            // Device
            return "\(settings.videoFormat.width)x\(settings.videoFormat.height)"
            #endif
            
        } else if indexPath.row == SessionConfigureItem.auido.rawValue {
            
            switch (settings.mediaConfiguration.audioCodec) {
            case .codecOpus:
                return "Opus"
            case .codecISAC:
                return "ISAC"
            case .codeciLBC:
                return "iLBC"
            }
        }
        return "Unknown"
    }
}
