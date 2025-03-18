//
//  ExpenseService.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 17/01/2025.
//

import Foundation
import RealmSwift

class ExpenseService {
    private let realm = try! Realm()
    
    // Start with all expenses
    func allExpenses() -> Results<Expense> {
        realm.objects(Expense.self)
    }
    
    // Filter by date range
    func filterByDate(_ results: Results<Expense>, start: Date, end: Date) -> Results<Expense> {
        let filteredResults = results.filter("date >= %@ AND date <= %@", start, end)
        return filteredResults
    }
    
    // Filter by category
    func filterByCategory(_ results: Results<Expense>, category: String) -> Results<Expense> {
        let filteredResults = results.filter("categoryString == %@", category)
        print("Filtering for category: \(category), Found: \(filteredResults.count) items")
        return filteredResults
    }
}
