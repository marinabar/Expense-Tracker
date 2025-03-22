//
//  ChatViewModel.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 17/01/2025.
//


import RealmSwift
import Foundation

class ChatViewModel: ObservableObject {
    private let expenseService = ExpenseService()
    @Published var queryResults: [String: Any] = [:]
    // gets the LLM answer from the JSON API output
    @Published var chatbotResponse: String = ""
    
    
    @Published var messages: [ChatMessage] = []
    @Published var newMessageText: String = ""
    private var realm: Realm?
    private var userQuestion : String = ""
    @Published var isSendingMessage:Bool = false

    init() {
        // what to do upon initialization
        do {
            realm = try Realm()
            fetchMessages()
        } catch {
            print("Error initializing Realm: \(error)")
        }
    }

    func sendMessage() {
        guard !newMessageText.isEmpty else { return }

        // Create the user message
        let userMessage = ChatMessage(content: newMessageText, isUser: true)
        self.userQuestion = userMessage.content

        // Save user message to Realm message database
        saveMessages([userMessage])

        // Clear the input field
        newMessageText = ""
        // Call API
        isSendingMessage = true
        generateFirstResponse(userMessage: userMessage)
    }
    
    private func generateFirstResponse(userMessage: ChatMessage) {
        // generate the first prompt for the model based on the user's query
        print(userMessage.content)
        
        // Construct the request body
        let requestBody: [String: Any] = [
            "model": "mistral-small-latest",
            "messages": [
                ["role": "system",
                 "content": Constants.finAssistantSystemPrompt],
                ["role": "user",
                 "content": Constants.dataQueryPrompt
                     .replacingOccurrences(of: "{question}",
                                           with: userMessage.content)
                     .replacingOccurrences(of: "{date}",
                                           with: Utils.dateFormatter.string(from: Date()))]
            ]
        ]
        
        if let request = Utils.createMistralAPIRequest(requestBody: requestBody) {
            // Use the request for your API call
            print("Request created successfully")
            
            // Send the request
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Request failed: \(error)")
                    DispatchQueue.main.async {
                        self.isSendingMessage = false
                    }
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    DispatchQueue.main.async {
                        self.isSendingMessage = false
                    }
                    return
                }
                
                // Get the response content asynchronously
                self.processResponseContent(data: data) { responseContent in
                    DispatchQueue.main.async {
                        if !responseContent.isEmpty {
                            self.addMessageToChat(content: responseContent, isUser: false)
                        }
                        self.isSendingMessage = false
                    }
                }
            }
            task.resume()
        } else {
            print("Failed to create API request")
            DispatchQueue.main.async {
                self.isSendingMessage = false
            }
        }
    }
    
    // Process the response data and extract the content
    // we update the values in an asynchronous way to prevent it from blocking the main thread.
    // completion is a mean of delivering this change
    func processResponseContent(data: Data, completion: @escaping (String) -> Void) {
        let content = processJSONAPIResponse(data)
        if content == "" {
            completion("")
            return
        }
        
        print("Received content: \(content)")
        if content.starts(with: "NO") {
            if let range = content.range(of: "NO") {
                let postNO = String(content[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                completion(postNO)
                return
            } else {
                completion(content)
            }
            return
        }
        // Check if the response starts with "YES"
        if content.starts(with: "YES") {
            // Extract the JSON after "YES"
            if let range = content.range(of: "YES") {
                let jsonString = String(content[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                DispatchQueue.main.async {
                    // Execute the filters and get the results
                    let results = self.executeOperationChain(from: jsonString)
                    
                    // Convert results to JSON string
                    let resultsJSON = self.convertResultsToJSON(results)
                    
                    // Send second request with the results
                    self.generateSecondResponse(resultsJSON: resultsJSON) { secondResponse in
                        // This code runs when the second request finishes
                        completion(secondResponse)
                    }
                }
                return
            } else {
                completion("Error processing database query")
                return
            }
        }
        completion(content)
    }
    
    // Add the processed message to the chat
    func addMessageToChat(content: String, isUser: Bool) {
        DispatchQueue.main.async {
            let message = ChatMessage(content: content, isUser: isUser)
            self.saveMessages([message])
        }
    }
    
    private func saveMessages(_ messages: [ChatMessage]) {
        guard let realm = realm else { return }

        do {
            try realm.write {
                realm.add(messages) // Save all messages in one transaction
            }
            fetchMessages() // Refresh the messages list
        } catch {
            print("Error saving messages: \(error)")
        }
    }
    
    
    private func fetchMessages() {
        guard let realm = realm else { return }
        // gets the messages from realm into a sorted array
        let results = realm.objects(ChatMessage.self).sorted(byKeyPath: "timestamp", ascending: true)
        messages = Array(results)
    }
    
    // function for executing queries to the database
    func executeOperationChain(from jsonString: String) -> [String: Any] {
        guard let data = jsonString.data(using: .utf8) else {
            print("Invalid JSON string")
            return [:]
        }

        do {
            let queryRequests = try JSONDecoder().decode(QueryRequests.self, from: data)
            var resultsDictionary: [String: Any] = [:]
            
            let allData = expenseService.allExpenses()
            if allData.isEmpty {
                print("No expenses found in database.")
                return [:]
            }
            print("all expenses : \(allData)")

            for (queryName, request) in queryRequests {
                print("Processing query: \(queryName)")
                var results: Results<Expense> = expenseService.allExpenses()
                var isAggregationRequest = false

                for filter in request.filters {
                    if let dateRange = filter.filterDate {
                        let (start, end) = parseDateRange(dateRange)
                        print("data range start :\(start) end \(end)")
                        results = expenseService.filterByDate(results, start: start, end: end)
                        print("After date filter: \(results.count) results")
                    }
                    if let category = filter.filterByCategory {
                        results = expenseService.filterByCategory(results, category:category)
                        print("After category filter: \(results.count) results")
                    }
                    // check if aggregation request
                    if filter.sum != nil {
                        isAggregationRequest = true
                    }
                }
                if results.isEmpty{
                    print("No results found for query: \(queryName) after applying all filters")
                    resultsDictionary[queryName] = []
                    continue
                }
                    
                // process any aggregation request
                for filter in request.filters {
                    if let sumKey = filter.sum {
                        if sumKey == "amounts" {
                            let totalSum = results.sum(ofProperty: "amount") as Double? ?? 0.0
                            print("Sum of amounts: \(totalSum)")
                            resultsDictionary[queryName] = totalSum
                        } else if sumKey == "entries" {
                            let totalEntries = results.count
                            print("Count of entries: \(totalEntries)")
                            resultsDictionary[queryName] = totalEntries
                        }
                    }
                }

                // If no aggregation operation was requested, return the list of expenses
                if !isAggregationRequest {
                    let expenseArray = Array(results.map { self.expenseToDictionary($0) })
                    resultsDictionary[queryName] = expenseArray
                }
            }

            DispatchQueue.main.async {
                self.queryResults = resultsDictionary
            }
            print("Final results: \(resultsDictionary)")
            return resultsDictionary

        } catch {
            print("Failed to parse JSON: \(error)")
            return [:]
        }
    }
    
    func generateSecondResponse(resultsJSON: String, completion: @escaping (String) -> Void) {    // Set up waiting state
        DispatchQueue.main.async {
            self.isSendingMessage = true
        }
        
        // This will be a synchronous request to keep the function simple
        let requestBody: [String: Any] = [
            "model": "mistral-small-latest",
            "messages": [
                ["role": "system", "content": Constants.finAssistantSystemPrompt],
                ["role": "user", "content": Constants.postDBQueryPrompt
                    .replacingOccurrences(of: "{resultsJSON}", with: resultsJSON)
                    .replacingOccurrences(of: "{userQuestion}", with: self.userQuestion)
                    ]
            ]
        ]
        if let request = Utils.createMistralAPIRequest(requestBody: requestBody) {
            // asynchronous call to API so that we don't block main thread
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                var responseContent = "Sorry, I couldn't analyze the expense data."
                
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    responseContent = content
                }
                DispatchQueue.main.async {
                    completion(responseContent)
                }
            }
        task.resume()
        }
    }
        
    
    // convert the dictionary of results to json
    func convertResultsToJSON(_ results: [String: Any]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? "Error converting to JSON string"
        } catch {
            print("Error converting results to JSON: \(error)")
            return "{}"
        }
    }
    
    func processJSONAPIResponse(_ data: Data) -> String {
        guard let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("Failed to parse JSON response")
            return ""
        }
        guard let choices = responseJSON["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            print("Failed to extract message content")
            return ""
        }
        return content
    }
    
    func constructExpensesPrompt(requestsJSONOutput: String, userQuestion: String) -> String {
        return """
        Here is the user's financial data:
        \(requestsJSONOutput)
        
        Based on this information, \(userQuestion)
        """
    }

    private func parseDateRange(_ range: String) -> (Date, Date) {
        // Convert data string to Date() type
        let dates = range.split(separator: " ").compactMap { Utils.dateFormatter.date(from: String($0)) }
        guard dates.count == 2 else { return (Date(), Date()) }
        return (dates[0], dates[1])
    }
    
    private func expenseToDictionary(_ expense: Expense) -> [String: Any] {
        return [
            "amount": expense.amount,
            "category": expense.categoryString,
            "date": Utils.dateFormatter.string(from: expense.date),
            "expenseName": expense.expenseName
        ]
    }
}


struct FilterOperation: Codable {
    let filterDate: String?
    let filterByCategory: String?
    let sum: String?
    
    enum CodingKeys: String, CodingKey {
    // Without CodingKeys, Swift would expect JSON keys to match property names exactly (filterDate would expect "filterDate" in JSON).
        case filterDate = "filter date"
        case filterByCategory = "filter by category"
        case sum
    }
}

struct QueryRequest: Codable {
    let filters: [FilterOperation]
}

typealias QueryRequests = [String: QueryRequest]
