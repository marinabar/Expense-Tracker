//
//  ChatView.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 17/01/2025.
//

import SwiftUI
/*
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var executionResult: [String: Any] = [:]
    @State private var executionJSON: String = ""

    var body: some View {
        VStack {
            Button("Process JSON") {
                let jsonString = """
                {
                    "Sum of restaurant dish expenses from 2024-07-22 to 2025-01-22": {
                        "filters": [
                            { "filter date": "2024-07-22 2025-01-22" },
                            { "filter by category": "restaurant dish" },
                            { "sum": "amounts" }
                        ]
                    },
                    "List of restaurant dish expenses from 2024-07-22 to 2025-01-22": {
                        "filters": [
                            { "filter date": "2024-07-22 2025-01-22" },
                            { "filter by category": "restaurant dish" }
                        ]
                    }
                }
                """
                
                let userQuery = "How much did I spend the last six months on restaurants?"
                // return des résultats de la base de données
                executionResult = viewModel.executeOperationChain(from: jsonString)
                // convert swift dictionnary to JSON
                executionJSON = viewModel.convertResultsToJSONString()
                // create next prompt
                let chatbotPrompt = viewModel.constructPrompt(requestsJSONOutput: executionJSON, userQuestion: userQuery)
                print(chatbotPrompt)
        
            }
        Text(executionJSON)
        Text(viewModel.chatbotResponse)
                .padding()
        }
    }
}*/

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        VStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        if viewModel.isSendingMessage {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages) {
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    if let lastMessage = viewModel.messages.last {
                        scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }

            // Input field and send button
            HStack {
                TextField("Type a message...", text: $viewModel.newMessageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .padding()
                }
                .disabled(viewModel.isSendingMessage)
            }
            .padding()
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            } else {
                Text(message.content)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(10)
                Spacer()
            }
        }
    }
}
