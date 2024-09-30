//
//  GraphicalAnalysisView.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 12/09/2024.
//

import SwiftUI
import Charts
import RealmSwift


struct GraphicalAnalysisView: View {
    @State private var expenses: [Expense] = []
    @State private var selectedCategory: Category?
    @State private var showPopup: Bool = false
    @State private var expensesDict: [Category: (total: Double, color: Color, range: ClosedRange<Double>)] = [:]
    @State private var totalExpenses: Double = 0.0
    @State private var rawSelection: Int?
    @State private var totalAmount: Double = 0.0
    
    var body: some View {
        ZStack {
            VStack {
                let sortedCategories = expensesDict.keys.sorted { (category1, category2) -> Bool in
                    guard let range1 = expensesDict[category1]?.range,
                          let range2 = expensesDict[category2]?.range else {
                        return false
                    }
                    return range1.lowerBound < range2.lowerBound
                }
                Chart(sortedCategories, id: \.self) { category in
                    if let categoryData = expensesDict[category] {
                        SectorMark(
                            angle: .value("Amount", categoryData.total),
                            innerRadius: .ratio(0),
                            angularInset: 2
                        )
                        .cornerRadius(5)
                        .foregroundStyle(categoryData.color)
                    }
                }
                .frame(height: 300)
                .chartAngleSelection(value: $rawSelection)
                .onChange(of: rawSelection) {
                    guard let rawSelection = rawSelection else { return }
                    handleTap(value: rawSelection)
                }
            }
            
            if showPopup, let category = selectedCategory {
                Color.black
                    .opacity(0.3)  // Semi-transparent background
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showPopup = false  // Close popup when tapping outside
                    }
                
                VStack {
                    Text("\(category.rawValue.capitalized) Expenses")
                        .font(.headline)
                    Text(String(format: "$%.2f", totalAmount))
                        .font(.body)  // Smaller font size
                        .padding()
                }
                .frame(width: 200, height: 150)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding()
                .transition(.scale)  // Animation for pop-up
                .zIndex(1)  // Ensure the popup is on top
            }
        }
        .onAppear {
            loadExpenses()
            getExpensesandColors()
        }
    }


    
    func loadExpenses() {
            let realm = try! Realm()
            let allExpenses = realm.objects(Expense.self)
            expenses = Array(allExpenses)
    }
        
    func getExpensesandColors() {
            var categoryTotals: [Category: Double] = [:]
            
            // Compute total expenses by category
            for expense in expenses {
                if let category = expense.category {
                    categoryTotals[category, default: 0.0] += expense.amount
                }
            }
            
            // Compute total expenses
            totalExpenses = categoryTotals.values.reduce(0, +)
            
            // Create an array of tuples with colors and ranges
            var accumulatedAmount: Double = 0.0
            for (category, total) in categoryTotals {
                // Assign a blue or purple hue to each category
                let hue = Double(abs(category.rawValue.hashValue % 360)) / 360.0
                let color = Color(hue: hue * 0.5 + 0.5, saturation: 0.7, brightness: 0.8)
                
                // Compute the range for this category
                let lowerBound = accumulatedAmount
                accumulatedAmount += total
                let upperBound = accumulatedAmount
                
                // Add to the dictionary
                expensesDict[category] = (total, color, lowerBound...upperBound)
            }
        }
        
    func handleTap(value: Int) {
            let expenseValue = Double(value)  // Convert value to a Double for comparison
            
            // Find the category corresponding to the tapped value based on the ranges in the dictionary
            if let tappedCategory = expensesDict.first(where: { $0.value.range.contains(expenseValue) }) {
                selectedCategory = tappedCategory.key
                totalAmount = tappedCategory.value.total
                showPopup = true
            }
    }
}



#Preview {
    // Setup Realm with sample data
    let realm = try! Realm()
    let sampleExpenses = [
        Expense(value: ["amount": 50.0, "categoryString": Category.food.rawValue]),
        Expense(value: ["amount": 30.0, "categoryString": Category.transportation.rawValue]),
        Expense(value: ["amount": 20.0, "categoryString": Category.housing.rawValue])
    ]

    try! realm.write {
        realm.add(sampleExpenses)
    }

    // Create a view with sample data
    return GraphicalAnalysisView()
}
