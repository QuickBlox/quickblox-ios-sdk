//
//  ChatDataSource.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

enum ChatDataSourceAction: Int {
    case add
    case update
    case remove
}

struct Key {
    static let dialogId = "dialog_id"
    static let newOccupantsIds = "new_occupants_ids"
    static let saveToHistory = "save_to_history"
    static let dateDividerKey = "kQBDateDividerCustomParameterKey"
    static let forwardedMessage = "origin_sender_name"
    static let attachmentSize = "size"
    static let notificationType = "notification_type"
    static let userID = "user_id"
    static let today = "Today"
    static let yesterday = "Yesterday"
}

protocol ChatDataSourceDelegate: AnyObject {
    func chatDataSource(_ chatDataSource: ChatDataSource,
                        willChangeWithMessageIDs IDs: [String])
    
    func chatDataSource(_ chatDataSource: ChatDataSource,
                        changeWithMessages messages: [QBChatMessage],
                        action: ChatDataSourceAction)
}

class ChatDataSource {
    //MARK: - Properties
    weak var delegate: ChatDataSourceDelegate?
    private(set) var messages: [QBChatMessage] = []

    var loadMessagesCount: Int {
        return messages.filter({
            if $0.isDateDividerMessage {
                return true
            }
            return false }).count
    }
    
    private var dividers: Set<Date> = []
    
    private var serialQueue = DispatchQueue(label: "com.chatvc.datasource.queue")
    
    //MARK: - Actions
    
    /**
     *  Message with index path.
     *
     *  @param indexPath    index path to find message
     *
     *  @return QBChatMessage instance that conforms to indexPath
     */
    func messageWithIndexPath(_ indexPath: IndexPath) -> QBChatMessage? {
        guard messages.isEmpty == false, indexPath.item != NSNotFound else {
            return nil
        }
        return messages[indexPath.item]
    }
    
    /**
     *  Index path With message.
     *
     *  @param message  message to return index path
     *
     *  @return NSIndexPath instance that conforms message or nil if not found
     */
    func messageIndexPath(_ message: QBChatMessage) -> IndexPath? {
        let objectIndex = messages.firstIndex{ $0 === message }
        guard let index = objectIndex else {
            return nil
        }
        if index != NSNotFound {
            return IndexPath(row: index, section: 0)
        }
        return nil
    }
    
    /**
     *  Returns a Boolean value that indicates whether a message is present in the data source.
     *
     *  @param message message to check
     *
     *  @return YES if message is present in the data source, otherwise NO.
     */
    func isExistMessage(_ message: QBChatMessage) -> Bool {
        return messages.contains(message)
    }
    
    func messageWithID(_ ID: String) -> QBChatMessage? {
        guard let message = messages.filter({ $0.id == ID }).first else {
            return nil
        }
        return message
    }
    
    func addMessage(_ message: QBChatMessage) {
        addMessages([message])
    }
    
    func addMessages(_ messages: [QBChatMessage]) {
        serialQueue.async { [weak self] in
            guard let self = self else { return }
            var messagesArray: [QBChatMessage] = []
            
            for message in messages {
                guard let messageDateSent = message.dateSent else { continue }
                let divideDate = Calendar.current.startOfDay(for: messageDateSent)
                if self.isExistMessage(message) == true, message.isDateDividerMessage {
                    if message.text == Key.today || message.text == Key.yesterday {
                        self.prepareDividerMessage(message, divideDate: divideDate)
                    }
                    continue
                }
                if message.isDateDividerMessage { continue }
                if self.isExistMessage(message) == true { continue }
                
                messagesArray.append(message)
                
                if self.dividers.contains(divideDate) { continue }
                self.dividers.insert(divideDate)
                
                let dividerMessage = QBChatMessage()
                self.prepareDividerMessage(dividerMessage, divideDate: divideDate)
                dividerMessage.dateSent = divideDate
                dividerMessage.customParameters[Key.dateDividerKey] = true
                messagesArray.append(dividerMessage)
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.chatDataSource(self,
                                              changeWithMessages: messagesArray,
                                              action: .add)
            }
        }
    }
    
    func deleteMessage(_ message: QBChatMessage) {
        deleteMessages([message])
    }
    
