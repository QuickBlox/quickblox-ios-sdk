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
    static let dialogCellIdentifier = "DialogTableViewCell"
}

protocol DialogsDataSourceDelegate: class {
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource, dialogCellDidTapListener dialogCell: UITableViewCell)
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource, dialogCellDidTapAudio dialogCell: UITableViewCell)
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource, dialogCellDidTapVideo dialogCell: UITableViewCell)
    func dialogsDataSource(_ dialogsDataSource: DialogsDataSource, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
}

class DialogsDataSource: NSObject {
    // MARK: - Properties
    weak var delegate: DialogsDataSourceDelegate?
    var objects = [QBChatDialog]()
    var selectedObjects = [QBChatDialog]()
    private let sortSelector: Selector = #selector(getter: QBCEntity.createdAt)
    
    // MARK: Public Methods
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
    
    // MARK: - Internal Methods
    func sortObjects(_ objects: [QBChatDialog]) -> [QBChatDialog] {
        let key = NSStringFromSelector(sortSelector)
        let sortDescriptor = NSSortDescriptor(key: key, ascending: false)
        guard let sortedObjects = (objects as NSArray).sortedArray(using: [sortDescriptor])
            as? [QBChatDialog] else {return objects}
        return sortedObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        guard let dialogCell = tableView.dequeueReusableCell(withIdentifier: DialogsDataSourceConstant.dialogCellIdentifier) as? DialogTableViewCell else { return cell }
        let chatDialog = objects[indexPath.row]
        if let title = chatDialog.name {
            dialogCell.title = title
        }
        dialogCell.delegate = self
        cell = dialogCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DialogsDataSourceConstant.selectChatDialog
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        delegate?.dialogsDataSource(self, commit: editingStyle, forRowAt: indexPath)
    }
}

extension DialogsDataSource: UITableViewDataSource {
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
}

extension DialogsDataSource: DialogTableViewCellDelegate {
    // MARK: - DialogTableViewCellDelegate
    func dialogCellDidListenerButton(_ dialogCell: DialogTableViewCell) {
        delegate?.dialogsDataSource(self, dialogCellDidTapListener: dialogCell)
    }
    
    func dialogCellDidAudioButton(_ dialogCell: DialogTableViewCell) {
        delegate?.dialogsDataSource(self, dialogCellDidTapAudio: dialogCell)
    }
    
    func dialogCellDidVideoButton(_ dialogCell: DialogTableViewCell) {
        delegate?.dialogsDataSource(self, dialogCellDidTapVideo: dialogCell)
    }
}
