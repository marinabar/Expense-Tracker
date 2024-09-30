//
//  ExpenseLog.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 10/09/2024.
//

import SwiftUI
import RealmSwift

struct ExpenseLog: View {
    
    @State private var date = Date()
    @State private var amount = ""
    @State private var name = ""
    @State private var category : Category = .miscellaneous
    
    let categories: [Category] = Category.allCases
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Expense")) {
                    TextField("Name", text: $name)
                    .keyboardType(.default)
                }
                Section(header: Text("Amount")) {
                    TextField("Amount", text: $amount)
                      .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                }
            }
            
            Button(action: {
                // Save the expense
                let expense = Expense()
                if let amount = Double(self.amount) {
                    expense.amount = amount
                }
                expense.date = self.date
                expense.expenseName = self.name
                expense.categoryString = self.category.rawValue
                
                // Save the expense to the Realm database
                do {
                    try Realm().write {
                        try Realm().add(expense)
                    }
                } catch {
                    print("Error saving expense: \(error)")
                }
            }) {
                Text("Add Expense")
            }
        }
    }
}

#Preview {
    ExpenseLog()
}
