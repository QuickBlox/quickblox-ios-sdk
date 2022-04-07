//
//  InputContainer.swift
//  sample-chat-swift
//
//  Created by Injoit on 25.11.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit

struct InputContainerConstant {
    static let padding: CGFloat = 12.0
    static let cornerRadius: CGFloat = 4.0
}

protocol InputContainerDelegate: AnyObject {
    func inputContainer(_ container: InputContainer, didChangeValidState isValid: Bool)
}

class InputContainer: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputTextfield: UITextField!
    @IBOutlet weak var hintLabel: UILabel!
    weak var delegate: InputContainerDelegate?
    var hint = "Set a hint for your textfield here"
    var regexes:[String] = []
    
    private(set) var valid: Bool = false {
        didSet {
            delegate?.inputContainer(self, didChangeValidState: valid)
            if (inputTextfield.text?.isEmpty == true && inputTextfield.isFirstResponder == false) || valid == true {
                hintLabel.text = ""
            } else {
                hintLabel.text = hint
            }
        }
    }
    
    func setup(title: Title, hint: Hint, regexes: [Regex]) {
        inputTextfield.setPadding(left: InputContainerConstant.padding)
        inputTextfield.addShadow(color: #colorLiteral(red: 0.8755381703, green: 0.9203008413, blue: 1, alpha: 1), cornerRadius: InputContainerConstant.cornerRadius)
        titleLabel.text = title.rawValue
        self.hint = hint.rawValue
        hintLabel.text = ""
        self.regexes = regexes.compactMap { $0.rawValue }
    }
    
    @IBAction func editingDidBegin(_ sender: UITextField) {
        validate(texField: sender)
        sender.addShadow(color: #colorLiteral(red: 0.6745098039, green: 0.7490196078, blue: 0.8862745098, alpha: 1), cornerRadius: InputContainerConstant.cornerRadius)
    }
    @IBAction func editingChanged(_ sender: UITextField) {
        validate(texField: sender)
    }
    @IBAction func editingDidEnd(_ sender: UITextField) {
        validate(texField: sender)
        sender.addShadow(color: #colorLiteral(red: 0.8745098039, green: 0.9215686275, blue: 1, alpha: 1), cornerRadius: InputContainerConstant.cornerRadius)
    }
    
    private func validate(texField: UITextField) {
        guard let text = texField.text else {
            valid = false
            return
        }
        valid = text.isValid(regexes: regexes)
    }
}

extension String {
    func isValid(regexes: [String]) -> Bool {
        for regex in regexes {
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            if predicate.evaluate(with: self) == true {
                return true
            }
        }
        return false
    }
}
