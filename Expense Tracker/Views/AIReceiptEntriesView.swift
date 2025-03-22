//
//  AIReceiptEntriesView.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 12/01/2025.
//

import SwiftUI
import RealmSwift

// EditableExpense structure for SwiftUI bindings
struct EditableExpense: Identifiable {
    let id = UUID()
    var name: String
    var date: Date
    var category: String
    var amount: Double
}

// ReceiptData structure for decoding JSON
struct ReceiptData: Decodable {
    let date: Date
    let items: [ReceiptItem]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = (try? container.decode(Date.self, forKey: .date)) ?? Date()
        items = try container.decode([ReceiptItem].self, forKey: .items)
    }
    
    private enum CodingKeys: String, CodingKey {
        case date
        case items
    }
}

struct ReceiptItem: Decodable {
    let name: String
    let category: String
    let price: Double
}


struct AIReceiptEntriesView: View {
    @State private var expenses: [EditableExpense] = []
    @Environment(\.presentationMode) var presentationMode
    
    let responseJSON: [String: Any] // Pass the response JSON here

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text("Manually edit the recognized data")
                        .padding(5)
                        .font(.title2)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(8)
                        
                    Spacer()
                    if expenses.isEmpty {
                        Text("No expenses to display")
                    }
                    ForEach($expenses) { $expense in
                        VStack(alignment: .leading, spacing: 8) {
                            // Expense Name (left-aligned)
                            TextField("Name", text: $expense.name)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Editable attributes in a single line
                            HStack(spacing: 10) {
                                DatePicker("", selection: $expense.date, displayedComponents: .date)
                                    .labelsHidden()
                                    //.frame(maxWidth: 100)
                                
                                TextField("Amount", value: $expense.amount, format: .number)
                                    .keyboardType(.decimalPad)
                                    .frame(maxWidth: 60)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .multilineTextAlignment(.trailing)
                                
                                Picker("", selection: $expense.category) {
                                    ForEach(Category.allCases, id: \.self) { category in
                                        Text(category.rawValue.capitalized)
                                            .tag(category.rawValue)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            .frame(maxWidth: .infinity)
                            
                            // Validation for empty category
                            if expense.category.isEmpty {
                                Text("Please select a valid category")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity) // Full-width block
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }

            }
            
            // Validation Button
            Button(action: saveExpensesToDatabase) {
                Text("Validate")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Constants.appTintColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onAppear {
            if let parsedExpenses = parseResponse(responseJSON) {
                print("Parsed expenses: \(parsedExpenses)")
                expenses = parsedExpenses
            } else {
                print("Failed to parse response")
            }
        }
    }

    // Parse the API response
    func parseResponse(_ responseJSON: [String: Any]) -> [EditableExpense]? {
        // Extract the content from the nested response structure
        guard let choicesArray = responseJSON["choices"] as? [[String: Any]],
              let firstChoice = choicesArray.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            print("Failed to extract message content")
            return nil
        }
        guard let jsonData = content.data(using: .utf8) else {
            print("Failed to extract JSON string")
            return nil
        }
        
        // Setup date decoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Utils.dateFormatter)
        
        do {
            let receiptData = try decoder.decode(ReceiptData.self, from: jsonData)
            
            // Convert to EditableExpense objects
            let expenses = receiptData.items.map { item in
                EditableExpense(
                    name: item.name,
                    date: receiptData.date,
                    category: item.category,
                    amount: item.price
                )
            }
            
            return expenses
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }


    // Save expenses to Realm
    func saveExpensesToDatabase() {
        do {
            let realm = try Realm()
            try realm.write {
                for expense in expenses {
                    let newExpense = Expense()
                    newExpense.expenseName = expense.name
                    newExpense.amount = expense.amount
                    newExpense.date = expense.date
                    newExpense.categoryString = expense.category
                    
                    realm.add(newExpense)
                }
            }
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving to Realm: \(error)")
        }
    }
}