    func deleteMessages(_ messages: [QBChatMessage]) {
        serialQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            var IDs: [String] = []
            var messagesArray: [QBChatMessage] = []
            
            for message in messages {
                if message.isDateDividerMessage {
                    continue
                }
                
                guard let messageID = message.id else {
                    debugPrint("[ChatDataSource] deleteMessages: message must have id!")
                    continue
                }
                
                guard let messageDateSent = message.dateSent else {
                    debugPrint("[ChatDataSource] deleteMessages: message must have dateSent!")
                    continue
                }
                
                if self.isExistMessage(message) == false {
                    continue
                }
                
                messagesArray.append(message)
                IDs.append(messageID)
                
                let startOfDay = Calendar.current.startOfDay(for: messageDateSent)
                var dayComponents = DateComponents()
                dayComponents.setValue(1, for: .day)
                dayComponents.setValue(-1, for: .second)
                guard let endOfDay = Calendar.current.date(byAdding: dayComponents, to: startOfDay) else {
                    continue
                }
                
                let currentDayMessages = self.messages.filter{
                    guard let dateSent = $0.dateSent else {
                        return false
                    }
                    
                    return dateSent >= startOfDay && dateSent <= endOfDay
                }
                
                // divider message + message
                let needAddDividerMessage = currentDayMessages.count == 2
                
                if needAddDividerMessage == false {
                    continue
                }
                
                let currentDividerMessage = currentDayMessages.filter{
                    return $0.isDateDividerMessage
                    }.first
                
                guard let dividerMessage = currentDividerMessage, let dividerID = dividerMessage.id else {
                    continue
                }
                messagesArray.append(dividerMessage)
                IDs.append(dividerID)
                
                self.dividers.remove(startOfDay)
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.delegate?.chatDataSource(self, willChangeWithMessageIDs: IDs)
                
                self.delegate?.chatDataSource(self,
                                              changeWithMessages: messagesArray,
                                              action: .remove)
            }
        }
    }
    
    func updateMessage(_ message: QBChatMessage) {
        updateMessages([message])
    }
    
    func updateMessages(_ messages: [QBChatMessage]) {
        serialQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            var IDs: [String] = []
            var messagesArray: [QBChatMessage] = []
            
            for message in messages {
                if message.isDateDividerMessage {
                    continue
                }
                
                guard let messageID = message.id else {
                    debugPrint("[ChatDataSource] updateMessages: message must have id!")
                    continue
                }
                
                if self.isExistMessage(message) == false {
                    continue
                }
                
                messagesArray.append(message)
                IDs.append(messageID)
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.delegate?.chatDataSource(self, willChangeWithMessageIDs: IDs)
                
                self.delegate?.chatDataSource(self,
                                              changeWithMessages: messagesArray,
                                              action: .update)
            }
        }
    }
    
    func performChangesFor(messages: [QBChatMessage], action: ChatDataSourceAction) -> [IndexPath] {
        switch action {
        case .add:
            var insertedMessage: [QBChatMessage] = []
            messages.forEach {
                let index = messageInsertIndex($0)
                if self.messages.first != $0 {
                    self.messages.insert($0, at: index)
                    insertedMessage.append($0)
                }
            }
            let indexPaths = messagesIndexPaths(insertedMessage)
            return indexPaths
        case .update:
            var indexPaths: [IndexPath] = []
            
            messages.forEach {
                if let indexPath = messageIndexPath($0) {
                    self.messages[indexPath.item] = $0
                    indexPaths.append(indexPath)
                }
            }
            
            return indexPaths
        case .remove:
            let indexPaths = messagesIndexPaths(messages)
            
            indexPaths.forEach {
                self.messages.remove(at: $0.item)
            }
            
            return indexPaths
        }
    }
    
    func clear() {
        messages = []
    }
    
    //MARK: - Internal Methods
    private func prepareDividerMessage(_ dividerMessage: QBChatMessage, divideDate: Date) {
        let formatter = DateFormatter()
        if divideDate.hasSame([.year], as: Date()) == true {
            formatter.dateFormat = "d MMM"
        } else {
            formatter.dateFormat = "d MMM, yyyy"
        }
        
        if Calendar.current.isDateInToday(divideDate) == true {
            dividerMessage.text = "Today"
        } else if Calendar.current.isDateInYesterday(divideDate) == true {
            dividerMessage.text = "Yesterday"
        } else {
            dividerMessage.text = formatter.string(from: divideDate)
        }
    }
    
    private func messagesIndexPaths(_ messages: [QBChatMessage]) -> [IndexPath] {
        return messages.compactMap{ messageIndexPath($0) }
    }
    
    private func messageInsertIndex(_ message: QBChatMessage) -> Int {
        let index = messages.firstIndex(where: { (item) -> Bool in
            item.dateSent! <= message.dateSent!
        })
        return index ?? messages.endIndex
    }
}
