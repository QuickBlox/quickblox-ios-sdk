//
//  SearchBar.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 30.06.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit

struct SearchBarConstant {
    static let searchBarHeight: CGFloat = 44.0
}

protocol SearchBarViewDelegate: AnyObject {
    func searchBarView(_ searchBarView: SearchBarView, didChangeSearchText searchText: String)
    func searchBarView(_ searchBarView: SearchBarView, didCancelSearchButtonTapped sender: UIButton)
}

class SearchBarView: UIView {
    
    //MARK: - Properties
    lazy private var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.barTintColor = .white
        searchBar.isTranslucent = true
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        return searchBar
    }()
    
    lazy private var cancelSearchButton: UIButton = {
        let cancelSearchButton = UIButton(type: .system)
        cancelSearchButton.setImage(UIImage(named: "ic_cancel"), for: .normal)
        cancelSearchButton.tintColor = #colorLiteral(red: 0.4255777597, green: 0.476770997, blue: 0.5723374486, alpha: 1)
        cancelSearchButton.isEnabled = true
        cancelSearchButton.addTarget(self,
                                     action: #selector(cancelSearchButtonTapped(_:)),
                                     for: .touchUpInside)
        return cancelSearchButton
    }()
    
    var searchText = ""
    
    weak var delegate: SearchBarViewDelegate?

    //MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupViews()
    }
    
    //MARK: - Setup
    private func setupViews() {
        addSubview(cancelSearchButton)
        cancelSearchButton.translatesAutoresizingMaskIntoConstraints = false
        cancelSearchButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        cancelSearchButton.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        cancelSearchButton.heightAnchor.constraint(equalToConstant: SearchBarConstant.searchBarHeight).isActive = true
        cancelSearchButton.widthAnchor.constraint(equalToConstant: 56.0).isActive = true
        
        addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: cancelSearchButton.leftAnchor, constant: -2.0).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: SearchBarConstant.searchBarHeight).isActive = true
        
        let iconSearch = UIImageView(image: UIImage(named: "search"))
        iconSearch.frame = CGRect(x: 0, y: 0, width: 28.0, height: 28.0)
        iconSearch.contentMode = .center
        searchBar.setRoundBorderEdgeColorView(cornerRadius: 0.0, borderWidth: 1.0, borderColor: .white)
        
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
            if let systemPlaceholderLabel = searchTextField.value(forKey: "placeholderLabel") as? UILabel {
                searchBar.placeholder = " "
                
                // Create custom placeholder label
                let placeholderLabel = UILabel(frame: .zero)
                
                placeholderLabel.text = "Search"
                placeholderLabel.font = .systemFont(ofSize: 15.0, weight: .regular)
                placeholderLabel.textColor = #colorLiteral(red: 0.4255777597, green: 0.476770997, blue: 0.5723374486, alpha: 1)
                
                systemPlaceholderLabel.addSubview(placeholderLabel)
                
                placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
                placeholderLabel.leadingAnchor.constraint(equalTo: systemPlaceholderLabel.leadingAnchor).isActive = true
                placeholderLabel.topAnchor.constraint(equalTo: systemPlaceholderLabel.topAnchor).isActive = true
                placeholderLabel.bottomAnchor.constraint(equalTo: systemPlaceholderLabel.bottomAnchor).isActive = true
                
                placeholderLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            }
            
            searchTextField.leftView = iconSearch
            searchTextField.backgroundColor = .white
            searchTextField.clearButtonMode = .never
        }
        searchBar.showsCancelButton = false
        cancelSearchButton.isHidden = true
    }
    
    //MARK: - Actions
    @objc private func cancelSearchButtonTapped(_ sender: UIButton) {
        cancelSearchButton.isHidden = true
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        delegate?.searchBarView(self, didCancelSearchButtonTapped: sender)
    }
    
}

// MARK: - UISearchBarDelegate
extension SearchBarView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        delegate?.searchBarView(self, didChangeSearchText: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        cancelSearchButton.isHidden = false
    }
}
