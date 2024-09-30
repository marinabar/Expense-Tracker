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
        }
       .onAppear {
            let realm = try! Realm()
            expenses = realm.objects(Expense.self).map { $0 }
        }
    }
}

struct ExpenseRowView: View {
    var expense: Expense
    
    var body: some View {
        HStack {
            VStack(alignment:.leading) {
                Text("Expense: \(expense.expenseName)")
                Text("Amount: \(Utils.numberFormatter.string(from: NSNumber(value:  expense.amount)) ?? "0")")
                Text("Date: \(Utils.dateFormatter.string(from: expense.date))")
            }
            Spacer()
        }
    }
}

#Preview {
    do {
        let realm = try Realm()
        
        try realm.write {
            let expense1 = Expense()
            expense1.amount = 32
            expense1.date = Date()
            realm.add(expense1)
            
            let expense2 = Expense()
            expense2.amount = 43
            expense2.date = Date()
            realm.add(expense2)
            
            let expense3 = Expense()
            expense3.amount = 54
            expense3.date = Date()
            realm.add(expense3)
        }
    } catch {
        print("Error creating Realm database: \(error)")
    }
  return AnalysisView()
}
