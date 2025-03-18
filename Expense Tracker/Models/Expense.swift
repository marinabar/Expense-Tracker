//
//  Expense.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 07/09/2024.
//

import RealmSwift
import Foundation

enum Category: String, CaseIterable {
    case supermarket_food = "supermarket food"
    case transportation
    case housing
    case entertainment
    case miscellaneous
    case restaurant_dish = "restaurant dish"
    case furniture
    case healthcare
    case beauty
    case clothing
    case snack
    case investement
}

class Expense: Object, Identifiable {
    @objc dynamic var id = UUID()
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var date: Date = Date()
    @objc dynamic var categoryString: String = Category.miscellaneous.rawValue
    @objc dynamic var expenseName: String = "Default"
    
    var category: Category? {
        return Category(rawValue: categoryString) ?? .miscellaneous
       }
}
