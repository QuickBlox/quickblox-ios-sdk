//
//  UsersDataSource.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 17.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

class UsersDataSource: NSObject {
    var objects = [QBUUser]()
    var selectedObjects = [QBUUser]()
    private let sortSelector: Selector = #selector(getter: QBUUser.fullName)
    
    // MARK: Public
    func updateObjects(_ objects: [QBUUser]) {
        self.objects = sortObjects(objects)
        selectedObjects = selectedObjects.filter({ objects.contains($0) })
    }
    
    func addObjects(_ objects: [QBUUser]) {
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
        selectedObjects = [QBUUser]()
    }
    
    // MARK: Private
    func sortObjects(_ objects: [QBUUser]) -> [QBUUser] {
        let key = NSStringFromSelector(sortSelector)
        let objectsSortDescriptor = NSSortDescriptor(key: key, ascending: false)
        guard let sortedObjects = (objects as NSArray).sortedArray(using: [objectsSortDescriptor])
            as? [QBUUser] else {return objects}
        return sortedObjects
    }
    
    func user(withID ID: Int) -> QBUUser? {
        for user in objects {
            if user.id == UInt(ID) {
                return user
            }
        }
        return nil
    }
}

// MARK: UITableViewDataSource
extension UsersDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        guard let userCell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserTableViewCell else { return cell }
        
        let user: QBUUser = objects[indexPath.row] as QBUUser
        let selected: Bool = self.selectedObjects.contains(user)
        let size = CGSize(width: 32, height: 32)
        let userImage: UIImage? = PlaceholderGenerator.placeholder(size: size, title: user.fullName)
        
        userCell.fullName = user.fullName
        userCell.check = selected
        userCell.userImage = userImage
        cell = userCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let str = String(format: "Select users to create chat dialog with (%tu)", selectedObjects.count)
        return NSLocalizedString(str, comment: "")
    }
}


