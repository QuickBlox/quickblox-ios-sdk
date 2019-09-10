//
//  BaseSettingsViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/11/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

struct BaseSettingsConstant {
    static let settingCellIdentifier = "SettingCell"
    static let switchCellIdentifier = "SettingSwitchCell"
    static let sliderCellIdentifier = "SettingSliderCell"
}

class BaseSettingsViewController: UITableViewController, SettingsCellDelegate {
    // MARK: - Properties
    /**
     *  Sections models.
     */
    var sections: [String: SettingsSectionModel] = [:]
    /**
     *  Selected indexes for each section.
     */
    var selectedIndexes: [String: IndexPath] = [:]
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        registerNibs()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        applySettings()
    }
    
    // MARK: - Public Methods
    
    /**
     *  Settings section model for section index
     *
     *  @param sectionType section index
     *
     *  @return Settings section model
     */
    func section(with sectionType: Int) -> SettingsSectionModel? {
        guard let sectionTitle = self.title(forSection: sectionType), let section = sections[sectionTitle] else {
            return nil
        }
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
        guard let key = title(forSection: section) else {
            return nil
        }
        let indexPath = selectedIndexes[key]
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
        let sectionModel = self.section(with: section)
        if sectionModel?.items.isEmpty == true {
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
    func addSection(with section: Int, items: @escaping (_ sectionTitle: String) -> [BaseItemModel]) {
        guard let sectionTitle = title(forSection: section) else {
            return
        }
        let sectionModel = SettingsSectionModel.section(withTitle: sectionTitle,
                                                        items: items(sectionTitle))
        sections[sectionTitle] = sectionModel
    }
    
    /**
     *  Select item at section.
     *
     *  @param section section index
     *  @param index item index
     */
    func selectSection(_ section: Int, index: Int) {
        guard let sectionTitle = title(forSection: section) else {
            return
        }
        let indexRow = index == NSNotFound ? 0 : index
        let supportedFormatsIndexPath = IndexPath(row: indexRow, section: section)
        selectedIndexes[sectionTitle] = supportedFormatsIndexPath
    }
    
    /**
     *  Update selection by selecting a new item and deselecting old one.
     *
     *  @param indexPath index path of requested item
     */
    func updateSelection(at indexPath: IndexPath?) {
        guard let indexPath = indexPath, let key = title(forSection: indexPath.section),
            let previosIndexPath = selectedIndexes[key] else {
                return
        }
        if indexPath.compare(previosIndexPath) == .orderedSame {
            return
        }
        selectedIndexes[key] = indexPath
        tableView.reloadRows(at: [previosIndexPath, indexPath], with: .fade)
    }
    
    //MARK: - Must be overriden Methods
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
    
    //MARK: - Table View
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
        guard let sectionItem = section(with: indexPath.section) else {
            return UITableViewCell()
        }
        
        let itemModel = sectionItem.items[indexPath.row]
        
        guard let identifier = NSStringFromClass(itemModel.viewClass()).components(separatedBy: ".").last else {
            return UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? BaseSettingsCell else {
            return UITableViewCell()
        }
        
        guard let key = title(forSection: indexPath.section) else {
            return UITableViewCell()
        }
        
        if let selectedIndexPath = selectedIndexes[key] {
            let isSame = indexPath.compare(selectedIndexPath) == .orderedSame
            cell.accessoryType = isSame ? .checkmark : .none
        }
        cell.delegate = self
        cell.updateModel(itemModel)
        
        return cell
    }
    
    private func registerNibs() {
        tableView.register(UINib(nibName: BaseSettingsConstant.settingCellIdentifier, bundle: nil),
                           forCellReuseIdentifier: BaseSettingsConstant.settingCellIdentifier)
        tableView.register(UINib(nibName: BaseSettingsConstant.switchCellIdentifier, bundle: nil),
                           forCellReuseIdentifier: BaseSettingsConstant.switchCellIdentifier)
        tableView.register(UINib(nibName: BaseSettingsConstant.sliderCellIdentifier, bundle: nil),
                           forCellReuseIdentifier: BaseSettingsConstant.sliderCellIdentifier)
    }
    
    // MARK: SettingsCellDelegate
    func cell(_ cell: BaseSettingsCell, didChageModel model: BaseItemModel) {
        assert(false, "Required method of SettingsCellDelegate must be implemented in superclass.")
    }
}
