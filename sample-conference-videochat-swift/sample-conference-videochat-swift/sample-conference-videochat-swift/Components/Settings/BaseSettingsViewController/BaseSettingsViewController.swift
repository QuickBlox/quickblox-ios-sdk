//
//  BaseSettingsViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

//class BaseSettingsViewController: UITableViewController, SettingsCellDelegate {
class BaseSettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

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
        var sections: [AnyHashable : Any] = [:]
        /**
         *  Selected indexes for each section.
         */
        var selectedIndexes: [AnyHashable : Any] = [:]
        
        // MARK: Public methods
        
        /**
         *  Settings section model for section index
         *
         *  @param sectionType section index
         *
         *  @return Settings section model
         */
        func section(with sectionType: Int) -> SettingsSectionModel? {
        }
        
        /**
         * Index path for section index.
         *
         *  @param section Section index
         *
         *  @return Index path for section index
         */
        func indexPath(atSection section: Int) -> IndexPath? {
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
        }
        
        /**
         *  Add section with index and items.
         *
         *  @param section section index
         *  @param items items for section
         *
         *  @return settings section model
         */
        func addSection(with section: Int, items: @escaping (_ sectionTitle: String?) -> [Any]) -> SettingsSectionModel? {
        }
        
        /**
         *  Select item at section.
         *
         *  @param section section index
         *  @param index item index
         */
        func selectSection(_ section: Int, index: Int) {
        }
        
        /**
         *  Update selection by selecting a new item and deselecting old one.
         *
         *  @param indexPath index path of requested item
         */
        func updateSelection(at indexPath: IndexPath?) {
        }


}
