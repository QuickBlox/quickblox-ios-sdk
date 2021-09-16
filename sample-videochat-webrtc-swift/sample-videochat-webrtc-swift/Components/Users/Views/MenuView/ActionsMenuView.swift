//
//  ActionsMenuView.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 14.07.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit

struct MenuConstant {
    static let heightForRow: CGFloat = 44.0
    static let statsInfoWidth: CGFloat = 200.0
}

class ActionsMenuView: UIView {
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: MenuActionCellConstant.reuseIdentifier, bundle: nil),
                               forCellReuseIdentifier: MenuActionCellConstant.reuseIdentifier)
            tableView.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cancelButton: UIButton!

    //MARK: - Properties
    private var actions:[ActionMenu] = []
    
    //MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupViews()
    }
    
    //MARK: - Public Methods
    func addAction(_ action: ActionMenu) {
        actions.append(action)
    }
    
    //MARK: - Actions
    @IBAction func tapCancelButton(_ sender: Any) {
        removeFromSuperview()
    }
    
    //MARK: - Setup
    private func setupViews() {
        let heightConstant = tableView.contentSize.height + 6.0
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32.0).isActive = true
        containerView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -22.0).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: MenuConstant.statsInfoWidth).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
        containerView.addShadowToView(color: #colorLiteral(red: 0.7834715247, green: 0.8073117137, blue: 0.8447045684, alpha: 1))
        containerView.setRoundView(cornerRadius: 14.0)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 3.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -3.0).isActive = true
        tableView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        
        tableView.reloadData()
    }
}

//MARK: -  UITableViewDelegate, UITableViewDataSource
extension ActionsMenuView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuActionCellConstant.reuseIdentifier, for: indexPath) as? ActionMenuCell else {
            return UITableViewCell()
        }
        
        let menuAction = actions[indexPath.row]
        cell.actionLabel.text = menuAction.title
        cell.accessoryType = menuAction.isSelected == true ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuAction = actions[indexPath.row]
        DispatchQueue.main.async(execute: {
            self.removeFromSuperview()
            menuAction.successHandler?(menuAction.action)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MenuConstant.heightForRow
    }
}
