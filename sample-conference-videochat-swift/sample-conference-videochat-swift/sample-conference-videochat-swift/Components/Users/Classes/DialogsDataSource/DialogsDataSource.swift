//
//  DialogsDataSource.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 11.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

struct DialogsDataSourceConstant {
    static let selectChatDialog = NSLocalizedString("Select chat dialog to join conference into", comment: "")
}

protocol DialogsDataSourceDelegate: class {
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?, dialogCellDidTapListener dialogCell: UITableViewCell?)
    
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?, dialogCellDidTapAudio dialogCell: UITableViewCell?)
    
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?, dialogCellDidTapVideo dialogCell: UITableViewCell?)
    
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource?, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath?)
}

class DialogsDataSource: NSObject {
    weak var delegate: DialogsDataSourceDelegate?
    var objects = [QBChatDialog]()
    var selectedObjects = [QBChatDialog]()
    private let sortSelector: Selector = #selector(getter: QBCEntity.createdAt)
    
    // MARK: Public
    func updateObjects(_ objects: [QBChatDialog]) {
        self.objects = sortObjects(objects)
        selectedObjects = selectedObjects.filter({ objects.contains($0) })
    }
    
    func addObjects(_ objects: [QBChatDialog]) {
        updateObjects(self.objects + objects)
    }
    
    func selectObject(at indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        let object = objects[indexPath.row]
        if selectedObjects.contains(object) {
            selectedObjects.removeAll(where: { element in element == object })
        } else {
            selectedObjects.append(object)
        }
    }
    
    func deselectAllObjects() {
        selectedObjects = [QBChatDialog]()
    }
    
    // MARK: Private
    func sortObjects(_ objects: [QBChatDialog]) -> [QBChatDialog] {
        let key = NSStringFromSelector(sortSelector)
        let objectsSortDescriptor = NSSortDescriptor(key: key, ascending: false)
        guard let sortedObjects = (objects as NSArray).sortedArray(using: [objectsSortDescriptor])
            as? [QBChatDialog] else {return objects}
        return sortedObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DialogTableViewCell") as! DialogTableViewCell
        let chatDialog: QBChatDialog? = objects[indexPath.row]
        cell.title = chatDialog?.name
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DialogsDataSourceConstant.selectChatDialog
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        delegate?.dialogsDataSource(self, commit: editingStyle, forRowAt: indexPath)
    }
}

// MARK: UITableViewDataSource
extension DialogsDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
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
