//
//  Constants.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 07/09/2024.
//

import Foundation
import SwiftUI

struct Constants {
    static let appTintColor: Color = .red
    static let finAssistantSystemPrompt = """
    You are a financial assistant that helps users analyze their expenses. You answer user's questions based on their history of spendings. You also answer more general questions. You have access to a database of expenses with the following characteristics for each entry : amount, category, date, and name of expense. the category can be in (supermarket food, transportation, housing, entertainment, miscellaneous, restaurant dish, furniture, healthcare, beauty, clothing, snack). Your answers are short, straightforward and precise. You provide useful and personalized insights.
    """
    
    static let dataQueryPrompt = """
    decide if this question needs further access to the user's transactions database entries:
    {question}
    If the question doesn't require transaction data, respond with "NO" followed by your answer.  If the question requires transaction data, respond with "YES" followed by a JSON string containing the necessary requests to get from the database, to be able to answer the questions with the received results after querying.

    For one request name, you can have multiple results to query, that is multiple filtering chains.

    Only output the list with JSON format {"requestName": {"filters": [{ "filter_name": "filter_value", "filter_name": "filter_value" }, { "filter_name": "filter_value", "filter_name": "filter_value" }, ]}}

    . with the filters being either filter by date, by category, sum amount, or sum entries. RequestName should explicit the filters applied. If the category is all, don't add the category filter. the request can output a list of expenses. use format yyyy-mm-dd for date filters. Today's date is {date}.

    For example, for Did I make some unnecessarily expensive purchase recently?, you could output :
    YES
    { "Sum of all recent purchases": { "filters": [ { "filter date": "2024-12-20 2025-02-20" }, { "sum": "amounts" } ] }, "Recent clothing purchases": { "filters": [ { "filter date": "2024-12-20 2025-02-20" }, { "filter by category": "clothing" }] }, "Recent entertainment purchases": { "filters": [ { "filter date": "2024-12-20 2025-02-20" }, { "filter by category": "entertainment" }] }, "Count of entertainment purchases": { "filters": [ { "filter date": "2024-12-20 2025-02-20" }, { "filter by category": "entertainment" }, { "sum": "entries" } ] } }
    
    """
}
