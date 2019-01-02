//
//  UsersDataSource.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 17.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

struct UsersDataSourceConstant {
    static let userCellIdentifier = "UserCell"
}

class UsersDataSource: NSObject {
    // MARK: - Properties
    var objects = [QBUUser]()
    var selectedObjects = [QBUUser]()
    private let sortSelector = #selector(getter: QBUUser.fullName)
    
    // MARK: Public Methods
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
    
    // MARK: - Internal Methods
    private func sortObjects(_ objects: [QBUUser]) -> [QBUUser] {
        let key = NSStringFromSelector(sortSelector)
        let objectsSortDescriptor = NSSortDescriptor(key: key, ascending: false)
        guard let sorted = (objects as NSArray).sortedArray(using: [objectsSortDescriptor]) as? [QBUUser] else {
                return objects
        }
        return sorted
    }
    
    func user(withID ID: UInt) -> QBUUser? {
        return objects.filter{ $0.id == ID }.first
    }
}

extension UsersDataSource: UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UsersDataSourceConstant.userCellIdentifier)
            as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        let user = objects[indexPath.row]
        let selected = selectedObjects.contains(user)
        let size = CGSize(width: 32.0, height: 32.0)
        let userImage = PlaceholderGenerator.placeholder(size: size, title: user.fullName)
        
        cell.fullName = user.fullName
        cell.check = selected
        cell.userImage = userImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = String(format: "Select users to create chat dialog with (%tu)", selectedObjects.count)
        return title
    }
}


