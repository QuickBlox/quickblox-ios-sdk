//
//  SelectedUsersView.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 29.07.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit

typealias SelectUserViewCancelCompletion = (_ userID: UInt) -> Void

struct SelectedUsersViewConstants {
    static let paddingLeft: CGFloat = 14.0
    static let spaceBetween: CGFloat = 2.0
    static let heightView: CGFloat = 24.0
}

class SelectedUsersView: UIView {
    //MARK: - IBOutlets
    @IBOutlet weak var maxUsersLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    //MARK: - Properties
    var onSelectedUserViewCancelTapped: SelectUserViewCancelCompletion?
    private var topConstraint: NSLayoutConstraint!
    private var selectedViews: [SelectedUserView] = [] {
        didSet {
            maxUsersLabel.isHidden = !selectedViews.isEmpty
        }
    }
    
    //MARK: - Public Methods
    func addView(_ userID: UInt, userName: String = "User") {
        let selectedUserView = SelectedUserView.loadNib()
        selectedUserView.name = userName
        selectedUserView.userID = userID
        
        selectedUserView.onCancelTapped = { [weak self] (userID) in
            self?.removeView(userID)
            self?.onSelectedUserViewCancelTapped?(userID)
        }
        
        containerView.addSubview(selectedUserView)
        selectedViews.append(selectedUserView)
        setupViews()
    }
    
    func removeView(_ userID: UInt) {
        guard let selectedView = self.selectedViews.filter({ $0.userID == userID }).first,
              let index = self.selectedViews.firstIndex(of: selectedView) else {
            return
        }
        selectedViews.remove(at: index)
        selectedView.removeFromSuperview()
        if selectedViews.count == 0 {
            return
        }
        for view in selectedViews {
            view.removeFromSuperview()
            containerView.addSubview(view)
        }
        setupViews()
    }
    
    func clear() {
        for selectedUserView in selectedViews {
            selectedUserView.removeFromSuperview()
        }
        selectedViews = []
    }
    
    //MARK: - Private Methods
    private func setupViews() {
        var previousView: SelectedUserView? = nil
        var viewsWidth: CGFloat = 0.0
        var spaceCount = 0
        for i in 0...selectedViews.count - 1 {
            let selectedUserView = selectedViews[i]
            selectedUserView.translatesAutoresizingMaskIntoConstraints = false
            selectedUserView.heightAnchor.constraint(equalToConstant: SelectedUsersViewConstants.heightView).isActive = true
            let selectedUserViewWidth: CGFloat = selectedUserView.nameLabel.intrinsicContentSize.width + 37.0
            selectedUserView.widthAnchor.constraint(equalToConstant: selectedUserViewWidth).isActive = true
            if let previous = previousView {
                let allwidth = SelectedUsersViewConstants.paddingLeft + (SelectedUsersViewConstants.spaceBetween * CGFloat(spaceCount)) + viewsWidth + selectedUserViewWidth
                if bounds.width > allwidth {
                    spaceCount = spaceCount + 1
                    selectedUserView.leftAnchor.constraint(equalTo: previous.rightAnchor, constant: SelectedUsersViewConstants.spaceBetween).isActive = true
                    selectedUserView.topAnchor.constraint(equalTo: previous.topAnchor).isActive = true
                } else {
                    topConstraint.constant = 3.0
                    spaceCount = 0
                    viewsWidth = 0.0
                    selectedUserView.leftAnchor.constraint(equalTo: leftAnchor, constant: SelectedUsersViewConstants.paddingLeft).isActive = true
                    selectedUserView.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 3.0).isActive = true
                }
            } else {
                spaceCount = 1
                topConstraint = selectedUserView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18.0)
                topConstraint.isActive = true
                selectedUserView.leftAnchor.constraint(equalTo: leftAnchor, constant: SelectedUsersViewConstants.paddingLeft).isActive = true
            }
            previousView = selectedUserView
            viewsWidth = viewsWidth + selectedUserViewWidth
        }
    }
}
