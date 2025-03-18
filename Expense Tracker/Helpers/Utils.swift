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
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.isLenient = true
        formatter.currencyCode = "EUR"
        formatter.numberStyle = .currency
        return formatter
    }()
    
    func formatExpenseDataForPrompt(_ expenses: [String: Any]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: expenses, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? "No data available"
        } catch {
            return "Error formatting data"
        }
    }
    static func getAPIKey() -> String? {
        return ProcessInfo.processInfo.environment["MISTRAL_API_KEY"]
    }
    static func createMistralAPIRequest(requestBody: [String: Any]) -> URLRequest? {
        // Fetch the API key
        guard let apiKey = getAPIKey() else {
            print("API Key not set")
            return nil
        }

        // Convert Swift dictionary to JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("Failed to serialize JSON")
            return nil
        }

        // Create the URL request
        var request = URLRequest(url: URL(string: "https://api.mistral.ai/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        return request
    }
}
