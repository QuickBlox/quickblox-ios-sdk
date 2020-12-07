//
//  InfoTableViewController.swift
//  sample-push-notifications-swift
//
//  Created by Injoit on 12/30/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

struct InfoCellConstant {
    static let infoTableViewCellId = "InfoTableViewCell"
    static let logoTableViewCellId = "QBLogoTableViewCell"
}

class InfoTableViewController: UITableViewController {
    
    //MARK: - Properties
    var infoModels = [InfoModel]()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        
        setupTableView()
    }
    
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Internal Methods
    private func setupTableView() {
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
        let appNameModel = InfoModel()
        appNameModel.title = "Application name"
        appNameModel.info = appName ?? ""
        infoModels.append(appNameModel)
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let appVersionModel = InfoModel()
        appVersionModel.title = "Application version:"
        appVersionModel.info = "\(appVersion ?? "")"
        infoModels.append(appVersionModel)
        
        let quickBloxSdkVersionModel = InfoModel()
        quickBloxSdkVersionModel.title = "QuickBlox SDK version:"
        quickBloxSdkVersionModel.info = "\(QuickbloxFrameworkVersion)"
        infoModels.append(quickBloxSdkVersionModel)
        
        let appIDModel = InfoModel()
        appIDModel.title = "Application ID:"
        appIDModel.info = "\(QBSettings.applicationID)"
        infoModels.append(appIDModel)
        
        let authKeyModel = InfoModel()
        authKeyModel.title = "Auhtorization key:"
        authKeyModel.info = "\(QBSettings.authKey ?? "")"
        infoModels.append(authKeyModel)
        
        let authSecretModel = InfoModel()
        authSecretModel.title = "Auhtorization secret:"
        authSecretModel.info = "\(QBSettings.authSecret ?? "")"
        infoModels.append(authSecretModel)
        
        let accountKeyModel = InfoModel()
        accountKeyModel.title = "Account key:"
        accountKeyModel.info = "\(QBSettings.accountKey ?? "")"
        infoModels.append(accountKeyModel)
        
        let apiDomainModel = InfoModel()
        apiDomainModel.title = "API domain:"
        apiDomainModel.info = "\(QBSettings.apiEndpoint ?? "")"
        infoModels.append(apiDomainModel)
        
        let chatDomainModel = InfoModel()
        chatDomainModel.title = "Chat domain:"
        chatDomainModel.info = "\(QBSettings.chatEndpoint ?? "")"
        infoModels.append(chatDomainModel)
        
        let qaVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let qaVersionModel = InfoModel()
        qaVersionModel.title = "QA version"
        qaVersionModel.info = qaVersion ?? ""
        infoModels.append(qaVersionModel)
        
        let logoModel = InfoModel()
        logoModel.title = "logo"
        logoModel.info = "logo"
        infoModels.append(logoModel)
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isLast = indexPath.row == infoModels.count - 1
        if isLast == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: InfoCellConstant.logoTableViewCellId, for: indexPath)
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InfoCellConstant.infoTableViewCellId)
            as? InfoTableViewCell else {
                return UITableViewCell()
        }
        let model = infoModels[indexPath.row]
        cell.applyInfo(model: model)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isLast = indexPath.row == infoModels.count - 1
        return isLast ? 80.0 : 54.0
    }
}
