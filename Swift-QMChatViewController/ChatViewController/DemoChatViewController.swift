//
//  DemoChatViewController.swift
//  Swift-QMChatViewController
//
//  Created by Vladimir Nybozhinsky on 09.11.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QMChatViewController

enum QMMessageType : UInt {
    case text = 0
    case createGroupDialog = 1
    case updateGroupDialog = 2
    case contactRequest = 4
    case acceptContactRequest
    case rejectContactRequest
    case deleteContactRequest
}

struct CredentialsConstant {
    static let applicationID:UInt = 72448
    static let authKey = "f4HYBYdeqTZ7KNb"
    static let authSecret = "ZC7dK39bOjVc-Z8"
    static let accountKey = "C4_z7nuaANnBYmsG_k98"
}

struct DemoChatConstant {
    static let timeIntervalBetweenSections: TimeInterval = 300.0
}

class DemoChatViewController: ChatViewController {
    
    @IBAction func unwind(toTab unwindSegue: UIStoryboardSegue) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        topContentAdditionalInset = ((navigationController?.navigationBar.frame.size.height)!) + UIApplication.shared.statusBarFrame.size.height
        
        senderID = 2000
        senderDisplayName = "hello"
        title = "Chat"
        
        QBSettings.applicationID = CredentialsConstant.applicationID;
        QBSettings.authKey = CredentialsConstant.authKey
        QBSettings.authSecret = CredentialsConstant.authSecret
        QBSettings.accountKey = CredentialsConstant.accountKey
        
        // Create test data source
        let message1 = QBChatMessage()
        message1.senderID = QMMessageType.contactRequest.rawValue
        message1.text = "Vladimir N.\nwould like to chat with you"
        message1.dateSent = Date(timeInterval: -12.0, since: Date())
        //
        let message2 = QBChatMessage()
        message2.senderID = senderID
        message2.text = "Why Q-municate is a right choice?"
        message2.dateSent = Date(timeInterval: -9.0, since: Date())
        //
        let message3 = QBChatMessage()
        message3.senderID = 20001
        message3.text = "Q-municate comes with powerful instant messaging right out of the box. Powered by the flexible XMPP protocol and Quickblox signalling technologies, with compatibility for server-side chat history, group chats, attachments and user avatars, it's pretty powerful. It also has chat bubbles and user presence (online/offline)."
        message3.dateSent = Date(timeInterval: -6.0, since: Date())
        // message with an attachment
        let message4 = QBChatMessage()
        message4.id = "4"
        message4.senderID = 20001
        
        let attachment = QBChatAttachment()
        let imagePath = Bundle.main.path(forResource: "quickblox-image", ofType: "png")
        attachment.url = imagePath
        message4.attachments = [attachment]
        message4.dateSent = Date(timeInterval: -3.0, since: Date())
        
