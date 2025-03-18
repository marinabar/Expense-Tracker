//
//  Message.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 23/01/2025.
//

import RealmSwift
import Foundation

class ChatMessage: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var content: String
    @Persisted var isUser: Bool
    @Persisted var timestamp: Date

    convenience init(content: String, isUser: Bool) {
        self.init()
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
    }
}
