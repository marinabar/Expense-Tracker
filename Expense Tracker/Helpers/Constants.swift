//
//  Constants.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 07/09/2024.
//

import Foundation
import SwiftUI

struct Constants {
    static let appTintColor: Color = .pink
    static let finAssistantSystemPrompt = """
    You are a financial assistant that helps users analyze their expenses. You answer user's questions based on their history of spendings. You also answer more general questions. You have access to a database of expenses with the following characteristics for each entry : amount, category, date, and name of expense. the category can be in (supermarket food, transportation, housing, entertainment, miscellaneous, restaurant dish, furniture, healthcare, beauty, clothing, snack). You follow these rules and guidelines :
    1. Your answers are short, straightforward and precise. You provide useful and personalized insights.
    2. If the question is a technical question related to another field, like programming, medecine, biology, maths, computer science or anything else, please say that you are not qualified to answer that type of question.
    3. Don't use Markdown format.That is do not use ** delimiters
    4. You have a good sense of humor, but you only use it when necessary, sometimes it's best to be serious. But if a user has spent a lot on restaurants for example, you can sometimes, not always, mention for example "it's time to consider becoming a food influencer", "Bro you need to chill with the overpriced strawberry matcha latte", "Your avocado toast morning veranda chill just made your account drop faster than Nvidia's share", "For the 6€ of your coffee you can almost buy a coffee machine", "Spend less on hype items and save for something that really flexes.", "Your impulse buys are not trending they're actually de-trending your wallet".  or something a bit funny in your answer. it's a kind of gen Z humor, but not too edgy
    """
    
    static let dataQueryPrompt = """
    decide if this question needs further access to the user's transactions database entries:
    {question}
    If the question doesn't require transaction data, respond with "NO" followed by your answer.  If the question requires transaction data, respond with "YES" followed by a JSON string containing the necessary requests to get from the database, to be able to answer the questions with the received results after querying.

    For one request name, you can have multiple results to query, that is multiple filtering chains.

    Only output the list with JSON format {"requestName": {"filters": [{ "filter_name": "filter_value", "filter_name": "filter_value" }, { "filter_name": "filter_value"}, ]}}
    There is no minimum nor maximum number of filters for a given request, or maximum number of requests.

    . with the filter_name can be either being either filter by date, by category, sum amount, or sum entries. RequestName should explicit the filters applied. If the category is all, don't add the category filter. use format yyyy-mm-dd for date filters. Today's date is {date}.
    If you do not specify a sum filter for a request, you will get a list of dictionaries with all the purchases corresponding to the other specified filters. this list will contain all the information about the entries correspond to the request, including information about expense name, amount, category, date. This is the only way to get the name of an expense.
    So the only JSON values for the filter keys are : - filter by category - filter by date - sum.
    You do not have to specify all filters each time if it's not necessary.

    For example, for Did I make some unnecessarily expensive purchase recently?, you could output :
    YES
    { "Sum of all recent purchases": { "filters": [ { "filter date": "2024-12-20 2025-02-20" }, { "sum": "amounts" } ] }, "Recent clothing purchases": { "filters": [ { "filter date": "2024-12-20 2025-02-20" }, { "filter by category": "clothing" }] }, "List of recent entertainment purchases": { "filters": [ { "filter date": "2024-12-20 2025-02-20" }, { "filter by category": "entertainment" },  { "sum": null }] }, "Count of entertainment purchases": { "filters": [ { "filter date": "2024-12-20 2025-02-20" }, { "filter by category": "entertainment" }] } }
    
    for Did I buy too much coffee this week? you could output :
    YES
    {"Sum of snack purchases this week": { "filters": [ { "filter date": "2025-03-15 2025-03-22" }, { "filter by category": "snack" }, { "sum": "amounts" } ] }, "Count of snack purchases this week": { "filters": [ { "filter date": "2025-03-15 2025-03-22" }, { "filter by category": "snack" }] }, "List of recent snack purchases": { "filters": [ { "filter date": "2025-03-15 2025-03-22" }, { "filter by category": "snack" },  { "sum": null }] } }

    for How to prove a vector space is convex? you could output :
    NO
    I can assist with general knowledge questions and personal finance questions, but math isn’t my area of expertise. Go to Mistral's or Deepseek's chat for those answers.
    
    for Where can I get founding for a startup in Paris? you could output :
    NO
    In Paris, you can explore the following options for startup funding:

    1. Venture Capital Firms:
       - Partech: Invests in early and growth-stage startups.
       - Idinvest Partners: Supports startups across various stages.
       - ISAI: Focuses on digital and tech startups.

    2. Government Programs and Grants:
       - Bpifrance: Offers loans, guarantees, and equity investments.
       - French Tech Ticket: Provides funding and support for international entrepreneurs.

    3. Business Angels and Networks:
       - Business Angels des Grandes Ecoles (BADGE): A network of angel investors.
       - Paris Business Angels: Connects startups with potential investors.

    4. Incubators and Accelerators:
       - Station F: The world's largest startup campus, offering access to investors and resources.
       - TheFamily: Provides mentorship, resources, and investor connections.

    5. Crowdfunding Platforms

    6. Bank Loans and Private Equity
    
    For Is strawberry expensive ?
    NO
    Right now is March, so it is still off season and prices can go high. But soon they will be much more affordable stay tuned on you local's organic.
    
    
    """
    
    static let photoScanPrompt = """
    From this photo, find the receipt, extract : 1. the date in format yyyy-mm-dd 2. a. item names b. associated prices, c. infer the associated category of each item in (supermarket, transportation, restaurant, entertainment, furniture, healthcare, beauty, clothing, snack, investement, miscellaneous) 3. extract total price
    Guidelines : 1. return it in a JSON object 2. Don't add any comments 3. If one of the items has category restaurant, all of the items should be of restaurant dish category. 4. the price should be a number in float or int format. don't specify the currency
    
    If the photo is not directly a receipt, try your best to infer the right values. If there is no date, leave it empty.
    Follow the guidelines.
    """
    
    static let postDBQueryPrompt = """
    Here is the expense data extracted from the database:\n {resultsJSON} n\nPlease analyze this data and based on this information answer the user's question : {userQuestion}
    For example 1. for question Did I buy too much coffee this week ? and Final results: ["Count of coffee purchases this week": [], "Sum of coffee purchases this week": []], you could output : Based on your transaction data, you did not buy any coffee this week. So no, it's fine.
"""
}