        chatDataSource.add([message1, message2, message3, message4])
    }
    
    // MARK: Tool bar Actions
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: UInt, senderDisplayName: String, date: Date) {
        
        let message = QBChatMessage()
        message.text = text
        message.senderID = senderId
        message.dateSent = Date()
        
        chatDataSource.add(message)
        
        finishSendingMessage(animated: true)
    }
    
    override func didPickAttachmentImage(_ image: UIImage) {
        
        DispatchQueue.global(qos: .default).async(execute: {
            
            let resizedImage = self.resizedImage(from: image.fixOrientation())

            let binaryImageData = resizedImage.pngData()
            let imageName = "\(Date().timeIntervalSince1970)-attachment.png"
            let fileManager = FileManager.default
            let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName)
            fileManager.createFile(atPath: imagePath as String, contents: binaryImageData, attributes: nil)

            let message = QBChatMessage()
            message.senderID = self.senderID
            
            let attacment = QBChatAttachment()
            attacment.url = imagePath
            
            message.attachments = [attacment]
            message.dateSent = Date()
            
            self.chatDataSource.add(message)
            
            DispatchQueue.main.async(execute: {
                
                self.finishSendingMessage(animated: true)
            })
        })
    }
    
    override func viewClass(forItem item: QBChatMessage) -> AnyClass {
        
        if item.senderID == QMMessageType.contactRequest.rawValue {
            if item.senderID != senderID {
                return QMChatContactRequestCell.self
            }
        } else if item.senderID == QMMessageType.rejectContactRequest.rawValue  {
            return QMChatNotificationCell.self
            
        } else if item.senderID == QMMessageType.acceptContactRequest.rawValue  {
            return QMChatNotificationCell.self
            
        } else {
            if item.senderID != senderID {
                if item.attachments != nil, item.attachments?.isEmpty == false {
                    return QMChatAttachmentIncomingCell.self
                } else {
                    return QMChatIncomingCell.self
                }
            } else {
                if item.attachments != nil, item.attachments?.isEmpty == false {
                    return QMChatAttachmentOutgoingCell.self
                } else {
                    return QMChatOutgoingCell.self
                }
            }
        }
        return QMChatNotificationCell.self
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView, dynamicSizeAt indexPath: IndexPath, maxWidth: CGFloat) -> CGSize {
        
        let item = chatDataSource.message(for: indexPath)
        let viewClass: AnyClass = self.viewClass(forItem: item!)
        var size: CGSize
        
        if viewClass == QMChatAttachmentIncomingCell.self || viewClass == QMChatAttachmentOutgoingCell.self {
            size = CGSize(width: min(200, maxWidth), height: 200)
        } else {
            let attributedString: NSAttributedString? = self.attributedString(forItem: item!)
            
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)), limitedToNumberOfLines: 0)
        }
        
        return size
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView, minWidthAt indexPath: IndexPath) -> CGFloat {
        
        let item = chatDataSource.message(for: indexPath)
        
        var size = CGSize(width: 0, height: 0)
        
        if item != nil {
            
            let attributedString: NSAttributedString? = item?.senderID == senderID ? bottomLabelAttributedString(forItem: item!) : topLabelAttributedString(forItem: item!)
            
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: 1000.0, height: 10000.0), limitedToNumberOfLines: 1)
        }
        
        return size.width
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView, configureCell cell: UICollectionViewCell, for indexPath: IndexPath) {
        
        if let cell = cell as? ChatAttachmentCell {
            let message = chatDataSource.message(for: indexPath)
            
            if message?.attachments != nil {
                let attachment = message?.attachments!.first
                let url = URL(fileURLWithPath: (attachment?.url)!)
                do {
                    let imageData = try Data(contentsOf: url)
                    cell.setAttachmentImage(UIImage(data: imageData))

                } catch {
                    print(error)
                }
            }
        }
        cell.updateConstraints()
        
        super.collectionView(collectionView, configureCell: cell, for: indexPath)
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView, layoutModelAt indexPath: IndexPath) -> ChatCellLayoutModel {
        
        var layoutModel: ChatCellLayoutModel = super.collectionView(collectionView, layoutModelAt: indexPath)
        let item = chatDataSource.message(for: indexPath)
        
        layoutModel.avatarSize = CGSize(width: 0.0, height: 0.0)
        
        if item != nil {
            
            let topLabelString: NSAttributedString? = topLabelAttributedString(forItem: item!)
            let size = TTTAttributedLabel.sizeThatFitsAttributedString(topLabelString, withConstraints: CGSize(width: self.collectionView!.frame.width, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 1)
            layoutModel.topLabelHeight = size.height
        }
        
        return layoutModel
    }
    
    
    override func attributedString(forItem messageItem: QBChatMessage) -> NSAttributedString {
        
        let textColor = messageItem.senderID == senderID ? UIColor.white : UIColor(white: 0.290, alpha: 1.000)
        let font = UIFont(name: "Helvetica", size: 15)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: font!,
                                                         .foregroundColor: textColor]
        
        let attrStr = NSAttributedString(string: messageItem.text ?? "", attributes: attributes)
        return attrStr
    }
    
    override func topLabelAttributedString(forItem messageItem: QBChatMessage) -> NSAttributedString {
        
        let font = UIFont(name: "Helvetica", size: 14)
        
        if messageItem.senderID == senderID {
            return NSMutableAttributedString(string: "")
        }
        let attributes: [NSAttributedString.Key: UIFont] = [.font: font!]

        let attrStr = NSMutableAttributedString(string: "USER_NAME", attributes: attributes)
        
        return attrStr
    }
    
    override func bottomLabelAttributedString(forItem messageItem: QBChatMessage) -> NSAttributedString {
        
        let textColor = messageItem.senderID == senderID ? UIColor(white: 1.000, alpha: 0.510) : UIColor(white: 0.000, alpha: 0.490)
        let font = UIFont(name: "Helvetica", size: 12)
        
        var attributes: [NSAttributedString.Key : Any] = [:]
        
        attributes = [NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.font: font as Any]
        
        let attrStr = NSMutableAttributedString(string: timeStamp(with: messageItem.dateSent!), attributes: attributes)
        
        return attrStr
    }
    
    func timeStamp(with date: Date) -> String {
        
        var dateFormatter = DateFormatter()
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let timeStamp = dateFormatter.string(from: date)
        return timeStamp
    }
    
    func resizedImage(from image: UIImage) -> UIImage {
        let largestSide: CGFloat = image.size.width > image.size.height ? image.size.width : image.size.height
        let scaleCoefficient: CGFloat = largestSide / 560.0
        let newSize = CGSize(width: image.size.width / scaleCoefficient, height: image.size.height / scaleCoefficient)
        
        UIGraphicsBeginImageContext(newSize)
        
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return image
        }
        
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
