//
//  BaseSettingsViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class BaseSettingsViewController: UITableViewController, SettingsCellDelegate {

    // MARK: Properties
    
    /**
     *  Settings storage.
     *
     *  @see Settings
     */
    var settings: Settings?
    /**
     *  Sections models.
     */
    var sections: [String: SettingsSectionModel] = [:]
    /**
     *  Selected indexes for each section.
     */
    var selectedIndexes: [String: IndexPath] = [:]

    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = Settings.instance
        selectedIndexes = [String: IndexPath]()
        sections = [String: SettingsSectionModel]()
        
        configure()
        registerNibs()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        applySettings()
    }

    // MARK: Public methods
    
    /**
     *  Settings section model for section index
     *
     *  @param sectionType section index
     *
     *  @return Settings section model
     */
    func section(with sectionType: Int) -> SettingsSectionModel? {
        
        let title = self.title(forSection: sectionType)
        let section: SettingsSectionModel? = sections[title ?? ""]
        return section
    }
    
    /**
     * Index path for section index.
     *
     *  @param section Section index
     *
     *  @return Index path for section index
     */
    func indexPath(atSection section: Int) -> IndexPath? {
        
        let key = title(forSection: section)
        let indexPath = selectedIndexes[key!]
        
        return indexPath
    }
    
    /**
     *  Model for section with index.
     *
     *  @param index model index
     *  @param section section index
     *
     *  @return model for section
     */
    func model(with index: Int, section: Int) -> BaseItemModel? {
        
        let sectionModel: SettingsSectionModel? = self.section(with: section)
        
        if sectionModel?.items.count == 0 {
            return nil
        }
        
        let model: BaseItemModel? = sectionModel?.items[index]
        return model
    }
    
    /**
     *  Add section with index and items.
     *
     *  @param section section index
     *  @param items items for section
     *
     *  @return settings section model
     */
    
    func addSection(with section: Int, items: @escaping (_ sectionTitle: String?) -> [BaseItemModel]) {
        
        let sectionTitle = title(forSection: section)
        let sectionModel = SettingsSectionModel.section(withTitle: sectionTitle, items: items(sectionTitle))
        sections[sectionTitle!] = sectionModel

    }
    
//    func addSection(with section: Int, items: @escaping (_ sectionTitle: String?) -> [Any]) -> SettingsSectionModel? {
//
//        let sectionTitle = title(forSection: section)
//        let sectionModel = SettingsSectionModel.section(withTitle: sectionTitle, items: items(sectionTitle) as? [BaseItemModel])
//        sections[sectionTitle!] = sectionModel
//
//        return sectionModel
//    }

    /**
     *  Select item at section.
     *
     *  @param section section index
     *  @param index item index
     */
    func selectSection(_ section: Int, index: Int) {
        var index = index
        
        if index == NSNotFound {
            index = 0
        }
        
        let sectionTitle = title(forSection: section)
        let supportedFormatsIndexPath = IndexPath(row: index, section: section)
        selectedIndexes[sectionTitle!] = supportedFormatsIndexPath
    }
    
    /**
     *  Update selection by selecting a new item and deselecting old one.
     *
     *  @param indexPath index path of requested item
     */
    func updateSelection(at indexPath: IndexPath?) {
        
        let key = title(forSection: (indexPath?.section)!)
        let previosIndexPath = selectedIndexes[key!]
        
        if let aPath = previosIndexPath {
            if ((indexPath?.compare(aPath)) != nil) {
                return
            }
        }
        if let aCopy = indexPath {
            selectedIndexes[key!] = aCopy
        }
        
        tableView.reloadRows(at: [previosIndexPath!, indexPath!], with: .fade)
    }
    
    // MARK: Override
    func configure() {
        assert(false, "Must be overriden in superclass.")
    }
    
    func applySettings() {
        assert(false, "Must be overriden in superclass.")
    }
    
    func title(forSection section: Int) -> String? {
        assert(false, "Must be overriden in superclass.")
        return nil
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionItem: SettingsSectionModel? = self.section(with: section)
        return sectionItem?.title
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionItem: SettingsSectionModel? = self.section(with: section)
        return sectionItem?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionItem: SettingsSectionModel? = section(with: indexPath.section)
        let itemModel: BaseItemModel? = sectionItem?.items[indexPath.row]
       
        debugPrint("itemModel? \(String(describing: itemModel?.title))")
       let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass((itemModel?.viewClass())!).components(separatedBy: ".").last!) as! BaseSettingsCell
            let key = title(forSection: indexPath.section)
        debugPrint(title(forSection: indexPath.section)!)
//            debugPrint("itemModel?.viewClass() \(String(describing: NSStringFromClass((itemModel?.viewClass())!).components(separatedBy: ".").last!))")
            let selectedIndexPath = selectedIndexes[key!]
//            if let aPath = selectedIndexPath {
//        cell.accessoryType = indexPath.compare(selectedIndexPath!) == .orderedSame ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
//            }
        
        cell.delegate = self
        cell.updateModel(itemModel!)
        
        return cell
    }
    
    // MARK: SettingsCellDelegate
    func cell(_ cell: BaseSettingsCell?, didChageModel model: BaseItemModel?) {
        
        assert(false, "Required method of SettingsCellDelegate must be implemented in superclass.")
    }
    
    // Private:
    func registerNibs() {

//        tableView.register(SettingCell.nib(), forCellReuseIdentifier: SettingCell.identifier()!)
//        tableView.register(SettingSwitchCell.nib(), forCellReuseIdentifier: SettingSwitchCell.identifier()!)
//        tableView.register(SettingSliderCell.nib(), forCellReuseIdentifier: SettingSliderCell.identifier()!)
        tableView.register(UINib(nibName: "SettingCell", bundle: nil), forCellReuseIdentifier: "SettingCell")
        tableView.register(UINib(nibName: "SettingSwitchCell", bundle: nil), forCellReuseIdentifier: "SettingSwitchCell")
        tableView.register(UINib(nibName: "SettingSliderCell", bundle: nil), forCellReuseIdentifier: "SettingSliderCell")
    }
}
