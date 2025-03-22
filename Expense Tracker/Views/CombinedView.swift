import SwiftUI
import Charts
import RealmSwift

struct CombinedView: View {
    @State private var expenses: [Expense] = []
    @State private var filteredExpenses: [Expense] = []
    @State private var selectedCategory: Category?
    @State private var expensesDict: [Category: (total: Double, color: Color)] = [:]
    @State private var selectedDate: Date?
    @State private var showDatePicker = false
    @State private var rawSelection: Int?
    
    var body: some View {
        ZStack() {
            ScrollView {
                
                VStack(spacing: 10) {
                    // Pie Chart
                    let categories = Array(expensesDict.keys)
                    let values = categories.map { expensesDict[$0]?.total ?? 0 }
                    let totalValue = values.reduce(0, +)
                    
                    if totalValue > 0 {
                        Chart {
                            ForEach(Array(expensesDict.keys.sorted { $0.rawValue < $1.rawValue }), id: \.self) { category in
                                SectorMark(
                                    angle: .value("Amount", expensesDict[category]?.total ?? 0),
                                    innerRadius: .ratio(0),
                                    angularInset: 2
                                )
                                .foregroundStyle(expensesDict[category]?.color ?? .gray)
                                .opacity(selectedCategory == category ? 1.0 : (selectedCategory == nil ? 1.0 : 0.2))
                            }
                        }
                        .frame(height: 250)
                        .chartAngleSelection(value: $rawSelection)
                        .onChange(of: rawSelection) { oldValue, newValue in
                            if let newValue = newValue {
                                handlePieSelection(value: newValue)
                            }
                        }
                    } else {
                        Text("No data available")
                            .foregroundColor(.gray)
                            .frame(height: 250)
                    }
                    
                    // Title
                    Text(selectedCategory == nil ? "All Transactions" : "\(selectedCategory!.rawValue.capitalized) Transactions")
                        .font(.headline)
                        .padding()
                    
                    // calendar picker for choosing the period
                    HStack {
                        Button(action: {
                            if selectedDate != nil {
                                // If date is already selected, clear the filter
                                selectedDate = nil
                                updateFilters()
                            } else {
                                showDatePicker.toggle()
                            }
                        }) {
                            HStack {
                                Text(selectedDate == nil ? "All Time" : formatDate(selectedDate!))
                                Image(systemName: "calendar")
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(selectedDate == nil ? Color.clear : Color.accentColor.opacity(0.2))
                            .cornerRadius(6)
                        }
                        
                        Spacer()
                        
                        // Total amount
                        Text(formatAmount(selectedCategory == nil ?
                              expensesDict.values.reduce(0) { $0 + $1.total } :
                              expensesDict[selectedCategory!]?.total ?? 0))
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 5)
                    .background(Color(UIColor.systemGroupedBackground))
                    
                    // Date picker popup
                    if showDatePicker {
                        DatePicker("", selection: Binding(
                            get: { selectedDate ?? Date() },
                            set: { selectedDate = $0 }
                        ), displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .padding()
                            .onChange(of: selectedDate) { oldValue, newValue in
                                updateFilters()
                                showDatePicker = false
                            }
                    }
                    
                    // Expense List
                    if filteredExpenses.isEmpty {
                        Text("No transactions found")
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                    } else {
                        ForEach(filteredExpenses, id: \.id) { expense in
                            ExpenseRowView(expense: expense)
                                .padding(.horizontal)
                            Divider()
                        }
                    }
                }
            }
            .padding(.top, 8) // to ensure content doesn't cover up status bar
        }
        .onAppear(perform: loadData)
    }
    
    // Load initial data and show all expenses by default
    private func loadData() {
        let realm = try! Realm()
        expenses = Array(realm.objects(Expense.self))
        // 2. Default view with all expenses from all time
        updateFilters()
    }
    
    // Update filters based on current selections
    private func updateFilters() {
        if let selectedDate = selectedDate {
            // Filter by month if date is selected
            let calendar = Calendar.current
            let month = calendar.component(.month, from: selectedDate)
            let year = calendar.component(.year, from: selectedDate)
            
            let monthlyExpenses = expenses.filter { expense in
                calendar.component(.month, from: expense.date) == month &&
                calendar.component(.year, from: expense.date) == year
            }
            
            // Calculate chart data for the filtered month
            calculateChartData(from: monthlyExpenses)
            
            // Further filter by category if selected
            filteredExpenses = selectedCategory == nil ?
                monthlyExpenses.sorted(by: { $0.date > $1.date }) :
                monthlyExpenses.filter { $0.category == selectedCategory }
                              .sorted(by: { $0.date > $1.date })
        } else {
            // Show all expenses from all time by default
            calculateChartData(from: expenses)
            
            // Filter by category if selected
            filteredExpenses = selectedCategory == nil ?
                expenses.sorted(by: { $0.date > $1.date }) :
                expenses.filter { $0.category == selectedCategory }
                        .sorted(by: { $0.date > $1.date })
        }
    }
    
    // Calculate data for pie chart
    private func calculateChartData(from data: [Expense]) {
        expensesDict.removeAll()
        
        // Group by category
        let grouped = Dictionary(grouping: data) { $0.category ?? .miscellaneous }
        
        // Calculate totals and assign colors
        for (category, expenses) in grouped {
            let total = expenses.reduce(0) { $0 + $1.amount }
            let index = abs(category.rawValue.hashValue % 5)
            let opacities = [0.3, 0.45, 0.6, 0.75, 0.9]
            let color = Color.accentColor.opacity(opacities[index])
            expensesDict[category] = (total, color)
        }
    }
    
    // Handle pie chart selection
    private func handlePieSelection(value: Int) {
        // Convert selection to a percentage
        let totalValue = expensesDict.values.reduce(0) { $0 + $1.total }
        let percentage = Double(value) / 360.0
        
        // Find cumulative percentages for each category
        var cumulative = 0.0
        var found = false
        
        for (category, data) in expensesDict {
            let categoryPercentage = data.total / totalValue
            
            if cumulative <= percentage && percentage < (cumulative + categoryPercentage) {
                // Toggle selection if clicking the same category
                if selectedCategory == category {
                    selectedCategory = nil
                } else {
                    selectedCategory = category
                }
                found = true
                break
            }
            
            cumulative += categoryPercentage
        }
        
        // If we didn't find a match, might be a rounding issue at the edges
        if !found && selectedCategory != nil {
            selectedCategory = nil
        }
        
        // Update filtered expenses based on new selection
        updateFilters()
    }
    
    // Format date as "Month Year"
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    // Format currency amount
    private func formatAmount(_ amount: Double) -> String {
        return Utils.numberFormatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(expense.expenseName.lowercased())
                .font(.headline)
            
            HStack {
                Text(Utils.dateFormatter.string(from: expense.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(Utils.numberFormatter.string(from: NSNumber(value: expense.amount)) ?? "$0.00")
            }
            
            if let category = expense.category {
                Text(category.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.vertical, 8)
    }
}
