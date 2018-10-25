//
//  SessionSettingsViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

protocol SettingsViewControllerDelegate: class {
    func settingsViewController(_ vc: SessionSettingsViewController?, didPressLogout sender: Any?)
}

enum SessionConfigureItem : Int {
    case video
    case auido
}


class SessionSettingsViewController: UITableViewController {
    
    @IBOutlet private weak var versionLabel: UILabel!
    private var settings: Settings?
    weak var delegate: SettingsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = Settings.instance
        
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
        debugPrint("settings \(String(describing: settings))")
        settings?.saveToDisk()
        settings?.applyConfig()
        dismiss(animated: true)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.detailTextLabel?.text = detailTextForRow(atIndexPaht: indexPath)
        
        #if targetEnvironment(simulator)
        // Simulator
        if indexPath.row == SessionConfigureItem.video.rawValue && indexPath.section == 0 {
            cell.isUserInteractionEnabled = false
        }
        #endif
        
        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let cell: UITableViewCell? = tableView.cellForRow(at: indexPath)
        if (cell?.reuseIdentifier == "LogoutCell") {
            
            let alertController = UIAlertController(title: nil, message: NSLocalizedString("Logout ?", comment: ""), preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { action in
                self.delegate?.settingsViewController(self, didPressLogout: cell)
            }))
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("NO", comment: ""), style: .default, handler: nil))
            
            present(alertController, animated: true)
        }
    }
    
    func detailTextForRow(atIndexPaht indexPath: IndexPath?) -> String? {
        
        if indexPath?.row == SessionConfigureItem.video.rawValue {
            
            #if targetEnvironment(simulator)
            // Simulator
            return "unavailable"
            #else
            // Device
            return String(format: "%tux%tu", settings?.videoFormat?.width ?? 640, settings?.videoFormat?.height ?? 480)
            #endif

        } else if indexPath?.row == SessionConfigureItem.auido.rawValue {
            
            return ""
        }
        
        return "Unknown"
    }
}
