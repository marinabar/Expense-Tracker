//
//  AnalysisView.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 10/09/2024.
//

import Foundation
import RealmSwift
import SwiftUI

struct AnalysisView: View {
    @State private var expenses: [Expense] = []
    
    var body: some View {
        List {
            ForEach(expenses.indices, id: \.self) { index in
                ExpenseRowView(expense: expenses[index])
            }
            // swiftUI returns an array of indexes to delete
            // even if we have only one element to delete, we still get a list
            .onDelete { indexSet in
                let realm = try! Realm()
                
                for index in indexSet {
                    let expenseToDelete = expenses[index]
                    try! realm.write {
                        realm.delete(expenseToDelete)
                    }
                }
                // update the fetched local version
                indexSet.forEach { index in
                    expenses.remove(at: index)
                }
            }
        }
       .onAppear {
            let realm = try! Realm()
            expenses = realm.objects(Expense.self).map { $0 }
        }
       .padding(.top, 1)
    }
}
