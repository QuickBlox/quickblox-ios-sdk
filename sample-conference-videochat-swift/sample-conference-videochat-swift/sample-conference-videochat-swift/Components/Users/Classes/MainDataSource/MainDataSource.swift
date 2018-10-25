//
//  MainDataSource.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 11.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class MainDataSource<T: Any> : NSObject, UITableViewDataSource where T: Equatable {
    
    var objects = [T]()
    var selectedObjects = [T]()
    
    private var sortSelector: Selector? {
        didSet {
            debugPrint("sortSelector did set \(String(describing: sortSelector))")
        }
    }
    
    // MARK: Construction
    init(sortSelector: Selector) {
        self.sortSelector = sortSelector
    }
    
    // MARK: Public
    func updateObjects(_ objects: [T]) {
        self.objects = sortObjects(objects)
        selectedObjects = selectedObjects.filter({ objects.contains($0) })
    }
    
    func addObjects(_ objects: [T]) {
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
        selectedObjects = [T]()
    }
    
    // MARK: Private
    func sortObjects(_ objects: [T]) -> [T] {
        
        // Create sort Descriptor
        guard let sortSelector = self.sortSelector else {
            return objects
        }
        let key = NSStringFromSelector(sortSelector)
        let objectsSortDescriptor = NSSortDescriptor(key: key, ascending: false)
        guard let sortedObjects = (objects as NSArray).sortedArray(using: [objectsSortDescriptor])
            as? [T] else {return objects}
        return sortedObjects
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(false, "Required to be implemented by subclass.")
        let cell = UITableViewCell()
        return cell
    }
}
