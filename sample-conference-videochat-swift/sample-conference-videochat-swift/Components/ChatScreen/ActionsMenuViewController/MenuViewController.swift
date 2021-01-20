//
//  MenuViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 09.01.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit

enum TypeActionsMenuVC {
    case chatInfo
    case appMenu
    case mediaInfo
}

struct MenuConstant {
    static let chatInfoHeight: CGFloat = 182.0
    static let chatInfoWidth: CGFloat = 154.0
    static let appMenuHeight: CGFloat = 280.0
    static let appMenuWidth: CGFloat = 177.0
    static let heightForRow: CGFloat = 44.0
    static let heightForUserProfileRow: CGFloat = 74.0
}

class MenuViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!

    var cancelAction:(() -> Void)?
    private var actions:[MenuAction] = []
    var typeActionsMenuVC: TypeActionsMenuVC?

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cancelAction?()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupViews()
    }
    
    private func setupViews() {
        guard let typePopVC = typeActionsMenuVC else {return}
        
        let heightConstant = tableView.contentSize.height + 6.0
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32.0).isActive = true
        switch typePopVC {
        case .chatInfo:
            containerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -22.0).isActive = true
            containerView.widthAnchor.constraint(equalToConstant: MenuConstant.chatInfoWidth).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
            containerView.addShadowToView(color: #colorLiteral(red: 0.7834715247, green: 0.8073117137, blue: 0.8447045684, alpha: 1))
        case .appMenu:
            containerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 22.0).isActive = true
            containerView.widthAnchor.constraint(equalToConstant: MenuConstant.appMenuWidth).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: MenuConstant.appMenuHeight).isActive = true
            containerView.addShadowToView(color: #colorLiteral(red: 0.7834715247, green: 0.8073117137, blue: 0.8447045684, alpha: 1))
        case .mediaInfo:
            containerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -22.0).isActive = true
            containerView.widthAnchor.constraint(equalToConstant: MenuConstant.chatInfoWidth).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 3.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -3.0).isActive = true
        tableView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        
        containerView.setRoundView(cornerRadius: 6.0)
        tableView.isUserInteractionEnabled = true
        tableView.reloadData()
    }
    
    func addAction(_ action: MenuAction) {
        actions.append(action)
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        dismiss(animated: false) {
            self.cancelAction?()
        }
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuActionCellConstant.reuseIdentifier, for: indexPath) as? MenuActionCell else {
            return UITableViewCell()
        }
        
        let menuAction = actions[indexPath.row]
        cell.actionLabel.text = menuAction.title
        if let type = typeActionsMenuVC, type == .appMenu {
            if menuAction.action == .userProfile {
                cell.actionLabel.font = .systemFont(ofSize: 15.0, weight: .medium)
            }
            if indexPath.row == 1 || indexPath.row == actions.count - 1 {
                cell.separatorView.isHidden = false
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuAction = actions[indexPath.row]
        DispatchQueue.main.async(execute: {
            self.dismiss(animated: false) {
                menuAction.successHandler?(menuAction.action)
                self.cancelAction?()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let menuAction = actions[indexPath.row]
        if let type = typeActionsMenuVC, type == .appMenu {
            if menuAction.action == .logout || menuAction.action == .userProfile {
                return MenuConstant.heightForUserProfileRow
            }
        }
        return MenuConstant.heightForRow
    }
}
