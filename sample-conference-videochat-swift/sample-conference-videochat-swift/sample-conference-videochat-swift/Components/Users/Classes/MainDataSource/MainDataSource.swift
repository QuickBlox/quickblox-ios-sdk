//
//  MainDataSource.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 11.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class MainDataSource<T: Any> : NSObject, UITableViewDataSource where T: Equatable {
    
    var objects:Array<T> = []
    var selectedObjects:Array<T> = []
    
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
    func setObjects(_ objects: Array<T>?) {
        
        if let anObjects = objects {
            if !(self.objects == anObjects) {
                
                self.objects = sortObjects(objects)!
                
                var mutableSelectedObjects = selectedObjects
                for obj: T? in selectedObjects {
                    
                    if let anObj = obj {
                        if !self.objects.contains(anObj) {
                            mutableSelectedObjects.removeAll(where: { element in element == obj })
                        }
                    }
                }
                selectedObjects = mutableSelectedObjects
            }
        }
    }
    
    func selectObject(at indexPath: IndexPath?) {
        
        let obj = objects[indexPath?.row ?? 0]
        
        var mutableSelectedObjects = selectedObjects
        if selectedObjects.contains(obj) {
            mutableSelectedObjects.removeAll(where: { element in element == obj })
        } else {
            mutableSelectedObjects.append(obj)
        }
        selectedObjects = mutableSelectedObjects
    }
    
    func deselectAllObjects() {
        selectedObjects = [Any]() as! Array<T>
    }
    
    // MARK: Private
    func sortObjects(_ objects: Array<T>?) -> Array<T>? {
        
        // Create sort Descriptor
        
        let key = NSStringFromSelector(self.sortSelector!)
        
        let objectsSortDescriptor = NSSortDescriptor(key: key, ascending: false)
        
        let sortedObjects = (objects as NSArray?)?.sortedArray(using: [objectsSortDescriptor])
        
        return sortedObjects as? Array<T>
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if objects.count > 0 {
            return objects.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(false, "Required to be implemented by subclass.")
        let cell = UITableViewCell()
        return cell
    }
}
