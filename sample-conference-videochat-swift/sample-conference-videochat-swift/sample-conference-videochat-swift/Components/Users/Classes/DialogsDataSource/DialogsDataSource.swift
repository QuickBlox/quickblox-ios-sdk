//
//  DialogsDataSource.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 11.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

protocol DialogsDataSourceDelegate: class {
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?, dialogCellDidTapListener dialogCell: UITableViewCell?)
    
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?, dialogCellDidTapAudio dialogCell: UITableViewCell?)
    
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?, dialogCellDidTapVideo dialogCell: UITableViewCell?)
    
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath?)
}

class DialogsDataSource: MainDataSource<QBChatDialog> {
    weak var delegate: DialogsDataSourceDelegate?
    
    // MARK: Construction
    class func dialogsDataSource() -> Self {
       return self.init()
    }
    

    required init() {
        super.init(sortSelector: #selector(getter: QBCEntity.createdAt))
    }
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DialogTableViewCell") as? DialogTableViewCell
        
        let chatDialog: QBChatDialog? = objects[indexPath.row]
        
        cell?.title = chatDialog?.name
        cell?.delegate = self
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let str = "Select chat dialog to join conference into"
        
        return NSLocalizedString(str, comment: "")
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        delegate?.dialogsDataSource(self, commit: editingStyle, forRowAt: indexPath)
    }
}

// MARK: - DialogTableViewCellDelegate
extension DialogsDataSource: DialogTableViewCellDelegate {
    
    func dialogCellDidListenerButton(_ dialogCell: DialogTableViewCell?) {
        delegate?.dialogsDataSource(self, dialogCellDidTapListener: dialogCell)
    }
    
    func dialogCellDidAudioButton(_ dialogCell: DialogTableViewCell?) {
        delegate?.dialogsDataSource(self, dialogCellDidTapAudio: dialogCell)
    }
    
    func dialogCellDidVideoButton(_ dialogCell: DialogTableViewCell?) {
        delegate?.dialogsDataSource(self, dialogCellDidTapVideo: dialogCell)
    }
}
