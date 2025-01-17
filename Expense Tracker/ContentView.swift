//
//  ContentView.swift
//  Expense Tracker
//
//  Created by Marina Barannikov on 07/09/2024.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            NavigationStack {
                ExpenseLog()
            }
           .tabItem {
                Image(systemName: "plus.app")
                Text("Add Expense")
            }.tag(0)
            NavigationStack {
                AnalysisView()
            }
            .tabItem {
                  Image(systemName: "list.bullet")
                  Text("Expenses")
            }.tag(1)
            NavigationStack {
                GraphicalAnalysisView()
            }
           .tabItem {
                  Image(systemName: "chart.bar")
                  Text("Insights")
            }.tag(2)
            NavigationStack {
                MistralPhotoView()
            }
            .tabItem {
                    Label("Save Receipt", systemImage: "photo")
            }.tag(3)
            NavigationStack {
                ChatView()
            }
            .tabItem {
                    Label("Chat", systemImage: "bubble.right.and.text.bubble.left.fill")
            }.tag(3)
        }
        .accentColor(Constants.appTintColor)
    }
}

#Preview() {
    ContentView()
}
