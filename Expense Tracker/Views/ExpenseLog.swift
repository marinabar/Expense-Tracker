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
                Section(header: Text("Transaction")) {
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
                Section {
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
                            print("Error saving transaction: \(error)")
                        }
                    }) {
                        Text("Add Transaction")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.accentColor.opacity(0.9))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.top, 20)
                    .listRowBackground(Color.clear)
                }
            }
            .padding(.top, 1)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}
