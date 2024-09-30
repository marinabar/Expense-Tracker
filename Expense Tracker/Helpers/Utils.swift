//
//  Utils.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 10/09/2024.
//

import Foundation

struct Utils {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter
    }()
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.isLenient = true
        formatter.currencyCode = "EUR"
        formatter.numberStyle = .currency
        return formatter
    }()
    
}
